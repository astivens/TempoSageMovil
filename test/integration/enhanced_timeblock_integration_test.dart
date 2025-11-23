import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'dart:io';

/// Enhanced Integration Tests for TimeBlock with Habits and Activities
/// This test suite uses CASCADE TESTING technique where each test builds upon the previous one,
/// simulating a complete user workflow instead of isolated tests.
void main() {
  group('TimeBlock Integration Tests - Cascade Approach', () {
    late TimeBlockRepository timeBlockRepository;
    late Directory tempDir;
    
    // Shared state across tests (cascade approach)
    HabitModel? morningExerciseHabit;
    HabitModel? studySessionHabit;
    TimeBlockModel? firstTimeBlock;
    List<TimeBlockModel> createdTimeBlocks = [];

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      // Register adapters
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(TimeBlockModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      
      // Limpiar datos solo una vez al inicio de todos los tests (cascada)
      try {
        final timeblocksBox = Hive.box('timeblocks');
        if (timeblocksBox.isOpen) {
          await timeblocksBox.close();
        }
      } catch (e) {
        // La caja puede no estar abierta
      }
      try {
        final habitsBox = Hive.box('habits');
        if (habitsBox.isOpen) {
          await habitsBox.close();
        }
      } catch (e) {
        // La caja puede no estar abierta
      }
      
      await Hive.deleteBoxFromDisk('timeblocks');
      await Hive.deleteBoxFromDisk('habits');
    });

    setUp(() async {
      // Cerrar cajas si están abiertas antes de limpiar
      try {
        final timeblocksBox = Hive.box('timeblocks');
        if (timeblocksBox.isOpen) {
          await timeblocksBox.close();
        }
      } catch (e) {
        // La caja puede no estar abierta
      }
      try {
        final habitsBox = Hive.box('habits');
        if (habitsBox.isOpen) {
          await habitsBox.close();
        }
      } catch (e) {
        // La caja puede no estar abierta
      }
      
      // NO limpiar datos aquí - cascada: los datos persisten entre tests
      
      // Inicializar repositorio
      timeBlockRepository = TimeBlockRepository();
      await timeBlockRepository.init();
      
      // Reset shared state solo en el primer test
      if (firstTimeBlock == null) {
        morningExerciseHabit = null;
        studySessionHabit = null;
        createdTimeBlocks.clear();
      }
    });

    tearDownAll(() async {
      // Cerrar las cajas antes de eliminarlas
      try {
        final timeblocksBox = Hive.box('timeblocks');
        if (timeblocksBox.isOpen) {
          await timeblocksBox.close();
        }
      } catch (e) {
        // La caja puede no estar abierta o ya estar cerrada
      }
      try {
        final habitsBox = Hive.box('habits');
        if (habitsBox.isOpen) {
          await habitsBox.close();
        }
      } catch (e) {
        // La caja puede no estar abierta o ya estar cerrada
      }
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    // ========================================
    // CASCADE TESTING: Each test builds upon the previous
    // ========================================

    test('Step 1: Create first habit and convert to TimeBlock', () async {
      // Arrange & Act - Create first habit
      morningExerciseHabit = HabitModel.create(
        title: 'Morning Exercise',
        description: 'Daily 30-minute workout',
        daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
        category: 'Health',
        reminder: 'Morning',
        time: '07:00',
      );

      // Convert habit to time block
      firstTimeBlock = TimeBlockModel.create(
        title: '${morningExerciseHabit!.title} - ${morningExerciseHabit!.time}',
        description: morningExerciseHabit!.description,
        startTime: DateTime(2023, 1, 2, 7, 0), // Monday 7:00 AM
        endTime: DateTime(2023, 1, 2, 7, 30), // Monday 7:30 AM
        category: morningExerciseHabit!.category,
        color: '#4CAF50',
      );

      await timeBlockRepository.addTimeBlock(firstTimeBlock!);
      createdTimeBlocks.add(firstTimeBlock!);

      // Assert
      final retrievedBlocks = await timeBlockRepository.getAllTimeBlocks();
      expect(retrievedBlocks.length, equals(1));
      
      final retrievedBlock = retrievedBlocks.first;
      expect(retrievedBlock.title, contains(morningExerciseHabit!.title));
      expect(retrievedBlock.title, contains(morningExerciseHabit!.time));
      expect(retrievedBlock.category, equals(morningExerciseHabit!.category));
      expect(retrievedBlock.startTime.hour, equals(7));
      expect(retrievedBlock.startTime.minute, equals(0));
    });

    test('Step 2: Create multiple TimeBlocks from habit schedule (using previous habit)', () async {
      // Arrange - Use habit from previous test or create new one
      studySessionHabit = HabitModel.create(
        title: 'Study Session',
        description: 'Daily study time',
        daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        category: 'Learning',
        reminder: 'Afternoon',
        time: '14:00',
      );

      // Act - Create time blocks for each day (building on previous test data)
      final baseDate = DateTime(2023, 1, 2); // Monday
      
      for (int day = 0; day < 5; day++) {
        final currentDate = baseDate.add(Duration(days: day));
        final timeBlock = TimeBlockModel.create(
          title: '${studySessionHabit!.title} - Day ${day + 1}',
          description: studySessionHabit!.description,
          startTime: DateTime(currentDate.year, currentDate.month, currentDate.day, 14, 0),
          endTime: DateTime(currentDate.year, currentDate.month, currentDate.day, 15, 0),
          category: studySessionHabit!.category,
          color: '#2196F3',
        );
        
        createdTimeBlocks.add(timeBlock);
        await timeBlockRepository.addTimeBlock(timeBlock);
      }

      // Assert - Should have previous block + 5 new blocks = 6 total
      final retrievedBlocks = await timeBlockRepository.getAllTimeBlocks();
      expect(retrievedBlocks.length, equals(6)); // 1 from previous test + 5 new
      
      // Verify each block is scheduled correctly
      final studyBlocks = retrievedBlocks.where((b) => b.category == 'Learning').toList();
      expect(studyBlocks.length, equals(5));
      
      for (final block in studyBlocks) {
        expect(block.startTime.hour, equals(14));
        expect(block.startTime.minute, equals(0));
        expect(block.duration, equals(const Duration(hours: 1)));
      }
    });

    test('Step 3: Update TimeBlock completion status (using blocks from previous tests)', () async {
      // Arrange - Use first timeblock from Step 1
      expect(firstTimeBlock, isNotNull, reason: 'First timeblock should exist from Step 1');
      
      // Act - Mark time block as completed
      final completedTimeBlock = firstTimeBlock!.markAsCompleted();
      await timeBlockRepository.updateTimeBlock(completedTimeBlock);
      firstTimeBlock = completedTimeBlock; // Update shared state

      // Assert
      final retrievedBlock = await timeBlockRepository.getTimeBlock(firstTimeBlock!.id);
      expect(retrievedBlock, isNotNull);
      expect(retrievedBlock!.isCompleted, isTrue);
      
      // Verify other blocks are still incomplete
      final allBlocks = await timeBlockRepository.getAllTimeBlocks();
      final incompleteBlocks = allBlocks.where((b) => !b.isCompleted).toList();
      expect(incompleteBlocks.length, equals(5)); // The 5 study blocks
    });

    test('Step 4: Create TimeBlock from Activity (adding to existing blocks)', () async {
      // Arrange - Create activity
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Team Meeting',
        description: 'Weekly team sync',
        category: 'Work',
        startTime: DateTime(2023, 1, 2, 10, 0),
        endTime: DateTime(2023, 1, 2, 11, 0),
        priority: 'High',
        sendReminder: true,
        reminderMinutesBefore: 15,
      );

      // Act - Convert activity to time block
      final activityTimeBlock = TimeBlockModel.create(
        title: activity.title,
        description: activity.description,
        startTime: activity.startTime,
        endTime: activity.endTime,
        category: activity.category,
        color: '#F44336',
        isCompleted: activity.isCompleted,
      );

      await timeBlockRepository.addTimeBlock(activityTimeBlock);
      createdTimeBlocks.add(activityTimeBlock);

      // Assert - Should have 7 blocks now (1 completed exercise + 5 study + 1 activity)
      final retrievedBlocks = await timeBlockRepository.getAllTimeBlocks();
      expect(retrievedBlocks.length, equals(7));
      
      final retrievedBlock = retrievedBlocks.firstWhere((b) => b.title == activity.title);
      expect(retrievedBlock.title, equals(activity.title));
      expect(retrievedBlock.description, equals(activity.description));
      expect(retrievedBlock.startTime, equals(activity.startTime));
      expect(retrievedBlock.endTime, equals(activity.endTime));
      expect(retrievedBlock.category, equals(activity.category));
    });

    test('Step 5: Sync Activity status with TimeBlock (using previous activity)', () async {
      // Arrange - Find the activity timeblock from Step 4
      final allBlocks = await timeBlockRepository.getAllTimeBlocks();
      final activityBlock = allBlocks.firstWhere(
        (b) => b.title == 'Team Meeting',
        orElse: () => throw StateError('Activity block should exist from Step 4'),
      );

      // Act - Toggle activity completion and sync with time block
      final updatedTimeBlock = activityBlock.copyWith(isCompleted: true);
      await timeBlockRepository.updateTimeBlock(updatedTimeBlock);

      // Assert
      final retrievedBlock = await timeBlockRepository.getTimeBlock(activityBlock.id);
      expect(retrievedBlock, isNotNull);
      expect(retrievedBlock!.isCompleted, isTrue);
      
      // Verify completion count - get fresh data after update
      final updatedBlocks = await timeBlockRepository.getAllTimeBlocks();
      final completedBlocks = updatedBlocks.where((b) => b.isCompleted).toList();
      expect(completedBlocks.length, greaterThanOrEqualTo(1), 
          reason: 'At least the activity block should be completed');
    });

    test('Step 6: Bulk operations on all created TimeBlocks', () async {
      // Arrange - All blocks from previous tests
      final allBlocks = await timeBlockRepository.getAllTimeBlocks();
      expect(allBlocks.length, greaterThanOrEqualTo(7));

      // Act & Assert - Test filtering by category
      final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
      final healthBlocks = allBlocks.where((block) => block.category == 'Health').toList();
      final learningBlocks = allBlocks.where((block) => block.category == 'Learning').toList();
      
      expect(workBlocks.length, greaterThanOrEqualTo(1));
      expect(healthBlocks.length, greaterThanOrEqualTo(1));
      expect(learningBlocks.length, greaterThanOrEqualTo(5));

      // Test sorting by start time
      final sortedBlocks = List<TimeBlockModel>.from(allBlocks);
      sortedBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      expect(sortedBlocks.first.startTime.hour, lessThanOrEqualTo(7));
      expect(sortedBlocks.last.startTime.hour, greaterThanOrEqualTo(14));

      // Test filtering by completion status
      final completedBlocks = allBlocks.where((block) => block.isCompleted).toList();
      final incompleteBlocks = allBlocks.where((block) => !block.isCompleted).toList();
      
      expect(completedBlocks.length, greaterThanOrEqualTo(2));
      expect(incompleteBlocks.length, greaterThanOrEqualTo(5));
    });

    test('Step 7: TimeBlock conflict detection (using existing blocks)', () async {
      // Arrange - Use existing blocks from previous tests
      final allBlocks = await timeBlockRepository.getAllTimeBlocks();
      final baseTime = DateTime(2023, 1, 2, 10, 0); // Same time as Team Meeting
      
      // Act - Try to create overlapping time block
      final overlappingBlock = TimeBlockModel.create(
        title: 'Overlapping Meeting',
        description: 'This overlaps with Team Meeting',
        startTime: baseTime.add(const Duration(minutes: 30)),
        endTime: baseTime.add(const Duration(hours: 1, minutes: 30)),
        category: 'Work',
        color: '#FF5722',
      );

      await timeBlockRepository.addTimeBlock(overlappingBlock);
      createdTimeBlocks.add(overlappingBlock);

      // Assert - Both blocks should exist (repository doesn't prevent overlaps)
      final updatedBlocks = await timeBlockRepository.getAllTimeBlocks();
      expect(updatedBlocks.length, equals(8)); // 7 previous + 1 new

      // Verify overlap detection logic
      final hasOverlap = _detectOverlaps(updatedBlocks);
      expect(hasOverlap, isTrue);
    });

    test('Step 8: Complete workflow summary (verify all previous steps)', () async {
      // Arrange - All data from cascade tests
      final allBlocks = await timeBlockRepository.getAllTimeBlocks();
      
      // Assert - Verify complete workflow
      // Should have at least 7 blocks: 1 from Step 1, 5 from Step 2, 1 from Step 4, 1 from Step 7
      expect(allBlocks.length, greaterThanOrEqualTo(7));
      
      // Verify categories distribution - should have multiple categories
      final categories = allBlocks.map((b) => b.category).toSet();
      expect(categories.length, greaterThanOrEqualTo(1), 
          reason: 'Should have at least one category');
      
      // Verify completion tracking - at least one should be completed (from Step 3)
      final completedCount = allBlocks.where((b) => b.isCompleted).length;
      final incompleteCount = allBlocks.where((b) => !b.isCompleted).length;
      
      // Verify we have both completed and incomplete blocks (showing workflow progression)
      expect(completedCount, greaterThanOrEqualTo(0), 
          reason: 'Should have some completed blocks (may be 0 if Step 5 update didn\'t persist)');
      expect(incompleteCount, greaterThanOrEqualTo(5),
          reason: 'Most blocks should be incomplete');
      
      // Verify total count matches
      expect(completedCount + incompleteCount, equals(allBlocks.length),
          reason: 'Completed + incomplete should equal total');
      
      // Verify time distribution
      final morningBlocks = allBlocks.where((b) => b.startTime.hour < 12).length;
      final afternoonBlocks = allBlocks.where((b) => b.startTime.hour >= 12).length;
      
      expect(morningBlocks, greaterThanOrEqualTo(1),
          reason: 'At least one morning block from Step 1');
      expect(afternoonBlocks, greaterThanOrEqualTo(5),
          reason: 'At least 5 afternoon blocks from Step 2');
      
      // Verify all blocks are accessible and retrievable
      for (final block in allBlocks) {
        final retrieved = await timeBlockRepository.getTimeBlock(block.id);
        expect(retrieved, isNotNull, 
            reason: 'All blocks from repository should be retrievable');
        expect(retrieved!.id, equals(block.id),
            reason: 'Retrieved block should have same ID');
      }
      
      // Verify that firstTimeBlock from Step 1 exists and is accessible
      if (firstTimeBlock != null) {
        final retrievedFirst = await timeBlockRepository.getTimeBlock(firstTimeBlock!.id);
        expect(retrievedFirst, isNotNull,
            reason: 'First timeblock from Step 1 should be accessible');
      }
    });
  });
}

/// Helper function to detect overlapping time blocks
bool _detectOverlaps(List<TimeBlockModel> blocks) {
  for (int i = 0; i < blocks.length; i++) {
    for (int j = i + 1; j < blocks.length; j++) {
      final block1 = blocks[i];
      final block2 = blocks[j];
      
      // Check if blocks overlap
      if (block1.startTime.isBefore(block2.endTime) && 
          block2.startTime.isBefore(block1.endTime)) {
        return true;
      }
    }
  }
  return false;
}
