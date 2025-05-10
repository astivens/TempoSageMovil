import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/core/services/tempo_sage_api_service.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';

/// Caso de uso para analizar patrones de actividades
class AnalyzePatternsUseCase {
  final TempoSageApiService _apiService;

  AnalyzePatternsUseCase({
    TempoSageApiService? apiService,
  }) : _apiService = apiService ?? ServiceLocator.instance.tempoSageApiService;

  /// Analiza patrones en las actividades durante un período específico
  Future<List<Map<String, dynamic>>> execute({
    required List<Activity> activities,
    int timePeriod = 30,
  }) async {
    try {
      final result = await _apiService.analyzePatterns(
        activities: activities,
        timePeriod: timePeriod,
      );

      // Extraer y devolver solo los patrones identificados
      return List<Map<String, dynamic>>.from(result['patterns']);
    } catch (e) {
      throw Exception('Error al analizar patrones: $e');
    }
  }

  /// Analiza patrones en las actividades y devuelve el resultado completo con explicación
  Future<Map<String, dynamic>> executeWithExplanation({
    required List<Activity> activities,
    int timePeriod = 30,
  }) async {
    try {
      return await _apiService.analyzePatterns(
        activities: activities,
        timePeriod: timePeriod,
      );
    } catch (e) {
      throw Exception('Error al analizar patrones: $e');
    }
  }
}
