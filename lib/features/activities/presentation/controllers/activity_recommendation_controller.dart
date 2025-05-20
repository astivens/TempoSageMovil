import 'package:flutter/foundation.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/recommendation_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/activity.dart';

class ActivityRecommendationController extends ChangeNotifier {
  final ActivityRepository _activityRepository;
  final RecommendationService _recommendationService;
  final Logger _logger = Logger.instance;

  List<ActivityModel> _recommendedActivities = [];
  bool _isLoading = false;
  String? _error;
  bool _isModelInitialized = false;

  ActivityRecommendationController({
    ActivityRepository? activityRepository,
    RecommendationService? recommendationService,
  })  : _activityRepository =
            activityRepository ?? ServiceLocator.instance.activityRepository,
        _recommendationService = recommendationService ??
            ServiceLocator.instance.recommendationService;

  List<ActivityModel> get recommendedActivities => _recommendedActivities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isModelInitialized => _isModelInitialized;

  Future<void> initialize() async {
    if (_isModelInitialized) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _recommendationService.initialize();
      _isModelInitialized = true;

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error al inicializar el servicio de recomendaciones',
          tag: 'RecommendationController', error: e, stackTrace: stackTrace);
      _error = 'No se pudo inicializar el servicio de recomendaciones';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommendations() async {
    try {
      if (!_isModelInitialized) {
        await initialize();
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Obtener el historial de actividades del usuario
      final activities = await _activityRepository.getAllActivities();

      // Convertir actividades a eventos de interacción
      final interactionEvents = activities
          .map((activity) => InteractionEvent(
                itemId: activity.category,
                timestamp: activity.startTime.millisecondsSinceEpoch ~/ 1000,
                eventType: activity.isCompleted ? 'completed' : 'created',
              ))
          .toList();

      // Obtener recomendaciones del servicio
      final recommendations = await _recommendationService.getRecommendations(
        interactionEvents: interactionEvents,
        type: 'activity',
      );

      // Convertir recomendaciones a actividades sugeridas
      _recommendedActivities = recommendations.map((category) {
        return ActivityModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Actividad sugerida en $category',
          description:
              'Basado en tu historial, te sugerimos una actividad en esta categoría',
          startTime: DateTime.now().add(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          category: category,
          priority: 'Media',
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error al cargar recomendaciones',
          tag: 'RecommendationController', error: e, stackTrace: stackTrace);
      _error = 'No se pudieron cargar las recomendaciones';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> suggestOptimalTime(ActivityModel activity) async {
    try {
      _isLoading = true;
      notifyListeners();

      final activities = await _activityRepository.getAllActivities();
      final pastActivities = activities
          .where((a) =>
              a.category == activity.category &&
              a.startTime.isBefore(DateTime.now()))
          .toList();

      // Convertir ActivityModel a Activity (entidad de dominio)
      final domainActivities = pastActivities
          .map((a) => Activity(
                id: a.id,
                name: a.title,
                date: a.startTime,
                category: a.category,
                description: a.description,
                isCompleted: a.isCompleted,
              ))
          .toList();

      final optimalTimes =
          await ServiceLocator.instance.suggestOptimalTimeUseCase.execute(
        activityCategory: activity.category,
        pastActivities: domainActivities,
        targetDate: activity.startTime,
      );

      if (optimalTimes.isNotEmpty) {
        final bestTime = optimalTimes.first;
        final suggestedStartTime =
            DateTime.fromMillisecondsSinceEpoch(bestTime['startTime']);
        final suggestedEndTime =
            DateTime.fromMillisecondsSinceEpoch(bestTime['endTime']);

        final updatedActivity = activity.copyWith(
          startTime: suggestedStartTime,
          endTime: suggestedEndTime,
        );

        await _activityRepository.updateActivity(updatedActivity);
        _logger.i(
            'Tiempo óptimo sugerido y aplicado para actividad ${activity.id}',
            tag: 'RecommendationController');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error al sugerir tiempo óptimo',
          tag: 'RecommendationController', error: e, stackTrace: stackTrace);
      _error = 'No se pudo sugerir un tiempo óptimo';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _recommendationService.dispose();
    super.dispose();
  }
}
