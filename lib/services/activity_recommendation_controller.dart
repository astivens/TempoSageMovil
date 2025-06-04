import 'package:flutter/material.dart';
import '../core/services/recommendation_service.dart';
import '../features/activities/data/models/activity_model.dart';
import '../core/services/service_locator.dart';

class ActivityRecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLoading = true;
  String _resultMessage = "Inicializando...";
  List<dynamic> _recommendations = [];
  Map<String, dynamic>? _activityDetails = {};
  bool _isModelInitialized = false;
  final List<String> _recentlyCreatedActivities = [];

  bool get isLoading => _isLoading;
  String get resultMessage => _resultMessage;
  List<dynamic> get recommendations => _recommendations;
  Map<String, dynamic>? get activityDetails => _activityDetails;
  bool get isModelInitialized => _isModelInitialized;
  List<String> get recentlyCreatedActivities => _recentlyCreatedActivities;

  Future<void> initialize() async {
    if (_isModelInitialized) return;
    try {
      _isLoading = true;
      _resultMessage = "Cargando modelo de recomendaciones...";
      notifyListeners();
      await _recommendationService.initialize();
      await _loadActivityMapping();
      _isModelInitialized = true;
      _isLoading = false;
      _resultMessage = "Modelo cargado correctamente";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resultMessage = "Error al cargar el modelo: $e";
      debugPrint('Error al inicializar el recomendador: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadActivityMapping() async {
    try {
      // En producción, podrías usar datos reales de actividades
      // Por ahora, creamos un mapping simple para pruebas
      _activityDetails = {
        "1": {
          "title": "Ejercicio matutino",
          "category": "Salud",
          "description":
              "Rutina de entrenamiento para comenzar el día con energía"
        },
        "2": {
          "title": "Meditación",
          "category": "Bienestar",
          "description":
              "Sesión para reducir el estrés y mejorar la concentración"
        },
        "3": {
          "title": "Lectura",
          "category": "Desarrollo personal",
          "description": "Tiempo dedicado a leer y expandir conocimientos"
        },
        "4": {
          "title": "Programación",
          "category": "Trabajo",
          "description": "Desarrollar y mantener proyectos de software"
        },
        "5": {
          "title": "Caminata al aire libre",
          "category": "Salud",
          "description": "Tiempo para caminar y disfrutar de la naturaleza"
        },
        "6": {
          "title": "Estudiar",
          "category": "Educación",
          "description":
              "Tiempo dedicado a estudiar y aprender nuevos conceptos"
        },
        "7": {
          "title": "Cocinar comida saludable",
          "category": "Hogar",
          "description": "Preparar comidas nutritivas para la semana"
        },
        "8": {
          "title": "Socializar",
          "category": "Social",
          "description": "Tiempo para conectar con amigos o familia"
        },
        "9": {
          "title": "Planificación semanal",
          "category": "Productividad",
          "description": "Organizar tareas y objetivos para la semana"
        },
        "10": {
          "title": "Yoga",
          "category": "Bienestar",
          "description":
              "Sesión de yoga para mejorar la flexibilidad y reducir el estrés"
        },
      };
    } catch (e) {
      debugPrint('Error al cargar detalles de actividades: $e');
    }
  }

  Future<void> getRecommendations() async {
    try {
      _isLoading = true;
      _resultMessage = "Generando recomendaciones...";
      notifyListeners();
      if (!_isModelInitialized) {
        await initialize();
      }
      final List<InteractionEvent> userHistory = await _generateUserHistory();
      final recommendations = await _recommendationService.getRecommendations(
        interactionEvents: userHistory,
      );
      _recommendations = recommendations
          .where((r) => !_recentlyCreatedActivities.contains(r['title'] ?? r))
          .toList();
      _isLoading = false;
      _resultMessage = "Recomendaciones generadas exitosamente";
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resultMessage = "Error: $e";
      debugPrint('Error al generar recomendaciones: $e');
      notifyListeners();
    }
  }

  Future<List<InteractionEvent>> _generateUserHistory() async {
    final List<InteractionEvent> history = [];
    try {
      final activityRepo = ServiceLocator.instance.activityRepository;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<ActivityModel> recentActivities =
          await activityRepo.getActivitiesByDate(today);
      if (recentActivities.isNotEmpty) {
        for (int i = 0; i < recentActivities.length; i++) {
          final activity = recentActivities[i];
          final String itemId = _mapActivityToModelId(activity.category);
          history.add(InteractionEvent(
            itemId: itemId,
            timestamp: activity.startTime.millisecondsSinceEpoch ~/ 1000,
            eventType: 'activity',
          ));
        }
      } else {
        return _generateTestHistory();
      }
    } catch (e) {
      debugPrint('Error al obtener historial de actividades: $e');
      return _generateTestHistory();
    }
    return history;
  }

  String _mapActivityToModelId(String category) {
    final Map<String, String> categoryToId = {
      'Trabajo': '4',
      'Estudio': '6',
      'Salud': '1',
      'Ejercicio': '5',
      'Personal': '3',
      'Social': '8',
      'Hogar': '7',
      'Bienestar': '2',
      'Productividad': '9',
    };
    return categoryToId[category] ?? '1';
  }

  List<InteractionEvent> _generateTestHistory() {
    final List<String> activityIds = ['1', '2', '3', '4', '5'];
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final List<InteractionEvent> history = [];
    for (int i = 0; i < 5; i++) {
      history.add(InteractionEvent(
        itemId: activityIds[i % activityIds.length],
        timestamp: now - (50 - i) * 86400,
        eventType: 'test',
      ));
    }
    return history;
  }

  String getActivityTitle(String activityId) {
    if (_activityDetails == null ||
        !_activityDetails!.containsKey(activityId)) {
      return 'Actividad $activityId';
    }
    return _activityDetails![activityId]['title'] ?? 'Actividad $activityId';
  }

  String getActivityCategory(String activityId) {
    if (_activityDetails == null ||
        !_activityDetails!.containsKey(activityId)) {
      return 'Sin categoría';
    }
    return _activityDetails![activityId]['category'] ?? 'Sin categoría';
  }

  String getActivityDescription(String activityId) {
    if (_activityDetails == null ||
        !_activityDetails!.containsKey(activityId)) {
      return '';
    }
    return _activityDetails![activityId]['description'] ?? '';
  }

  /// Crea una nueva actividad basada en la recomendación y la añade al repositorio
  Future<ActivityModel?> createActivityFromRecommendation(
    String activityId, {
    DateTime? startTime,
    DateTime? endTime,
    String priority = 'Media',
    bool sendReminder = false,
    int reminderMinutesBefore = 15,
  }) async {
    try {
      final title = getActivityTitle(activityId);
      final category = getActivityCategory(activityId);
      final description = getActivityDescription(activityId);

      // Si no se proporciona hora de inicio, usar la hora actual redondeada a la siguiente hora
      startTime ??= DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour + 1,
        0,
      );

      // Si no se proporciona hora de fin, usar hora de inicio + 1 hora
      endTime ??= startTime.add(const Duration(hours: 1));

      // Crear el modelo de actividad
      final activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        category: category,
        priority: priority,
      );

      // Guardar en el repositorio
      final activityRepo = ServiceLocator.instance.activityRepository;
      await activityRepo.addActivity(activity);

      // Añadir a la lista de actividades recientemente creadas
      _recentlyCreatedActivities.add(activityId);
      if (_recentlyCreatedActivities.length > 10) {
        _recentlyCreatedActivities.removeAt(0);
      }

      // Actualizar las recomendaciones
      await getRecommendations();

      return activity;
    } catch (e) {
      debugPrint('Error al crear actividad desde recomendación: $e');
      return null;
    }
  }
}
