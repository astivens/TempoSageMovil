import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/recommendation_service.dart';
import '../../activities/data/models/activity_model.dart';

class ActivityRecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService =
      ServiceLocator.instance.recommendationService;

  List<ActivityModel> _recommendedActivities = [];
  bool _isLoading = false;
  bool _isModelInitialized = false;
  String? _error;

  List<ActivityModel> get recommendedActivities => _recommendedActivities;
  bool get isLoading => _isLoading;
  bool get isModelInitialized => _isModelInitialized;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _recommendationService.initialize();
      _isModelInitialized = true;
    } catch (e) {
      _error = 'Error al inicializar el servicio de recomendaciones: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommendations() async {
    if (!_isModelInitialized) {
      _error = 'El modelo no está inicializado';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final recommendations = await _recommendationService.getRecommendations();
      _recommendedActivities = recommendations.map((rec) {
        if (rec is Map<String, dynamic>) {
          return ActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: rec['title'] as String? ?? 'Actividad sugerida',
            description: rec['description'] as String? ?? '',
            startTime: DateTime.now().add(const Duration(hours: 1)),
            endTime: DateTime.now().add(const Duration(hours: 2)),
            category: rec['category'] as String? ?? 'General',
            priority: 'Media',
          );
        }
        return ActivityModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Actividad sugerida',
          description: '',
          startTime: DateTime.now().add(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          category: rec.toString(),
          priority: 'Media',
        );
      }).toList();
    } catch (e) {
      _error = 'Error al cargar recomendaciones: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRecommendations() async {
    await loadRecommendations();
  }

  @override
  void dispose() {
    _recommendedActivities.clear();
    super.dispose();
  }
}
