import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/models/interaction_event.dart';
import './recommendation_service.dart';
import '../features/activities/data/models/activity_model.dart';
import '../core/services/service_locator.dart';

class ActivityRecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLoading = true;
  String _resultMessage = "Inicializando...";
  List<String> _recommendations = [];
  Map<String, dynamic>? _activityDetails = {};
  bool _isModelInitialized = false;
  List<String> _recentlyCreatedActivities = [];

  bool get isLoading => _isLoading;
  String get resultMessage => _resultMessage;
  List<String> get recommendations => _recommendations;
  Map<String, dynamic>? get activityDetails => _activityDetails;
  bool get isModelInitialized => _isModelInitialized;
  List<String> get recentlyCreatedActivities => _recentlyCreatedActivities;

  Future<void> initialize() async {
    if (_isModelInitialized) return;

    try {
      _isLoading = true;
      _resultMessage = "Cargando modelo TiSASRec...";
      notifyListeners();

      // 1. Cargar el servicio
      await _recommendationService.loadModelAndPreprocessor();

      // 2. Cargar detalles de actividades
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

      // Generar historial de usuario basado en actividades reales
      final List<InteractionEvent> userHistory = await _generateUserHistory();

      // Obtener recomendaciones
      final recommendations = await _recommendationService.getRecommendations(
        userHistory,
        topK: 5,
      );

      // Filtrar recomendaciones para no mostrar las que ya se crearon recientemente
      _recommendations = recommendations
          .where((r) => !_recentlyCreatedActivities.contains(r))
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
    // En producción, obtendríamos un historial real de las actividades del usuario
    final List<InteractionEvent> history = [];

    try {
      // Intentar obtener actividades recientes del usuario
      final activityRepo = ServiceLocator.instance.activityRepository;
      // Obtener actividades del día actual
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<ActivityModel> recentActivities =
          await activityRepo.getActivitiesByDate(today);

      if (recentActivities.isNotEmpty) {
        // Convertir actividades a eventos de interacción
        for (int i = 0; i < recentActivities.length; i++) {
          final activity = recentActivities[i];

          // Mapear la categoría de actividad a un ID del modelo
          // En un escenario real, necesitaríamos un mapeo más sofisticado
          final String itemId = _mapActivityToModelId(activity.category);

          history.add(InteractionEvent(
            itemId: itemId,
            timestamp: activity.startTime.millisecondsSinceEpoch ~/ 1000,
          ));
        }
      } else {
        // Si no hay actividades, usar datos de prueba
        return _generateTestHistory();
      }
    } catch (e) {
      debugPrint('Error al obtener historial de actividades: $e');
      return _generateTestHistory();
    }

    return history;
  }

  String _mapActivityToModelId(String category) {
    // Mapear categorías de actividades a IDs del modelo
    // Esto es simplificado, en producción necesitarías un mapeo más robusto
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

    return categoryToId[category] ?? '1'; // Default a ejercicio si no hay match
  }

  List<InteractionEvent> _generateTestHistory() {
    // Generar datos de prueba si no hay historial real
    final List<String> activityIds = ['1', '2', '3', '4', '5'];
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final List<InteractionEvent> history = [];

    for (int i = 0; i < 5; i++) {
      history.add(InteractionEvent(
        itemId: activityIds[i % activityIds.length],
        timestamp:
            now - (50 - i) * 86400, // Un evento cada día, últimos 50 días
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
      if (startTime == null) {
        final now = DateTime.now();
        startTime = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
          0,
        );
      }

      // Si no se proporciona hora de fin, usar hora de inicio + 1 hora
      if (endTime == null) {
        endTime = startTime.add(const Duration(hours: 1));
      }

      // Crear el modelo de actividad
      final activity = ActivityModel.create(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        category: category,
        priority: priority,
        sendReminder: sendReminder,
        reminderMinutesBefore: reminderMinutesBefore,
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

  void dispose() {
    _recommendationService.dispose();
    super.dispose();
  }
}
