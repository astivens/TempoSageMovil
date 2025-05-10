import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/core/services/tempo_sage_api_service.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';

/// Caso de uso para sugerir horarios óptimos para actividades
class SuggestOptimalTimeUseCase {
  final TempoSageApiService _apiService;

  SuggestOptimalTimeUseCase({
    TempoSageApiService? apiService,
  }) : _apiService = apiService ?? ServiceLocator.instance.tempoSageApiService;

  /// Obtiene sugerencias de horarios óptimos para una categoría de actividad
  Future<List<Map<String, dynamic>>> execute({
    required String activityCategory,
    required List<Activity> pastActivities,
    required DateTime targetDate,
  }) async {
    try {
      final result = await _apiService.suggestOptimalTime(
        activityCategory: activityCategory,
        pastActivities: pastActivities,
        targetDate: targetDate,
      );

      // Extraer y devolver solo las sugerencias
      return List<Map<String, dynamic>>.from(result['suggestions']);
    } catch (e) {
      throw Exception('Error al sugerir horarios óptimos: $e');
    }
  }

  /// Obtiene sugerencias de horarios óptimos con explicación
  Future<Map<String, dynamic>> executeWithExplanation({
    required String activityCategory,
    required List<Activity> pastActivities,
    required DateTime targetDate,
  }) async {
    try {
      return await _apiService.suggestOptimalTime(
        activityCategory: activityCategory,
        pastActivities: pastActivities,
        targetDate: targetDate,
      );
    } catch (e) {
      throw Exception('Error al sugerir horarios óptimos: $e');
    }
  }
}
