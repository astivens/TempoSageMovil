import '../../../../core/utils/logger.dart';
import '../../../../core/services/service_locator.dart';
import '../models/activity_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';
import '../../../../core/services/local_storage.dart';

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
      _validateActivity(activity);

      _logger.d('Agregando actividad: ${activity.title}', tag: 'ActivityRepo');
      await LocalStorage.saveData<ActivityModel>(
          _boxName, activity.id, activity);
      await _syncWithTimeBlock(activity);

      // Programar notificación si es necesario
      if (activity.sendReminder) {
        await ServiceLocator.instance.activityNotificationService
            .scheduleActivityNotification(activity);
      }
    } catch (e) {
      _logger.e('Error al agregar actividad', tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException('Error al agregar actividad: $e');
    }
  }

  /// Actualiza una actividad existente
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      _validateActivity(activity);

      _logger.d('Actualizando actividad: ${activity.title}',
          tag: 'ActivityRepo');
      await LocalStorage.saveData<ActivityModel>(
          _boxName, activity.id, activity);
      await _syncWithTimeBlock(activity);

      // Actualizar notificación
      await ServiceLocator.instance.activityNotificationService
          .updateActivityNotification(activity);
    } catch (e) {
      _logger.e('Error al actualizar actividad', tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException('Error al actualizar actividad: $e');
    }
  }

  /// Valida una actividad
  void _validateActivity(ActivityModel activity) {
    if (activity.title.isEmpty) {
      throw ActivityRepositoryException('El título no puede estar vacío');
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

      final activity = await getActivity(id);
      if (activity == null) {
        throw ActivityRepositoryException('Actividad no encontrada');
      }

      await LocalStorage.deleteData(_boxName, id);

      // Cancelar notificación si existía
      await ServiceLocator.instance.activityNotificationService
          .cancelActivityNotification(id);

      _logger.d('Actividad eliminada: $id', tag: 'ActivityRepo');
    } catch (e) {
      _logger.e('Error al eliminar actividad', tag: 'ActivityRepo', error: e);
      throw ActivityRepositoryException('Error al eliminar actividad: $e');
    }
  }
}
