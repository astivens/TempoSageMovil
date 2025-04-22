import 'package:flutter/material.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/habit_repository.dart';
import '../../../timeblocks/data/models/time_block_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';

class HabitToTimeBlockService {
  final HabitRepository _habitRepository;
  final TimeBlockRepository _timeBlockRepository;

  HabitToTimeBlockService({
    required HabitRepository habitRepository,
    required TimeBlockRepository timeBlockRepository,
  })  : _habitRepository = habitRepository,
        _timeBlockRepository = timeBlockRepository;

  Future<TimeBlockModel?> convertSingleHabitToTimeBlock(
      HabitModel habit) async {
    debugPrint('Convirtiendo hábito individual: ${habit.title}');

    final startTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      habit.time.hour,
      habit.time.minute,
    );

    final endTime = startTime.add(const Duration(minutes: 30));

    final timeBlock = TimeBlockModel.create(
      title: habit.title,
      description: habit.description,
      startTime: startTime,
      endTime: endTime,
      category: habit.category,
      isFocusTime: true,
      color: _getCategoryColor(habit.category),
      isCompleted: habit.isCompleted,
    );

    // Verificar si ya existe un timeblock para este hábito
    final existingTimeBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(startTime);
    final existingBlock = existingTimeBlocks
        .where((block) =>
            block.title == habit.title &&
            block.startTime.hour == startTime.hour &&
            block.startTime.minute == startTime.minute)
        .firstOrNull;

    if (existingBlock != null) {
      debugPrint('TimeBlock ya existe, actualizando...');
      await _timeBlockRepository.updateTimeBlock(timeBlock);
      return existingBlock;
    } else {
      debugPrint('Creando nuevo TimeBlock...');
      await _timeBlockRepository.addTimeBlock(timeBlock);
      return timeBlock;
    }
  }

  Future<List<TimeBlockModel>> convertHabitsToTimeBlocks(DateTime date) async {
    debugPrint('Iniciando conversión para fecha: ${date.toString()}');

    final habits = await _habitRepository.getHabitsForDate(date);
    debugPrint('Hábitos encontrados: ${habits.length}');

    final timeBlocks = <TimeBlockModel>[];

    for (final habit in habits) {
      final timeBlock = await convertSingleHabitToTimeBlock(habit);
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
      case 'trabajo':
        return '#7AA2F7'; // Blue
      case 'personal':
        return '#9ECE6A'; // Green
      case 'estudio':
        return '#9D7CD8'; // Purple
      case 'otro':
        return '#E0AF68'; // Yellow
      default:
        return '#9D7CD8'; // Default purple
    }
  }

  Future<void> syncTimeBlocksForHabit(HabitModel habit) async {
    debugPrint('Sincronizando timeblocks para hábito: ${habit.title}');

    // Obtener todos los timeblocks del día
    final startTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      habit.time.hour,
      habit.time.minute,
    );

    final timeBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(startTime);

    // Encontrar el timeblock correspondiente
    final existingBlock = timeBlocks.firstWhere(
      (block) =>
          block.title == habit.title &&
          block.startTime.hour == startTime.hour &&
          block.startTime.minute == startTime.minute,
      orElse: () => TimeBlockModel.create(
        title: '',
        description: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        color: '',
      ),
    );

    if (existingBlock.title.isNotEmpty) {
      // Actualizar el timeblock existente
      final updatedTimeBlock = TimeBlockModel.create(
        title: habit.title,
        description: habit.description,
        startTime: startTime,
        endTime: startTime.add(const Duration(minutes: 30)),
        category: habit.category,
        isFocusTime: true,
        color: _getCategoryColor(habit.category),
        isCompleted: habit.isCompleted,
      );
      await _timeBlockRepository.updateTimeBlock(updatedTimeBlock);
      debugPrint('TimeBlock actualizado para hábito: ${habit.title}');
    }
  }

  Future<void> deleteTimeBlocksForHabit(HabitModel habit) async {
    debugPrint('Eliminando timeblocks para hábito: ${habit.title}');

    final startTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      habit.time.hour,
      habit.time.minute,
    );

    final timeBlocks =
        await _timeBlockRepository.getTimeBlocksByDate(startTime);

    // Encontrar y eliminar el timeblock correspondiente
    final existingBlock = timeBlocks.firstWhere(
      (block) =>
          block.title == habit.title &&
          block.startTime.hour == startTime.hour &&
          block.startTime.minute == startTime.minute,
      orElse: () => TimeBlockModel.create(
        title: '',
        description: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        color: '',
      ),
    );

    if (existingBlock.title.isNotEmpty) {
      await _timeBlockRepository.deleteTimeBlock(existingBlock.id);
      debugPrint('TimeBlock eliminado para hábito: ${habit.title}');
    }
  }
}
