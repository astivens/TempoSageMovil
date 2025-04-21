import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../../timeblocks/data/models/time_block_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';

class ActivityToTimeBlockService {
  final ActivityRepository _activityRepository;
  final TimeBlockRepository _timeBlockRepository;

  ActivityToTimeBlockService({
    required ActivityRepository activityRepository,
    required TimeBlockRepository timeBlockRepository,
  })  : _activityRepository = activityRepository,
        _timeBlockRepository = timeBlockRepository;

  Future<TimeBlockModel?> convertSingleActivityToTimeBlock(
      ActivityModel activity) async {
    debugPrint('Convirtiendo actividad individual: ${activity.title}');

    final timeBlock = TimeBlockModel.create(
      title: activity.title,
      description: activity.description,
      startTime: activity.startTime,
      endTime: activity.endTime,
      category: activity.category,
      isFocusTime: activity.priority == 'High',
      color: _getCategoryColor(activity.category),
      isCompleted: activity.isCompleted,
    );

    // Verificar si ya existe un timeblock para esta actividad
    final existingTimeBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(activity.startTime);
    final existingBlock = existingTimeBlocks
        .where((block) =>
            block.title == activity.title &&
            block.startTime == activity.startTime &&
            block.endTime == activity.endTime)
        .firstOrNull;

    if (existingBlock != null) {
      debugPrint('TimeBlock ya existe, actualizando...');
      await _timeBlockRepository.updateTimeBlock(timeBlock);
    } else {
      debugPrint('Creando nuevo TimeBlock...');
      await _timeBlockRepository.addTimeBlock(timeBlock);
    }

    return timeBlock;
  }

  Future<List<TimeBlockModel>> convertActivitiesToTimeBlocks(
      DateTime date) async {
    debugPrint('Iniciando conversión para fecha: ${date.toString()}');

    final activities = await _activityRepository.getActivitiesByDate(date);
    debugPrint('Actividades encontradas: ${activities.length}');

    final timeBlocks = <TimeBlockModel>[];

    for (final activity in activities) {
      final timeBlock = await convertSingleActivityToTimeBlock(activity);
      if (timeBlock != null) {
        timeBlocks.add(timeBlock);
      }
    }

    debugPrint(
        'Conversión completada. TimeBlocks creados: ${timeBlocks.length}');
    return timeBlocks;
  }

  String _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return '#7AA2F7'; // Blue
      case 'study':
        return '#9ECE6A'; // Green
      case 'personal':
        return '#9D7CD8'; // Purple
      case 'other':
        return '#E0AF68'; // Yellow
      default:
        return '#9D7CD8'; // Default purple
    }
  }
}
