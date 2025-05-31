import 'package:flutter/material.dart';
import 'dart:async';
import '../../activities/data/models/activity_model.dart';
import '../../habits/data/models/habit_model.dart';
import '../../activities/data/repositories/activity_repository.dart';
import '../../habits/domain/repositories/habit_repository.dart';
import '../../habits/domain/services/habit_to_timeblock_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../habits/domain/entities/habit.dart';
import '../../activities/domain/usecases/predict_productivity_use_case.dart';
import '../../activities/domain/usecases/suggest_optimal_time_use_case.dart';
import '../../activities/domain/usecases/analyze_patterns_use_case.dart';
import '../../activities/domain/entities/activity.dart';

class DashboardController extends ChangeNotifier {
  final ActivityRepository _activityRepository;
  final HabitRepository _habitRepository;
  final HabitToTimeBlockService _habitToTimeBlockService;
  final PredictProductivityUseCase _predictProductivityUseCase;
  final SuggestOptimalTimeUseCase _suggestOptimalTimeUseCase;
  final AnalyzePatternsUseCase _analyzePatternsUseCase;

  List<ActivityModel> _activities = [];
  List<HabitModel> _habits = [];
  bool _isLoading = false;

  // Estados para la API
  bool _isApiLoading = false;
  String? _apiError;
  double? _productivityPrediction;
  String? _productivityExplanation;
  List<Map<String, dynamic>>? _timeSuggestions;
  List<Map<String, dynamic>>? _activityPatterns;

  // Estado para la predicción de logro de metas
  bool _isGoalPredictionLoading = false;
  String? _goalPredictionError;
  Map<String, dynamic>? _goalPredictionResult;

  // Estado para la predicción de energía
  bool _isEnergyPredictionLoading = false;
  String? _energyPredictionError;
  Map<String, dynamic>? _energyPredictionResult;

  // Estado para la recomendación de hábitos
  bool _isHabitRecommendationLoading = false;
  String? _habitRecommendationError;
  Map<String, dynamic>? _habitRecommendationResult;

  DashboardController({
    required ActivityRepository activityRepository,
    required HabitRepository habitRepository,
    PredictProductivityUseCase? predictProductivityUseCase,
    SuggestOptimalTimeUseCase? suggestOptimalTimeUseCase,
    AnalyzePatternsUseCase? analyzePatternsUseCase,
  })  : _activityRepository = activityRepository,
        _habitRepository = habitRepository,
        _habitToTimeBlockService =
            ServiceLocator.instance.habitToTimeBlockService,
        _predictProductivityUseCase =
            predictProductivityUseCase ?? PredictProductivityUseCase(),
        _suggestOptimalTimeUseCase =
            suggestOptimalTimeUseCase ?? SuggestOptimalTimeUseCase(),
        _analyzePatternsUseCase =
            analyzePatternsUseCase ?? AnalyzePatternsUseCase();

  List<ActivityModel> get activities => _activities;
  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;

  // Nuevos getters para la API
  bool get isApiLoading => _isApiLoading;
  String? get apiError => _apiError;
  double? get productivityPrediction => _productivityPrediction;
  String? get productivityExplanation => _productivityExplanation;
  List<Map<String, dynamic>>? get timeSuggestions => _timeSuggestions;
  List<Map<String, dynamic>>? get activityPatterns => _activityPatterns;

  // Nuevos getters para la predicción de logro de metas
  bool get isGoalPredictionLoading => _isGoalPredictionLoading;
  String? get goalPredictionError => _goalPredictionError;
  Map<String, dynamic>? get goalPredictionResult => _goalPredictionResult;

  // Nuevos getters para la predicción de energía
  bool get isEnergyPredictionLoading => _isEnergyPredictionLoading;
  String? get energyPredictionError => _energyPredictionError;
  Map<String, dynamic>? get energyPredictionResult => _energyPredictionResult;

  // Nuevos getters para la recomendación de hábitos
  bool get isHabitRecommendationLoading => _isHabitRecommendationLoading;
  String? get habitRecommendationError => _habitRecommendationError;
  Map<String, dynamic>? get habitRecommendationResult =>
      _habitRecommendationResult;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentDay = DateTimeHelper.getDayOfWeek(now);

      debugPrint('=== DASHBOARD LOAD DATA DEBUG ===');
      debugPrint('Fecha de hoy: ${today.toString()}');
      debugPrint('Día actual: $currentDay');

      // Cargamos hábitos y actividades al mismo tiempo
      final futures = await Future.wait([
        _habitRepository.getHabitsByDayOfWeek(currentDay),
        _activityRepository.getActivitiesByDate(today),
      ]);

      // La lista de entidades Habit debe convertirse a HabitModel para que funcionen los métodos existentes
      final habitsEntities = futures[0] as List<Habit>;
      _habits = habitsEntities.map(_mapEntityToModel).toList();

      _activities = futures[1] as List<ActivityModel>;

      debugPrint('Hábitos cargados para $currentDay: ${_habits.length}');
      for (final habit in _habits) {
        debugPrint('  - ${habit.title} (${habit.daysOfWeek.join(', ')})');
      }

      debugPrint('Actividades cargadas para hoy: ${_activities.length}');
      for (final activity in _activities) {
        debugPrint('  - ${activity.title} (${activity.startTime})');
      }

      // Si no hay datos para hoy, verificar si hay datos en general
      if (_habits.isEmpty && _activities.isEmpty) {
        debugPrint('No hay datos para hoy, verificando datos generales...');
        await _loadFallbackData();
      }

      // Ordenamos los elementos por hora
      _sortAllLists();

      debugPrint(
          'Total de items cargados: ${_activities.length + _habits.length}');
      debugPrint('=== FIN DEBUG LOAD DATA ===');
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga datos de respaldo si no hay elementos para el día actual
  Future<void> _loadFallbackData() async {
    try {
      // Cargar todos los hábitos y actividades para mostrar algo al usuario
      final allHabitsEntities = await _habitRepository.getAllHabits();
      final allActivities = await _activityRepository.getAllActivities();

      debugPrint(
          'Datos de respaldo - Todos los hábitos: ${allHabitsEntities.length}');
      debugPrint(
          'Datos de respaldo - Todas las actividades: ${allActivities.length}');

      // Si hay hábitos en general pero no para hoy, mostrar algunos como ejemplo
      if (allHabitsEntities.isNotEmpty && _habits.isEmpty) {
        // Tomar hasta 3 hábitos como ejemplo para mostrar en el dashboard
        _habits = allHabitsEntities.take(3).map(_mapEntityToModel).toList();
        debugPrint('Mostrando ${_habits.length} hábitos como ejemplo');
      }

      // Si hay actividades recientes pero no para hoy, mostrar las más recientes
      if (allActivities.isNotEmpty && _activities.isEmpty) {
        final now = DateTime.now();
        final recentActivities = allActivities.where((activity) {
          final daysDiff = now.difference(activity.startTime).inDays;
          return daysDiff <= 7; // Actividades de la última semana
        }).toList();

        if (recentActivities.isNotEmpty) {
          _activities = recentActivities.take(3).toList();
          debugPrint(
              'Mostrando ${_activities.length} actividades recientes como ejemplo');
        }
      }
    } catch (e) {
      debugPrint('Error cargando datos de respaldo: $e');
    }
  }

  // Método para ordenar todas las listas por hora
  void _sortAllLists() {
    // Ordenar actividades por hora de inicio
    _activities.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Ordenar hábitos por hora (extraer hora de string)
    _habits.sort((a, b) {
      final timeA = _parseTimeToMinutes(a.time);
      final timeB = _parseTimeToMinutes(b.time);
      return timeA.compareTo(timeB);
    });
  }

  // Parse time string to minutes for sorting
  int _parseTimeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return hour * 60 + minute;
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return 0;
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _activityRepository.deleteActivity(activityId);
      await loadData();
    } catch (e) {
      debugPrint('Error al eliminar actividad: $e');
      rethrow;
    }
  }

  Future<void> toggleActivityCompletion(String activityId) async {
    try {
      await _activityRepository.toggleActivityCompletion(activityId);
      await loadData();
    } catch (e) {
      debugPrint('Error al cambiar estado de actividad: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(HabitModel habit) async {
    try {
      await _habitRepository.deleteHabit(habit.id);
      // También eliminar los timeblocks asociados
      await _habitToTimeBlockService.deleteTimeBlocksForHabit(habit);
      await loadData();
    } catch (e) {
      debugPrint('Error al eliminar hábito: $e');
      rethrow;
    }
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    try {
      // Crear la entidad Habit desde el modelo
      final habitEntity = _mapModelToEntity(habit);
      // Actualizar al estado opuesto
      final updatedHabit = habitEntity.copyWith(isDone: !habitEntity.isDone);
      // Actualizar en el repositorio
      await _habitRepository.updateHabit(updatedHabit);

      // Actualizar el estado de los timeblocks asociados
      await _habitToTimeBlockService.syncTimeBlocksForHabit(habit);
      await loadData();
    } catch (e) {
      debugPrint('Error al cambiar estado de hábito: $e');
      rethrow;
    }
  }

  String _getCurrentPeriod() {
    final now = TimeOfDay.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 18) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  List<ActivityModel> getMorningActivities() {
    return _activities.where((activity) {
      final hour = activity.startTime.hour;
      return hour >= 5 && hour < 12;
    }).toList();
  }

  List<ActivityModel> getAfternoonActivities() {
    return _activities.where((activity) {
      final hour = activity.startTime.hour;
      return hour >= 12 && hour < 18;
    }).toList();
  }

  List<ActivityModel> getEveningActivities() {
    return _activities.where((activity) {
      final hour = activity.startTime.hour;
      return hour >= 18 || hour < 5;
    }).toList();
  }

  List<HabitModel> getCurrentPeriodHabits() {
    final period = _getCurrentPeriod();
    final filteredHabits = <HabitModel>[];

    for (final habit in _habits) {
      final time = _parseTimeToHourMinute(habit.time);
      if (time == null) continue;

      final hour = time.hour;

      if (period == 'morning' && hour >= 5 && hour < 12) {
        filteredHabits.add(habit);
      } else if (period == 'afternoon' && hour >= 12 && hour < 18) {
        filteredHabits.add(habit);
      } else if (period == 'evening' && (hour >= 18 || hour < 5)) {
        filteredHabits.add(habit);
      }
    }

    return filteredHabits;
  }

  TimeOfDay? _parseTimeToHourMinute(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return null;
  }

  List<HabitModel> getMorningHabits() {
    return _habits.where((habit) {
      final time = _parseTimeToHourMinute(habit.time);
      if (time == null) return false;

      final hour = time.hour;
      return hour >= 5 && hour < 12;
    }).toList();
  }

  List<HabitModel> getAfternoonHabits() {
    return _habits.where((habit) {
      final time = _parseTimeToHourMinute(habit.time);
      if (time == null) return false;

      final hour = time.hour;
      return hour >= 12 && hour < 18;
    }).toList();
  }

  List<HabitModel> getEveningHabits() {
    return _habits.where((habit) {
      final time = _parseTimeToHourMinute(habit.time);
      if (time == null) return false;

      final hour = time.hour;
      return hour >= 18 || hour < 5;
    }).toList();
  }

  // Mapper from HabitModel to Habit entity
  Habit _mapModelToEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.title,
      description: model.description,
      daysOfWeek: model.daysOfWeek,
      category: model.category,
      reminder: model.reminder,
      time: model.time,
      isDone: model.isCompleted,
      dateCreation: model.dateCreation,
    );
  }

  // Mapper from Habit entity to HabitModel
  HabitModel _mapEntityToModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      title: entity.name,
      description: entity.description,
      daysOfWeek: entity.daysOfWeek,
      category: entity.category,
      reminder: entity.reminder,
      time: entity.time,
      isCompleted: entity.isDone,
      dateCreation: entity.dateCreation,
    );
  }

  // Convertir ActivityModel a Activity para la API
  Activity _mapActivityModelToEntity(ActivityModel model) {
    return Activity(
      id: model.id,
      name: model.title,
      date: model.startTime,
      category: model.category,
      description: model.description,
      isCompleted: model.isCompleted,
    );
  }

  /// Predice la productividad para la fecha objetivo
  Future<void> predictProductivity({DateTime? targetDate}) async {
    _isApiLoading = true;
    // Reset de datos previos
    _productivityPrediction = null;
    _productivityExplanation = null;
    _apiError = null;
    notifyListeners();

    try {
      final date = targetDate ?? DateTime.now();
      // Convertir las actividades y hábitos al formato de entidad para la API
      final activities = _activities.map(_mapActivityModelToEntity).toList();
      final habits = _habits.map(_mapModelToEntity).toList();

      // Si no hay suficientes datos, no realizar la llamada
      if (activities.isEmpty) {
        debugPrint('Insuficientes actividades para predecir productividad');
        _isApiLoading = false;
        notifyListeners();
        return;
      }

      final result = await _predictProductivityUseCase.executeWithExplanation(
        activities: activities,
        habits: habits,
        targetDate: date,
      );

      // Verificamos que haya resultados válidos
      if (result.containsKey('prediction')) {
        _productivityPrediction = result['prediction'] as double;
        _productivityExplanation = result['explanation'] as String? ??
            'Predicción basada en tus actividades y hábitos recientes.';
      } else {
        debugPrint('Respuesta de API sin predicción');
      }
    } catch (e) {
      _apiError = e.toString();
      debugPrint('Error al predecir productividad: $e');
    } finally {
      _isApiLoading = false;
      notifyListeners();
    }
  }

  /// Sugiere horarios óptimos para una categoría de actividad
  Future<void> suggestOptimalTimes({
    required String activityCategory,
    DateTime? targetDate,
  }) async {
    _isApiLoading = true;
    // Reset de datos previos
    _timeSuggestions = [];
    _apiError = null;
    notifyListeners();

    try {
      final date = targetDate ?? DateTime.now();
      // Filtrar actividades de la misma categoría y convertirlas
      final pastActivities = _activities
          .where((a) => a.category == activityCategory)
          .map(_mapActivityModelToEntity)
          .toList();

      // Si no hay suficientes actividades previas, no realizar la llamada
      if (pastActivities.isEmpty || pastActivities.length < 2) {
        _timeSuggestions = [];
        debugPrint('Insuficientes actividades previas para sugerir horarios');
        _isApiLoading = false;
        notifyListeners();
        return;
      }

      final result = await _suggestOptimalTimeUseCase.executeWithExplanation(
        activityCategory: activityCategory,
        pastActivities: pastActivities,
        targetDate: date,
      );

      // Verificar si hay sugerencias en la respuesta
      final suggestions = result['suggestions'];
      if (suggestions == null) {
        _timeSuggestions = [];
      } else {
        _timeSuggestions = List<Map<String, dynamic>>.from(suggestions);
      }
    } catch (e) {
      _apiError = e.toString();
      debugPrint('Error al sugerir horarios: $e');
      _timeSuggestions = []; // Inicializar como lista vacía en caso de error
    } finally {
      _isApiLoading = false;
      notifyListeners();
    }
  }

  /// Analiza patrones en las actividades
  Future<void> analyzePatterns({int timePeriod = 30}) async {
    _isApiLoading = true;
    // Reset de datos previos
    _activityPatterns = [];
    _apiError = null;
    notifyListeners();

    try {
      // Convertir actividades al formato de entidad para la API
      final activities = _activities.map(_mapActivityModelToEntity).toList();

      // Si no hay suficientes actividades, no realizar la llamada
      if (activities.isEmpty || activities.length < 2) {
        _activityPatterns = [];
        debugPrint('Insuficientes actividades para análisis de patrones');
        _isApiLoading = false;
        notifyListeners();
        return;
      }

      final result = await _analyzePatternsUseCase.executeWithExplanation(
        activities: activities,
        timePeriod: timePeriod,
      );

      // Verificar si hay patrones en la respuesta
      final patterns = result['patterns'];
      if (patterns == null) {
        _activityPatterns = [];
      } else {
        _activityPatterns = List<Map<String, dynamic>>.from(patterns);
      }
    } catch (e) {
      _apiError = e.toString();
      debugPrint('Error al analizar patrones: $e');
      _activityPatterns = []; // Inicializar como lista vacía en caso de error
    } finally {
      _isApiLoading = false;
      notifyListeners();
    }
  }

  /// Predice el logro de una meta a largo plazo
  Future<void> predictGoalAchievement({
    required String goalDescription,
    required DateTime targetDeadline,
  }) async {
    _isGoalPredictionLoading = true;
    _goalPredictionError = null;
    _goalPredictionResult = null;
    notifyListeners();

    try {
      // Implementación pendiente
      _goalPredictionResult = {
        'prediction': 0.0,
        'explanation': 'Funcionalidad en desarrollo'
      };
    } catch (e) {
      _goalPredictionError = e.toString();
      debugPrint('Error al predecir logro de meta: $e');
    } finally {
      _isGoalPredictionLoading = false;
      notifyListeners();
    }
  }

  /// Predice los niveles de energía y riesgo de burnout
  Future<void> predictEnergyLevels(
      {Map<String, dynamic>? selfAssessment}) async {
    _isEnergyPredictionLoading = true;
    _energyPredictionError = null;
    _energyPredictionResult = null;
    notifyListeners();

    try {
      // Implementación pendiente
      _energyPredictionResult = {
        'energyLevel': 0.0,
        'burnoutRisk': 0.0,
        'explanation': 'Funcionalidad en desarrollo'
      };
    } catch (e) {
      _energyPredictionError = e.toString();
      debugPrint('Error al predecir niveles de energía: $e');
    } finally {
      _isEnergyPredictionLoading = false;
      notifyListeners();
    }
  }

  /// Recomienda hábitos personalizados y contextuales
  Future<void> recommendHabits({required List<String> userGoals}) async {
    _isHabitRecommendationLoading = true;
    _habitRecommendationError = null;
    _habitRecommendationResult = null;
    notifyListeners();

    try {
      // Implementación pendiente
      _habitRecommendationResult = {
        'recommendations': [],
        'explanation': 'Funcionalidad en desarrollo'
      };
    } catch (e) {
      _habitRecommendationError = e.toString();
      debugPrint('Error al recomendar hábitos: $e');
    } finally {
      _isHabitRecommendationLoading = false;
      notifyListeners();
    }
  }

  // Método público para refrescar el dashboard después de cambios
  Future<void> refreshDashboard() async {
    debugPrint('🔄 Refrescando dashboard manualmente...');
    await loadData();
    debugPrint('✅ Dashboard refrescado completamente');
  }

  // Método para notificar cambios y recargar automáticamente
  void notifyDataChanged() {
    debugPrint('🔔 Datos modificados, recargando dashboard...');
    loadData();
  }
}
