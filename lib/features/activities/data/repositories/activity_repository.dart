import 'package:flutter/material.dart';
import '../../../../core/services/service_locator.dart';
import '../models/activity_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';
import '../../../../core/services/local_storage.dart';

class ActivityRepositoryException implements Exception {
  final String message;
  ActivityRepositoryException(this.message);

  @override
  String toString() => 'ActivityRepositoryException: $message';
}

class ActivityRepository {
  static const String _boxName = 'activities';
  final TimeBlockRepository _timeBlockRepository;

  ActivityRepository({
    required TimeBlockRepository timeBlockRepository,
  }) : _timeBlockRepository = timeBlockRepository;

  Future<List<ActivityModel>> _getActivities() async {
    try {
      return await LocalStorage.getAllData<ActivityModel>(_boxName);
    } catch (e) {
      throw ActivityRepositoryException('Error al obtener actividades: $e');
    }
  }

  Future<void> init() async {
    try {
      await _getActivities();
      debugPrint('Repositorio de actividades inicializado');
    } catch (e) {
      debugPrint('Error inicializando repositorio de actividades: $e');
      throw ActivityRepositoryException(
          'Error inicializando repositorio de actividades: $e');
    }
  }

  Future<List<ActivityModel>> getAllActivities() async {
    try {
      return await _getActivities();
    } catch (e) {
      debugPrint('Error al obtener todas las actividades: $e');
      throw ActivityRepositoryException(
          'Error al obtener todas las actividades: $e');
    }
  }

  Future<List<ActivityModel>> getActivitiesByDate(DateTime date) async {
    try {
      final activities = await _getActivities();
      return activities.where((activity) {
        return activity.startTime.year == date.year &&
            activity.startTime.month == date.month &&
            activity.startTime.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener actividades por fecha: $e');
      throw ActivityRepositoryException(
          'Error al obtener actividades por fecha: $e');
    }
  }

  Future<ActivityModel?> getActivity(String id) async {
    try {
      if (id.isEmpty) {
        throw ActivityRepositoryException('El ID no puede estar vacío');
      }

      final activity = await LocalStorage.getData<ActivityModel>(_boxName, id);
      return activity;
    } catch (e) {
      debugPrint('Error al obtener actividad: $e');
      throw ActivityRepositoryException('Error al obtener actividad: $e');
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    try {
      if (activity.title.isEmpty) {
        throw ActivityRepositoryException('El título no puede estar vacío');
      }

      debugPrint('Agregando actividad: ${activity.title}');
      await LocalStorage.saveData<ActivityModel>(
          _boxName, activity.id, activity);
      await _syncWithTimeBlock(activity);
    } catch (e) {
      debugPrint('Error al agregar actividad: $e');
      throw ActivityRepositoryException('Error al agregar actividad: $e');
    }
  }

  Future<void> updateActivity(ActivityModel activity) async {
    try {
      if (activity.title.isEmpty) {
        throw ActivityRepositoryException('El título no puede estar vacío');
      }

      debugPrint('Actualizando actividad: ${activity.title}');
      await LocalStorage.saveData<ActivityModel>(
          _boxName, activity.id, activity);
      await _syncWithTimeBlock(activity);
    } catch (e) {
      debugPrint('Error al actualizar actividad: $e');
      throw ActivityRepositoryException('Error al actualizar actividad: $e');
    }
  }

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
        debugPrint('TimeBlock sincronizado con la actividad');
      } else {
        await ServiceLocator.instance.activityToTimeBlockService
            .convertSingleActivityToTimeBlock(activity);
        debugPrint('Nuevo TimeBlock creado para la actividad');
      }
    } catch (e) {
      debugPrint('Error al sincronizar con TimeBlock: $e');
      // No lanzamos la excepción aquí para no interrumpir la operación principal
    }
  }

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
      debugPrint('Error al cambiar estado de actividad: $e');
      throw ActivityRepositoryException(
          'Error al cambiar estado de actividad: $e');
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      if (id.isEmpty) {
        throw ActivityRepositoryException('El ID no puede estar vacío');
      }

      await LocalStorage.deleteData(_boxName, id);
    } catch (e) {
      debugPrint('Error eliminando actividad: $e');
      throw ActivityRepositoryException('Error eliminando actividad: $e');
    }
  }
}
