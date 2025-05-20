import '../../../../core/utils/logger.dart';
import '../../../../core/services/service_locator.dart';
import '../models/activity_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';
import '../../../../core/services/local_storage.dart';
import 'package:flutter/foundation.dart';

/// Excepción específica para el repositorio de actividades
class ActivityRepositoryException implements Exception {
  final String message;
  ActivityRepositoryException(this.message);

  @override
  String toString() => 'ActivityRepositoryException: $message';
}

/// Repositorio para gestionar las actividades
///
/// Responsable de:
/// - Almacenar y recuperar actividades
/// - Sincronizar actividades con bloques de tiempo
/// - Gestionar el estado de las actividades
class ActivityRepository {
  static const String _boxName = 'activities';
  final TimeBlockRepository _timeBlockRepository;
  final Logger _logger = Logger.instance;
  final List<ActivityModel> _activities = [];

  ActivityRepository({
    required TimeBlockRepository timeBlockRepository,
  }) : _timeBlockRepository = timeBlockRepository;

  /// Obtiene todas las actividades del almacenamiento local
  Future<List<ActivityModel>> _getActivities() async {
    try {
      return await LocalStorage.getAllData<ActivityModel>(_boxName);
    } catch (e) {
      throw ActivityRepositoryException('Error al obtener actividades: $e');
    }
  }

  /// Inicializa el repositorio
  Future<void> init() async {
    try {
      await _getActivities();
      _logger.i('Repositorio de actividades inicializado', tag: 'ActivityRepo');
    } catch (e) {
      _logger.e('Error inicializando repositorio de actividades',
          tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException(
          'Error inicializando repositorio de actividades: $e');
    }
  }

  /// Obtiene todas las actividades
  Future<List<ActivityModel>> getAllActivities() async {
    try {
      return await _getActivities();
    } catch (e) {
      _logger.e('Error al obtener todas las actividades',
          tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException(
          'Error al obtener todas las actividades: $e');
    }
  }

  /// Obtiene las actividades para una fecha específica
  Future<List<ActivityModel>> getActivitiesByDate(DateTime date) async {
    try {
      final activities = await _getActivities();
      return activities.where((activity) {
        return activity.startTime.year == date.year &&
            activity.startTime.month == date.month &&
            activity.startTime.day == date.day;
      }).toList();
    } catch (e) {
      _logger.e('Error al obtener actividades por fecha',
          tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException(
          'Error al obtener actividades por fecha: $e');
    }
  }

  /// Obtiene una actividad específica por su ID
  Future<ActivityModel?> getActivity(String id) async {
    try {
      if (id.isEmpty) {
        throw ActivityRepositoryException('El ID no puede estar vacío');
      }

      final activity = await LocalStorage.getData<ActivityModel>(_boxName, id);
      return activity;
    } catch (e) {
      _logger.e('Error al obtener actividad', tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException('Error al obtener actividad: $e');
    }
  }

  /// Agrega una nueva actividad
  Future<void> addActivity(ActivityModel activity) async {
    try {
      _activities.add(activity);
      debugPrint('Actividad agregada: ${activity.title}');
      await _syncWithTimeBlock(activity);

      // Programar notificación si es necesario
      if (activity.sendReminder) {
        await ServiceLocator.instance.activityNotificationService
            .scheduleActivityNotification(activity);
      }
    } catch (e) {
      debugPrint('Error al agregar actividad: $e');
      rethrow;
    }
  }

  /// Actualiza una actividad existente
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        debugPrint('Actividad actualizada: ${activity.title}');
        await _syncWithTimeBlock(activity);

        // Actualizar notificación
        await ServiceLocator.instance.activityNotificationService
            .updateActivityNotification(activity);
      } else {
        throw Exception('Actividad no encontrada');
      }
    } catch (e) {
      debugPrint('Error al actualizar actividad: $e');
      rethrow;
    }
  }

  /// Sincroniza una actividad con su correspondiente bloque de tiempo
  Future<void> _syncWithTimeBlock(ActivityModel activity) async {
    try {
      final timeBlocks =
          await _timeBlockRepository.getTimeBlocksByDate(activity.startTime);
      final matchingTimeBlocks = timeBlocks
          .where(
            (block) =>
                block.title == activity.title &&
                block.startTime == activity.startTime,
          )
          .toList();

      if (matchingTimeBlocks.isNotEmpty) {
        final timeBlock = matchingTimeBlocks.first;
        final updatedTimeBlock = timeBlock.copyWith(
          isCompleted: activity.isCompleted,
          title: activity.title,
          description: activity.description,
          startTime: activity.startTime,
          endTime: activity.endTime,
          category: activity.category,
        );
        await _timeBlockRepository.updateTimeBlock(updatedTimeBlock);
        _logger.d('TimeBlock sincronizado con la actividad',
            tag: 'ActivityRepo');
      } else {
        await ServiceLocator.instance.activityToTimeBlockService
            .convertSingleActivityToTimeBlock(activity);
        _logger.d('Nuevo TimeBlock creado para la actividad',
            tag: 'ActivityRepo');
      }
    } catch (e) {
      _logger.w('Error al sincronizar con TimeBlock: $e', tag: 'ActivityRepo');
      // No lanzamos la excepción aquí para no interrumpir la operación principal
    }
  }

  /// Cambia el estado de completado de una actividad
  Future<void> toggleActivityCompletion(String id) async {
    try {
      if (id.isEmpty) {
        throw ActivityRepositoryException('El ID no puede estar vacío');
      }

      final activity = await getActivity(id);
      if (activity == null) {
        throw ActivityRepositoryException('Actividad no encontrada');
      }

      final updatedActivity = activity.copyWith(
        isCompleted: !activity.isCompleted,
      );
      await updateActivity(updatedActivity);
    } catch (e) {
      _logger.e('Error al cambiar estado de actividad',
          tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException(
          'Error al cambiar estado de actividad: $e');
    }
  }

  /// Elimina una actividad
  Future<void> deleteActivity(String id) async {
    try {
      if (id.isEmpty) {
        throw ActivityRepositoryException('El ID no puede estar vacío');
      }

      final index = _activities.indexWhere((a) => a.id == id);
      if (index != -1) {
        final activity = _activities.removeAt(index);
        debugPrint('Actividad eliminada: ${activity.title}');

        // Cancelar notificación si existía
        await ServiceLocator.instance.activityNotificationService
            .cancelActivityNotification(id);
      } else {
        throw Exception('Actividad no encontrada');
      }
    } catch (e) {
      debugPrint('Error al eliminar actividad: $e');
      rethrow;
    }
  }
}
