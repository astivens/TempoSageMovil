import 'package:flutter/foundation.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/tempo_sage_api_service.dart';
import '../entities/activity.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';
import '../../data/repositories/activity_repository.dart';

/// Caso de uso para sugerir horarios óptimos para actividades
class SuggestOptimalTimeUseCase {
  final TempoSageApiService _apiService;
  final ActivityRepository _activityRepository;
  final TimeBlockRepository _timeBlockRepository;

  SuggestOptimalTimeUseCase({
    TempoSageApiService? apiService,
    ActivityRepository? activityRepository,
    TimeBlockRepository? timeBlockRepository,
  })  : _apiService = apiService ?? ServiceLocator.instance.tempoSageApiService,
        _activityRepository =
            activityRepository ?? ServiceLocator.instance.activityRepository,
        _timeBlockRepository =
            timeBlockRepository ?? ServiceLocator.instance.timeBlockRepository;

  /// Obtiene sugerencias de horarios óptimos para una categoría de actividad
  Future<List<Map<String, dynamic>>> execute({
    required String activityCategory,
    required List<Activity> pastActivities,
    required DateTime targetDate,
  }) async {
    try {
      // Primero intentamos usar la API
      try {
        final result = await _apiService.suggestOptimalTime(
          activityCategory: activityCategory,
          pastActivities: pastActivities,
          targetDate: targetDate,
        );

        // Extraer y devolver solo las sugerencias
        return List<Map<String, dynamic>>.from(result['suggestions']);
      } catch (e) {
        debugPrint(
            'Error al usar API para sugerencias: $e. Usando enfoque local.');
        // Si la API falla, usamos un enfoque local
        return _getLocalSuggestions(activityCategory, targetDate);
      }
    } catch (e) {
      throw Exception('Error al sugerir horarios óptimos: $e');
    }
  }

  /// Genera sugerencias locales basadas en los bloques de tiempo disponibles
  Future<List<Map<String, dynamic>>> _getLocalSuggestions(
      String category, DateTime targetDate) async {
    // Obtener actividades existentes para la fecha objetivo
    final existingActivities =
        await _activityRepository.getActivitiesByDate(targetDate);

    // Obtener bloques de tiempo existentes para la fecha objetivo
    final existingBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(targetDate);

    // Crear una lista de slots de tiempo ocupados (inicio y fin)
    final List<Map<String, DateTime>> occupiedSlots = [];

    // Agregar slots de actividades
    for (final activity in existingActivities) {
      occupiedSlots.add({
        'start': activity.startTime,
        'end': activity.endTime,
      });
    }

    // Agregar slots de bloques de tiempo
    for (final block in existingBlocks) {
      occupiedSlots.add({
        'start': block.startTime,
        'end': block.endTime,
      });
    }

    // Ordenar slots por hora de inicio
    occupiedSlots.sort((a, b) => a['start']!.compareTo(b['start']!));

    // Encontrar slots libres (mínimo 30 minutos)
    final List<Map<String, dynamic>> freeSlots = [];

    // Definir inicio y fin del día
    final dayStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      8, // 8:00 AM
      0,
    );

    final dayEnd = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      22, // 10:00 PM
      0,
    );

    // Si no hay slots ocupados, todo el día está libre
    if (occupiedSlots.isEmpty) {
      freeSlots.add({
        'startTime': dayStart.millisecondsSinceEpoch,
        'endTime': dayEnd.millisecondsSinceEpoch,
        'score': 1.0,
      });
      return freeSlots;
    }

    // Verificar si hay espacio libre antes del primer slot ocupado
    if (occupiedSlots.first['start']!.difference(dayStart).inMinutes >= 30) {
      freeSlots.add({
        'startTime': dayStart.millisecondsSinceEpoch,
        'endTime': occupiedSlots.first['start']!.millisecondsSinceEpoch,
        'score': 0.9,
      });
    }

    // Buscar espacios entre slots ocupados
    for (int i = 0; i < occupiedSlots.length - 1; i++) {
      final currentEnd = occupiedSlots[i]['end']!;
      final nextStart = occupiedSlots[i + 1]['start']!;

      final gap = nextStart.difference(currentEnd).inMinutes;

      if (gap >= 30) {
        freeSlots.add({
          'startTime': currentEnd.millisecondsSinceEpoch,
          'endTime': nextStart.millisecondsSinceEpoch,
          'score': 0.8,
        });
      }
    }

    // Verificar si hay espacio libre después del último slot ocupado
    if (dayEnd.difference(occupiedSlots.last['end']!).inMinutes >= 30) {
      freeSlots.add({
        'startTime': occupiedSlots.last['end']!.millisecondsSinceEpoch,
        'endTime': dayEnd.millisecondsSinceEpoch,
        'score': 0.7,
      });
    }

    // Si no se encontraron slots libres, sugerir uno después del día
    if (freeSlots.isEmpty) {
      final nextDay = targetDate.add(const Duration(days: 1));
      final nextDayStart = DateTime(
        nextDay.year,
        nextDay.month,
        nextDay.day,
        8, // 8:00 AM
        0,
      );

      final nextDayEnd = nextDayStart.add(const Duration(hours: 2));

      freeSlots.add({
        'startTime': nextDayStart.millisecondsSinceEpoch,
        'endTime': nextDayEnd.millisecondsSinceEpoch,
        'score': 0.5,
      });
    }

    return freeSlots;
  }

  /// Obtiene sugerencias de horarios óptimos con explicación
  Future<Map<String, dynamic>> executeWithExplanation({
    required String activityCategory,
    required List<Activity> pastActivities,
    required DateTime targetDate,
  }) async {
    try {
      final suggestions = await execute(
        activityCategory: activityCategory,
        pastActivities: pastActivities,
        targetDate: targetDate,
      );

      return {
        'suggestions': suggestions,
        'explanation':
            'Estas sugerencias se basan en tu historial de actividades y los espacios disponibles en tu agenda.',
      };
    } catch (e) {
      throw Exception('Error al sugerir horarios óptimos: $e');
    }
  }
}
