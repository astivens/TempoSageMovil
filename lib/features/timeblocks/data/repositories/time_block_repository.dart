import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/time_block_model.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/local_storage.dart';

/// Excepción para el repositorio de bloques de tiempo
class RepositoryException implements Exception {
  final String message;
  final dynamic originalError;

  RepositoryException({required this.message, this.originalError});

  @override
  String toString() => 'RepositoryException: $message';
}

/// Repositorio que maneja el acceso y persistencia de bloques de tiempo (TimeBlock).
///
/// Responsabilidades:
/// - Almacenar bloques de tiempo en la base de datos local (Hive)
/// - Recuperar bloques de tiempo por fecha, ID u otros criterios
/// - Actualizar o eliminar bloques de tiempo existentes
/// - Realizar cálculos sobre colecciones de bloques (duración total, etc)
class TimeBlockRepository {
  static const String _boxName = 'timeblocks';
  final Logger _logger = Logger.instance;

  /// Obtiene la caja (box) de Hive para timeblocks
  Future<Box<TimeBlockModel>> _getBox() async {
    try {
      return await LocalStorage.getBox<TimeBlockModel>(_boxName);
    } catch (e) {
      ErrorHandler.logError('Error al abrir box de timeblocks', e, null);
      throw RepositoryException(
          message: 'Error al acceder a los datos de bloques de tiempo',
          originalError: e);
    }
  }

  /// Inicializa el repositorio, asegurando que la caja de Hive esté abierta.
  Future<void> init() async {
    try {
      await _getBox();
      _logger.i('Repositorio de timeblocks inicializado correctamente',
          tag: 'TimeBlockRepo');
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
        _logger.d(
            'Buscando timeblocks para fecha: ${normalizedDate.toIso8601String()}',
            tag: 'TimeBlockRepo');
        _logger.d('Total timeblocks en base de datos: ${box.values.length}',
            tag: 'TimeBlockRepo');
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
          _logger.d('Coincidencia: ${timeBlock.title} - ${timeBlock.startTime}',
              tag: 'TimeBlockRepo');
        }

        return matches;
      }).toList();

      if (debugMode) {
        _logger.d('Encontrados ${timeBlocks.length} timeblocks para la fecha',
            tag: 'TimeBlockRepo');
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

  /// Verifica si ya existe un bloque de tiempo similar.
  ///
  /// Comprueba si ya existe un time block con el mismo título para la misma fecha
  /// y con horas de inicio y fin cercanas.
  ///
  /// Retorna `true` si existe un duplicado potencial.
  Future<bool> isDuplicate(TimeBlockModel timeBlock) async {
    try {
      final date = DateTime(
        timeBlock.startTime.year,
        timeBlock.startTime.month,
        timeBlock.startTime.day,
      );

      final existingBlocks = await getTimeBlocksByDate(date);

      for (final existing in existingBlocks) {
        // Si no es el mismo objeto pero tiene el mismo título
        if (existing.id != timeBlock.id && existing.title == timeBlock.title) {
          // Y los tiempos son similares (dentro de un rango de 15 minutos)
          final startDiff =
              (existing.startTime.difference(timeBlock.startTime).inMinutes)
                  .abs();
          final endDiff =
              (existing.endTime.difference(timeBlock.endTime).inMinutes).abs();

          if (startDiff < 15 && endDiff < 15) {
            _logger.w('Posible duplicado detectado: ${timeBlock.title}',
                tag: 'TimeBlockRepo');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      ErrorHandler.logError(
          'Error al verificar duplicado de timeblock', e, null);
      return false; // En caso de error, permitimos la operación
    }
  }

  /// Añade un nuevo bloque de tiempo a la base de datos.
  ///
  /// [timeBlock] El bloque de tiempo a guardar.
  Future<void> addTimeBlock(TimeBlockModel timeBlock) async {
    try {
      // Verificar si es un duplicado potencial
      final duplicate = await isDuplicate(timeBlock);
      if (duplicate) {
        _logger.w('Evitando guardar un timeblock duplicado: ${timeBlock.title}',
            tag: 'TimeBlockRepo');
        return; // No guardar si es un duplicado
      }

      _logger.i('Guardando timeblock: ${timeBlock.title}',
          tag: 'TimeBlockRepo');
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
      _logger.i('Actualizando timeblock: ${timeBlock.title}',
          tag: 'TimeBlockRepo');
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
      _logger.i('Eliminado timeblock con ID: $id', tag: 'TimeBlockRepo');
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

      _logger.i(
          'Eliminados ${blocks.length} timeblocks para la fecha ${date.toIso8601String()}',
          tag: 'TimeBlockRepo');
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
