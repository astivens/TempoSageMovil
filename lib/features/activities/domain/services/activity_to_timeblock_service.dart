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
    debugPrint('🔄 Iniciando conversión para actividad: ${activity.title}');

    final timeBlock = TimeBlockModel.create(
      title: activity.title,
      description: _createActivityDescription(activity),
      startTime: activity.startTime,
      endTime: activity.endTime,
      category: activity.category,
      isFocusTime: activity.priority == 'High',
      color: _getCategoryColor(activity.category),
      isCompleted: activity.isCompleted,
    );

    // Verificar si ya existe un timeblock para esta actividad usando múltiples criterios
    final existingTimeBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(activity.startTime);

    final existingBlock = existingTimeBlocks.firstWhere(
      (block) => _isMatchingActivityTimeBlock(block, activity),
      orElse: () => TimeBlockModel.create(
        title: '',
        description: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        color: '#9D7CD8',
      ),
    );

    if (existingBlock.title.isNotEmpty) {
      debugPrint(
          '✅ TimeBlock ya existe para "${activity.title}", actualizando...');
      final updatedTimeBlock = existingBlock.copyWith(
        title: activity.title,
        description: _createActivityDescription(activity),
        startTime: activity.startTime,
        endTime: activity.endTime,
        category: activity.category,
        isFocusTime: activity.priority == 'High',
        color: _getCategoryColor(activity.category),
        isCompleted: activity.isCompleted,
      );
      await _timeBlockRepository.updateTimeBlock(updatedTimeBlock);
      return updatedTimeBlock;
    } else {
      debugPrint('🆕 Creando nuevo TimeBlock para "${activity.title}"...');
      await _timeBlockRepository.addTimeBlock(timeBlock);
      return timeBlock;
    }
  }

  Future<List<TimeBlockModel>> convertActivitiesToTimeBlocks(
      DateTime date) async {
    debugPrint('🔄 Iniciando conversión masiva para fecha: ${date.toString()}');

    final activities = await _activityRepository.getActivitiesByDate(date);
    debugPrint('📋 Actividades encontradas: ${activities.length}');

    if (activities.isEmpty) {
      debugPrint('📭 No hay actividades para convertir');
      return [];
    }

    // Obtener timeblocks existentes para evitar duplicados
    final existingTimeBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(date);
    debugPrint('⏰ TimeBlocks existentes: ${existingTimeBlocks.length}');

    final timeBlocks = <TimeBlockModel>[];
    int createdCount = 0;
    int updatedCount = 0;
    int skippedCount = 0;

    for (final activity in activities) {
      try {
        // Verificar si ya existe un timeblock para esta actividad
        final existingBlock = existingTimeBlocks.firstWhere(
          (block) => _isMatchingActivityTimeBlock(block, activity),
          orElse: () => TimeBlockModel.create(
            title: '',
            description: '',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            category: '',
            color: '#9D7CD8',
          ),
        );

        if (existingBlock.title.isNotEmpty) {
          // Ya existe, verificar si necesita actualización
          if (_needsUpdate(existingBlock, activity)) {
            final updatedBlock = existingBlock.copyWith(
              title: activity.title,
              description: _createActivityDescription(activity),
              startTime: activity.startTime,
              endTime: activity.endTime,
              category: activity.category,
              isFocusTime: activity.priority == 'High',
              color: _getCategoryColor(activity.category),
              isCompleted: activity.isCompleted,
            );
            await _timeBlockRepository.updateTimeBlock(updatedBlock);
            timeBlocks.add(updatedBlock);
            updatedCount++;
            debugPrint('🔄 Actualizado TimeBlock: "${activity.title}"');
          } else {
            timeBlocks.add(existingBlock);
            skippedCount++;
            debugPrint('⏭️ TimeBlock ya está actualizado: "${activity.title}"');
          }
        } else {
          // No existe, crear uno nuevo
          final timeBlock = await convertSingleActivityToTimeBlock(activity);
          if (timeBlock != null) {
            timeBlocks.add(timeBlock);
            createdCount++;
          }
        }
      } catch (e) {
        debugPrint('❌ Error procesando actividad "${activity.title}": $e');
      }
    }

    debugPrint('📊 Resumen conversión:');
    debugPrint('   🆕 Creados: $createdCount');
    debugPrint('   🔄 Actualizados: $updatedCount');
    debugPrint('   ⏭️ Omitidos: $skippedCount');
    debugPrint('   📦 Total: ${timeBlocks.length}');

    return timeBlocks;
  }

  /// Crea una descripción que incluye un identificador de la actividad
  String _createActivityDescription(ActivityModel activity) {
    String description = activity.description;
    const activityMarker = '[ACTIVITY_GENERATED]';

    if (!description.contains(activityMarker)) {
      description = description.isEmpty
          ? '$activityMarker ID: ${activity.id}'
          : '$description\n\n$activityMarker ID: ${activity.id}';
    }

    return description;
  }

  /// Verifica si un timeblock corresponde a una actividad específica
  bool _isMatchingActivityTimeBlock(
      TimeBlockModel timeBlock, ActivityModel activity) {
    // Criterios múltiples para identificar coincidencias:

    // 1. Verificar por ID en la descripción (más confiable)
    if (timeBlock.description.contains('[ACTIVITY_GENERATED]') &&
        timeBlock.description.contains('ID: ${activity.id}')) {
      return true;
    }

    // 2. Verificar por coincidencia exacta de tiempo y título
    if (timeBlock.title == activity.title &&
        timeBlock.startTime == activity.startTime &&
        timeBlock.endTime == activity.endTime) {
      return true;
    }

    // 3. Verificar timeblocks antiguos sin marcador pero con coincidencia exacta
    if (timeBlock.title == activity.title &&
        timeBlock.startTime.year == activity.startTime.year &&
        timeBlock.startTime.month == activity.startTime.month &&
        timeBlock.startTime.day == activity.startTime.day &&
        timeBlock.startTime.hour == activity.startTime.hour &&
        timeBlock.startTime.minute == activity.startTime.minute &&
        timeBlock.category == activity.category) {
      return true;
    }

    return false;
  }

  /// Verifica si un timeblock necesita ser actualizado
  bool _needsUpdate(TimeBlockModel timeBlock, ActivityModel activity) {
    return timeBlock.title != activity.title ||
        timeBlock.description != _createActivityDescription(activity) ||
        timeBlock.startTime != activity.startTime ||
        timeBlock.endTime != activity.endTime ||
        timeBlock.category != activity.category ||
        timeBlock.isCompleted != activity.isCompleted ||
        (activity.priority == 'High') != timeBlock.isFocusTime;
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
