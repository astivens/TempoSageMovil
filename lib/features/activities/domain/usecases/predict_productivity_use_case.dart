import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/core/services/tempo_sage_api_service.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

/// Caso de uso para obtener predicciones de productividad
class PredictProductivityUseCase {
  final TempoSageApiService _apiService;

  PredictProductivityUseCase({
    TempoSageApiService? apiService,
  }) : _apiService = apiService ?? ServiceLocator.instance.tempoSageApiService;

  /// Ejecuta la predicción y retorna solo el valor numérico
  Future<double> execute({
    required List<Activity> activities,
    required List<Habit> habits,
    required DateTime targetDate,
  }) async {
    try {
      final result = await _apiService.predictProductivity(
        activities: activities,
        habits: habits,
        targetDate: targetDate,
      );

      return result['prediction'] as double;
    } catch (e) {
      throw Exception('Error al predecir productividad: $e');
    }
  }

  /// Ejecuta la predicción y retorna la respuesta completa con explicación
  Future<Map<String, dynamic>> executeWithExplanation({
    required List<Activity> activities,
    required List<Habit> habits,
    required DateTime targetDate,
  }) async {
    try {
      return await _apiService.predictProductivity(
        activities: activities,
        habits: habits,
        targetDate: targetDate,
      );
    } catch (e) {
      throw Exception('Error al predecir productividad: $e');
    }
  }
}
