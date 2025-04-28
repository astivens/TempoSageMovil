import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/time_block_model.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/errors/app_exception.dart';

/// Repositorio que maneja el acceso y persistencia de bloques de tiempo (TimeBlock).
///
/// Responsabilidades:
/// - Almacenar bloques de tiempo en la base de datos local (Hive)
/// - Recuperar bloques de tiempo por fecha, ID u otros criterios
/// - Actualizar o eliminar bloques de tiempo existentes
/// - Realizar cálculos sobre colecciones de bloques (duración total, etc)
class TimeBlockRepository {
  static const String _boxName = 'timeblocks';

  /// Obtiene la referencia a la caja (box) de Hive para los bloques de tiempo.
  /// Si la caja no está abierta, la abre.
  ///
  /// Lanza [RepositoryException] si hay un error al acceder a la base de datos.
  Future<Box<TimeBlockModel>> _getBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<TimeBlockModel>(_boxName);
      }
      return Hive.box<TimeBlockModel>(_boxName);
    } catch (e) {
      ErrorHandler.logError('Error al abrir la caja de timeblocks', e, null);
      throw RepositoryException(
          message: 'Error al acceder a la base de datos de timeblocks',
          originalError: e);
    }
  }

  /// Inicializa el repositorio, asegurando que la caja de Hive esté abierta.
  Future<void> init() async {
    try {
      await _getBox();
      debugPrint('Repositorio de timeblocks inicializado correctamente');
    } catch (e) {
      ErrorHandler.logError(
          'Error al inicializar repositorio de timeblocks', e, null);
      throw RepositoryException(
          message: 'Error al inicializar repositorio de timeblocks',
          originalError: e);
    }
  }

  /// Obtiene todos los bloques de tiempo almacenados.
  ///
  /// Retorna una lista de [TimeBlockModel].
  Future<List<TimeBlockModel>> getAllTimeBlocks() async {
    try {
      final box = await _getBox();
      return box.values.toList();
    } catch (e) {
      ErrorHandler.logError('Error al obtener todos los timeblocks', e, null);
      throw RepositoryException(
          message: 'Error al recuperar los bloques de tiempo',
          originalError: e);
    }
  }

  /// Obtiene los bloques de tiempo para una fecha específica.
  ///
  /// [date] La fecha para la cual buscar bloques de tiempo.
  /// Retorna una lista de [TimeBlockModel] correspondientes a la fecha.
  Future<List<TimeBlockModel>> getTimeBlocksByDate(DateTime date) async {
    try {
      final box = await _getBox();
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (debugMode) {
        debugPrint(
            'Buscando timeblocks para fecha: ${normalizedDate.toIso8601String()}');
        debugPrint('Total timeblocks en base de datos: ${box.values.length}');
      }

      final timeBlocks = box.values.where((timeBlock) {
        // Normalizar la fecha del timeblock para comparar solo año, mes y día
        final blockDate = DateTime(
          timeBlock.startTime.year,
          timeBlock.startTime.month,
          timeBlock.startTime.day,
        );

        // Verificar coincidencia de fecha
        final matches = blockDate.year == normalizedDate.year &&
            blockDate.month == normalizedDate.month &&
            blockDate.day == normalizedDate.day;

        if (matches && debugMode) {
          debugPrint(
              'Coincidencia: ${timeBlock.title} - ${timeBlock.startTime}');
        }

        return matches;
      }).toList();

      if (debugMode) {
        debugPrint('Encontrados ${timeBlocks.length} timeblocks para la fecha');
      }

      return timeBlocks;
    } catch (e) {
      ErrorHandler.logError('Error al obtener timeblocks por fecha', e, null);
      throw RepositoryException(
          message: 'Error al recuperar bloques de tiempo por fecha',
          originalError: e);
    }
  }

  /// Obtiene un bloque de tiempo por su ID.
  ///
  /// [id] El identificador único del bloque de tiempo.
  /// Retorna el [TimeBlockModel] correspondiente, o `null` si no existe.
  Future<TimeBlockModel?> getTimeBlock(String id) async {
    try {
      final box = await _getBox();
      return box.get(id);
    } catch (e) {
      ErrorHandler.logError('Error al obtener timeblock con ID: $id', e, null);
      throw RepositoryException(
          message: 'Error al recuperar bloque de tiempo', originalError: e);
    }
  }

  /// Añade un nuevo bloque de tiempo a la base de datos.
  ///
  /// [timeBlock] El bloque de tiempo a guardar.
  Future<void> addTimeBlock(TimeBlockModel timeBlock) async {
    try {
      debugPrint('Guardando timeblock: ${timeBlock.title}');
      final box = await _getBox();
      await box.put(timeBlock.id, timeBlock);
    } catch (e) {
      ErrorHandler.logError(
          'Error al agregar timeblock: ${timeBlock.title}', e, null);
      throw RepositoryException(
          message: 'Error al guardar bloque de tiempo', originalError: e);
    }
  }

  /// Actualiza un bloque de tiempo existente.
  ///
  /// [timeBlock] El bloque de tiempo con las actualizaciones.
  Future<void> updateTimeBlock(TimeBlockModel timeBlock) async {
    try {
      debugPrint('Actualizando timeblock: ${timeBlock.title}');
      final box = await _getBox();
      await box.put(timeBlock.id, timeBlock);
    } catch (e) {
      ErrorHandler.logError(
          'Error al actualizar timeblock: ${timeBlock.title}', e, null);
      throw RepositoryException(
          message: 'Error al actualizar bloque de tiempo', originalError: e);
    }
  }

  /// Elimina un bloque de tiempo por su ID.
  ///
  /// [id] El identificador único del bloque de tiempo a eliminar.
  Future<void> deleteTimeBlock(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      debugPrint('Eliminado timeblock con ID: $id');
    } catch (e) {
      ErrorHandler.logError('Error al eliminar timeblock con ID: $id', e, null);
      throw RepositoryException(
          message: 'Error al eliminar bloque de tiempo', originalError: e);
    }
  }

  /// Calcula el total de horas planificadas para una fecha.
  ///
  /// [date] La fecha para la cual calcular las horas.
  /// Retorna el total de horas como [double].
  Future<double> getTotalHoursForDate(DateTime date) async {
    try {
      final blocks = await getTimeBlocksByDate(date);
      final totalDuration = blocks.fold<Duration>(
        Duration.zero,
        (total, block) => total + block.duration,
      );
      return totalDuration.inMinutes / 60.0;
    } catch (e) {
      ErrorHandler.logError(
          'Error al calcular horas totales para fecha', e, null);
      throw RepositoryException(
          message: 'Error al calcular horas totales', originalError: e);
    }
  }

  /// Calcula el tiempo de enfoque planificado para una fecha.
  ///
  /// [date] La fecha para la cual calcular el tiempo de enfoque.
  /// Retorna el total de horas de enfoque como [double].
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
      ErrorHandler.logError(
          'Error al calcular tiempo de enfoque para fecha', e, null);
      throw RepositoryException(
          message: 'Error al calcular tiempo de enfoque', originalError: e);
    }
  }

  /// Elimina todos los bloques de tiempo para una fecha específica.
  ///
  /// [date] La fecha para la cual eliminar los bloques.
  Future<void> deleteAllTimeBlocksForDate(DateTime date) async {
    try {
      final blocks = await getTimeBlocksByDate(date);
      final box = await _getBox();

      // Eliminar todos los bloques en una sola operación
      final deleteOperations = blocks.map((block) => box.delete(block.id));
      await Future.wait(deleteOperations);

      debugPrint(
          'Eliminados ${blocks.length} timeblocks para la fecha ${date.toIso8601String()}');
    } catch (e) {
      ErrorHandler.logError('Error al eliminar timeblocks para fecha', e, null);
      throw RepositoryException(
          message: 'Error al eliminar bloques de tiempo por fecha',
          originalError: e);
    }
  }

  /// Verifica si estamos en modo de depuración.
  bool get debugMode => !kReleaseMode;
}
