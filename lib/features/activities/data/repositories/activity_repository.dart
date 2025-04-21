import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../../core/services/service_locator.dart';
import '../models/activity_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';

class ActivityRepository {
  static const String _boxName = 'activities';
  final TimeBlockRepository _timeBlockRepository =
      ServiceLocator.instance.timeBlockRepository;

  Future<Box<ActivityModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<ActivityModel>(_boxName);
    }
    return Hive.box<ActivityModel>(_boxName);
  }

  Future<void> init() async {
    await _getBox();
  }

  Future<List<ActivityModel>> getAllActivities() async {
    try {
      final box = await _getBox();
      return box.values.toList();
    } catch (e) {
      debugPrint('Error al obtener todas las actividades: $e');
      return [];
    }
  }

  Future<List<ActivityModel>> getActivitiesByDate(DateTime date) async {
    try {
      final box = await _getBox();
      final activities = box.values.where((activity) {
        return activity.startTime.year == date.year &&
            activity.startTime.month == date.month &&
            activity.startTime.day == date.day;
      }).toList();
      return activities;
    } catch (e) {
      debugPrint('Error al obtener actividades por fecha: $e');
      return [];
    }
  }

  Future<ActivityModel?> getActivity(String id) async {
    try {
      final box = await _getBox();
      return box.get(id);
    } catch (e) {
      debugPrint('Error al obtener actividad: $e');
      return null;
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    try {
      debugPrint('Agregando actividad: ${activity.title}');
      final box = await _getBox();
      await box.put(activity.id, activity);

      // Convertir solo la nueva actividad a timeblock
      try {
        await ServiceLocator.instance.activityToTimeBlockService
            .convertSingleActivityToTimeBlock(activity);
        debugPrint('Actividad convertida a timeblock automáticamente');
      } catch (e) {
        debugPrint('Error al convertir actividad a timeblock: $e');
      }
    } catch (e) {
      debugPrint('Error al agregar actividad: $e');
      rethrow;
    }
  }

  Future<void> updateActivity(ActivityModel activity) async {
    try {
      debugPrint('Actualizando actividad: ${activity.title}');
      final box = await _getBox();
      await box.put(activity.id, activity);

      // Actualizar el timeblock correspondiente
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
          debugPrint(
              'TimeBlock actualizado para reflejar cambios en la actividad');
        }
      } catch (e) {
        debugPrint('Error al actualizar timeblock: $e');
      }
    } catch (e) {
      debugPrint('Error al actualizar actividad: $e');
      rethrow;
    }
  }

  Future<void> toggleActivityCompletion(String id) async {
    try {
      final activity = await getActivity(id);
      if (activity != null) {
        final updatedActivity = activity.copyWith(
          isCompleted: !activity.isCompleted,
        );
        await updateActivity(updatedActivity);
      }
    } catch (e) {
      debugPrint('Error al cambiar estado de actividad: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      final box = await _getBox();
      final activity = await getActivity(id);

      if (activity != null) {
        // Primero eliminar el timeblock asociado
        try {
          final timeBlocks = await _timeBlockRepository
              .getTimeBlocksByDate(activity.startTime);
          final matchingTimeBlocks = timeBlocks
              .where(
                (block) =>
                    block.title == activity.title &&
                    block.startTime == activity.startTime,
              )
              .toList();

          for (final timeBlock in matchingTimeBlocks) {
            await _timeBlockRepository.deleteTimeBlock(timeBlock.id);
          }
        } catch (e) {
          debugPrint('Error al eliminar timeblocks asociados: $e');
        }

        // Luego eliminar la actividad
        await box.delete(id);
      }
    } catch (e) {
      debugPrint('Error al eliminar actividad: $e');
      rethrow;
    }
  }
}
