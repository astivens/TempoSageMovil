import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/time_block_model.dart';

class TimeBlockRepository {
  static const String _boxName = 'timeblocks';

  Future<Box<TimeBlockModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<TimeBlockModel>(_boxName);
    }
    return Hive.box<TimeBlockModel>(_boxName);
  }

  Future<void> init() async {
    await _getBox();
  }

  Future<List<TimeBlockModel>> getAllTimeBlocks() async {
    try {
      final box = await _getBox();
      return box.values.toList();
    } catch (e) {
      debugPrint('Error al obtener todos los timeblocks: $e');
      return [];
    }
  }

  Future<List<TimeBlockModel>> getTimeBlocksByDate(DateTime date) async {
    try {
      final box = await _getBox();
      final normalizedDate = DateTime(date.year, date.month, date.day);

      debugPrint('Cargando timeblocks para fecha normalizada: $normalizedDate');
      debugPrint('Timeblocks totales en box: ${box.values.length}');

      final timeBlocks = box.values.where((timeBlock) {
        // Normalizamos la fecha del timeblock (eliminando la hora)
        final blockDate = DateTime(
          timeBlock.startTime.year,
          timeBlock.startTime.month,
          timeBlock.startTime.day,
        );

        // Comparamos solo año, mes y día
        final matches = blockDate.year == normalizedDate.year &&
            blockDate.month == normalizedDate.month &&
            blockDate.day == normalizedDate.day;

        if (matches) {
          debugPrint(
              'TimeBlock coincide con la fecha: ${timeBlock.title} - ${timeBlock.startTime}');
        }

        return matches;
      }).toList();

      debugPrint('Timeblocks encontrados para la fecha: ${timeBlocks.length}');
      return timeBlocks;
    } catch (e) {
      debugPrint('Error al obtener timeblocks por fecha: $e');
      return [];
    }
  }

  Future<TimeBlockModel?> getTimeBlock(String id) async {
    try {
      final box = await _getBox();
      return box.get(id);
    } catch (e) {
      debugPrint('Error al obtener timeblock: $e');
      return null;
    }
  }

  Future<void> addTimeBlock(TimeBlockModel timeBlock) async {
    try {
      debugPrint('Agregando timeblock: ${timeBlock.title}');
      final box = await _getBox();
      await box.put(timeBlock.id, timeBlock);
    } catch (e) {
      debugPrint('Error al agregar timeblock: $e');
      rethrow;
    }
  }

  Future<void> updateTimeBlock(TimeBlockModel timeBlock) async {
    try {
      debugPrint('Actualizando timeblock: ${timeBlock.title}');
      final box = await _getBox();
      await box.put(timeBlock.id, timeBlock);
    } catch (e) {
      debugPrint('Error al actualizar timeblock: $e');
      rethrow;
    }
  }

  Future<void> deleteTimeBlock(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error al eliminar timeblock: $e');
      rethrow;
    }
  }

  Future<double> getTotalHoursForDate(DateTime date) async {
    try {
      final blocks = await getTimeBlocksByDate(date);
      final totalDuration = blocks.fold<Duration>(
        Duration.zero,
        (total, block) => total + block.duration,
      );
      return totalDuration.inMinutes / 60.0;
    } catch (e) {
      debugPrint('Error al calcular horas totales: $e');
      return 0.0;
    }
  }

  Future<double> getFocusTimeForDate(DateTime date) async {
    try {
      final blocks = await getTimeBlocksByDate(date);
      final focusBlocks = blocks.where((block) => block.isFocusTime);
      final totalDuration = focusBlocks.fold<Duration>(
        Duration.zero,
        (total, block) => total + block.duration,
      );
      return totalDuration.inMinutes / 60.0;
    } catch (e) {
      debugPrint('Error al calcular tiempo de enfoque: $e');
      return 0.0;
    }
  }
}
