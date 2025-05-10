import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temposage/features/activities/domain/entities/activity.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

/// Servicio para realizar llamadas a la API de TempoSage
///
/// Proporciona métodos para obtener predicciones de productividad,
/// sugerencias de horarios y análisis de patrones.
class TempoSageApiService {
  final String baseUrl;

  TempoSageApiService({this.baseUrl = 'http://localhost:5000'});

  /// Verifica el estado de la API
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Convierte una actividad del modelo de la app al formato esperado por la API
  Map<String, dynamic> _mapActivityToApiFormat(Activity activity) {
    return {
      'startTime': activity.date.toIso8601String(),
      'endTime': activity.date
          .add(Duration(hours: 1))
          .toIso8601String(), // Asumimos 1 hora por defecto
      'category': activity.category,
      'isCompleted': activity.isCompleted,
    };
  }

  /// Convierte un hábito del modelo de la app al formato esperado por la API
  Map<String, dynamic> _mapHabitToApiFormat(Habit habit) {
    return {
      'category': habit.category,
      'date': habit.dateCreation.toIso8601String().split('T')[0],
      'completed': habit.isDone,
    };
  }

  /// Predice la productividad basada en actividades y hábitos
  Future<Map<String, dynamic>> predictProductivity({
    required List<Activity> activities,
    required List<Habit> habits,
    required DateTime targetDate,
  }) async {
    try {
      final body = jsonEncode({
        'activities':
            activities.map((a) => _mapActivityToApiFormat(a)).toList(),
        'habits': habits.map((h) => _mapHabitToApiFormat(h)).toList(),
        'target_date': targetDate.toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$baseUrl/predict/productivity/enhanced'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al predecir productividad: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  /// Sugiere horarios óptimos para una actividad específica
  Future<Map<String, dynamic>> suggestOptimalTime({
    required String activityCategory,
    required List<Activity> pastActivities,
    required DateTime targetDate,
  }) async {
    try {
      final body = jsonEncode({
        'activity_category': activityCategory,
        'past_activities':
            pastActivities.map((a) => _mapActivityToApiFormat(a)).toList(),
        'target_date': targetDate.toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$baseUrl/predict/optimal_time'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al sugerir horarios: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  /// Analiza patrones basados en actividades históricas
  Future<Map<String, dynamic>> analyzePatterns({
    required List<Activity> activities,
    int timePeriod = 30,
  }) async {
    try {
      final body = jsonEncode({
        'activities':
            activities.map((a) => _mapActivityToApiFormat(a)).toList(),
        'time_period': timePeriod,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/analyze/patterns'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al analizar patrones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }
}
