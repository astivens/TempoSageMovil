import 'package:device_calendar/device_calendar.dart';
import '../data/models/productive_block.dart';

/// Representa un rango ocupado en el calendario.
class BusySlot {
  final DateTime start;
  final DateTime end;
  BusySlot(this.start, this.end);
}

class ScheduleRuleService {
  final DeviceCalendarPlugin _calendarPlugin;
  final List<ProductiveBlock> top3Blocks;
  final List<String> calendarIds;

  ScheduleRuleService({
    required this.top3Blocks,
    required this.calendarIds,
    DeviceCalendarPlugin? calendarPlugin,
  }) : _calendarPlugin = calendarPlugin ?? DeviceCalendarPlugin();

  /// Obtiene los rangos de tiempo ocupados para [day] en los calendarios seleccionados.
  Future<List<BusySlot>> getBusySlots(DateTime day) async {
    // Solicitar permisos si hace falta
    final perm = await _calendarPlugin.hasPermissions();
    if (!(perm.isSuccess && perm.data == true)) {
      await _calendarPlugin.requestPermissions();
    }
    final busySlots = <BusySlot>[];
    final start = DateTime(day.year, day.month, day.day, 0, 0);
    final end = DateTime(day.year, day.month, day.day, 23, 59);
    for (final calId in calendarIds) {
      final result = await _calendarPlugin.retrieveEvents(
        calId,
        RetrieveEventsParams(
          startDate: start,
          endDate: end,
        ),
      );
      if (result.isSuccess && result.data != null) {
        for (final event in result.data!) {
          if (event.start != null && event.end != null) {
            busySlots.add(BusySlot(event.start!, event.end!));
          }
        }
      }
    }
    return busySlots;
  }

  bool _isBlockFree(List<BusySlot> busySlots, DateTime day, int hour) {
    final blockStart = DateTime(day.year, day.month, day.day, hour);
    final blockEnd = blockStart.add(const Duration(hours: 1));
    for (final slot in busySlots) {
      if (blockStart.isBefore(slot.end) && slot.start.isBefore(blockEnd)) {
        return false;
      }
    }
    return true;
  }

  DateTime _nextDateForWeekday(DateTime referenceDate, int targetWeekday) {
    // Dart weekday: 1 = lunes ... 7 = domingo; queremos 0-6
    final current = referenceDate.weekday - 1;
    final diff = (targetWeekday - current) % 7;
    return referenceDate.add(Duration(days: diff));
  }

  /// Sugiere un bloque productivo desde Top3 según reglas híbridas.
  Future<ProductiveBlock?> suggestBlock({
    required DateTime referenceDate,
    required int priority,
    required double energyLevel,
    required double moodLevel,
    required String predictedCategory,
  }) async {
    final busySlots = await getBusySlots(referenceDate);
    for (final block in top3Blocks) {
      final candidateDay = _nextDateForWeekday(referenceDate, block.weekday);
      if (candidateDay.isBefore(referenceDate)) continue;
      if (!_isBlockFree(busySlots, candidateDay, block.hour)) continue;
      // Reglas adicionales
      if (priority >= 4) return block;
      if (predictedCategory == 'Formacion' && moodLevel < 0.4) continue;
      if (energyLevel < 0.3 && block.rate < 0.8) continue;
      return block;
    }
    return null;
  }
}
