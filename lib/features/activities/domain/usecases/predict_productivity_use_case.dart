import 'package:temposage/features/activities/domain/entities/activity.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

/// Caso de uso para obtener predicciones de productividad
class PredictProductivityUseCase {
  PredictProductivityUseCase();

  /// Ejecuta la predicción y retorna solo el valor numérico
  Future<double> execute({
    required List<Activity> activities,
    required List<Habit> habits,
    required DateTime targetDate,
  }) async {
    try {
      // Implementación local de predicción de productividad
      // Aquí se podría implementar la lógica de ML local
      return 0.8; // Valor de ejemplo
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
      final prediction = await execute(
        activities: activities,
        habits: habits,
        targetDate: targetDate,
      );

      return {
        'prediction': prediction,
        'explanation':
            'Esta predicción se basa en tu historial de actividades y hábitos.',
      };
    } catch (e) {
      throw Exception('Error al predecir productividad: $e');
    }
  }
}
