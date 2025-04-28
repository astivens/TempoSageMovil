import 'package:flutter/material.dart';
import 'dart:async';
import '../../activities/data/models/activity_model.dart';
import '../../habits/data/models/habit_model.dart';
import '../../activities/data/repositories/activity_repository.dart';
import '../../habits/domain/repositories/habit_repository.dart';
import '../../timeblocks/data/repositories/time_block_repository.dart';
import '../../timeblocks/data/models/time_block_model.dart';
import '../../habits/domain/services/habit_to_timeblock_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../habits/domain/entities/habit.dart';

class DashboardController extends ChangeNotifier {
  final ActivityRepository _activityRepository;
  final HabitRepository _habitRepository;
  final TimeBlockRepository _timeBlockRepository;
  final HabitToTimeBlockService _habitToTimeBlockService;

  List<ActivityModel> _activities = [];
  List<HabitModel> _habits = [];
  List<TimeBlockModel> _timeBlocks = [];
  bool _isLoading = false;

  DashboardController({
    required ActivityRepository activityRepository,
    required HabitRepository habitRepository,
  })  : _activityRepository = activityRepository,
        _habitRepository = habitRepository,
        _timeBlockRepository = ServiceLocator.instance.timeBlockRepository,
        _habitToTimeBlockService =
            ServiceLocator.instance.habitToTimeBlockService;

  List<ActivityModel> get activities => _activities;
  List<HabitModel> get habits => _habits;
  List<TimeBlockModel> get timeBlocks => _timeBlocks;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentDay = DateTimeHelper.getDayOfWeek(now);

      // Precarga asíncrona de timeblocks de hábitos para que estén listos antes
      _preloadHabitTimeBlocks(today);

      // Cargamos todos los datos al mismo tiempo
      final futures = await Future.wait([
        _habitRepository.getHabitsByDayOfWeek(currentDay),
        _activityRepository.getActivitiesByDate(today),
        _timeBlockRepository.getTimeBlocksByDate(today),
      ]);

      // La lista de entidades Habit debe convertirse a HabitModel para que funcionen los métodos existentes
      final habitsEntities = futures[0] as List<Habit>;
      _habits = habitsEntities.map(_mapEntityToModel).toList();

      _activities = futures[1] as List<ActivityModel>;
      _timeBlocks = futures[2] as List<TimeBlockModel>;

      debugPrint('Cargando hábitos para hoy: ${today.toString()}');
      debugPrint('Hábitos cargados: ${_habits.length}');

      debugPrint('Cargando actividades para hoy: ${today.toString()}');
      debugPrint('Actividades cargadas: ${_activities.length}');

      debugPrint('Cargando timeblocks para hoy: ${today.toString()}');
      debugPrint('Timeblocks iniciales cargados: ${_timeBlocks.length}');

      // Ordenamos los elementos por hora
      _sortAllLists();

      debugPrint(
          'Total de items cargados: ${_activities.length + _habits.length + _timeBlocks.length}');
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Precarga de timeblocks para hábitos sin bloquear la UI
  Future<void> _preloadHabitTimeBlocks(DateTime date) async {
    try {
      // Obtener los hábitos para hoy
      final now = DateTime.now();
      final currentDay = DateTimeHelper.getDayOfWeek(now);
      final habitsEntities =
          await _habitRepository.getHabitsByDayOfWeek(currentDay);

      // Convertir a modelo
      final habitsForToday = habitsEntities.map(_mapEntityToModel).toList();

      // Si no hay hábitos, no hacemos nada
      if (habitsForToday.isEmpty) return;

      // Actualizar timeblocks para estos hábitos en segundo plano
      // Usando una versión simplificada sin unawaited
      _createTimeBlocksInBackground(habitsForToday, date).then((_) {
        debugPrint('Timeblocks precargados completados');
      });
    } catch (e) {
      debugPrint('Error en precarga de timeblocks: $e');
    }
  }

  // Método para crear timeblocks en segundo plano sin bloquear la UI
  Future<void> _createTimeBlocksInBackground(
      List<HabitModel> habits, DateTime date) async {
    try {
      await _habitToTimeBlockService.convertHabitsToTimeBlocks(date);
      debugPrint('Timeblocks precargados en segundo plano');
    } catch (e) {
      debugPrint('Error creando timeblocks en segundo plano: $e');
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

    // Ordenar timeblocks por hora de inicio
    _timeBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
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
}
