import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'dart:io';

/// Enhanced Integration Tests for TimeBlock with Habits and Activities
/// This test suite implements comprehensive integration testing between different modules
void main() {
  group('TimeBlock Integration Tests - Enhanced', () {
    late TimeBlockRepository timeBlockRepository;
    late Directory tempDir;

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
    });

    setUp(() async {
      timeBlockRepository = TimeBlockRepository();
      await timeBlockRepository.init();
      
      // Clean up previous test data
      await Hive.deleteBoxFromDisk('timeblocks');
      await Hive.deleteBoxFromDisk('habits');
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('timeblocks');
      await Hive.deleteBoxFromDisk('habits');
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    group('TimeBlock-Habit Integration', () {
      test('Integration: Create TimeBlock from Habit', () async {
        // Arrange
        final habit = HabitModel.create(
          title: 'Morning Exercise',
          description: 'Daily 30-minute workout',
          daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
          category: 'Health',
          reminder: 'Morning',
          time: '07:00',
        );

        // Act - Convert habit to time block
        final timeBlock = TimeBlockModel.create(
          title: '${habit.title} - ${habit.time}',
          description: habit.description,
          startTime: DateTime(2023, 1, 2, 7, 0), // Monday 7:00 AM
          endTime: DateTime(2023, 1, 2, 7, 30), // Monday 7:30 AM
          category: habit.category,
          color: '#4CAF50',
        );

        await timeBlockRepository.addTimeBlock(timeBlock);

        // Assert
        final retrievedBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(retrievedBlocks.length, equals(1));
        
        final retrievedBlock = retrievedBlocks.first;
        expect(retrievedBlock.title, contains(habit.title));
        expect(retrievedBlock.title, contains(habit.time));
        expect(retrievedBlock.category, equals(habit.category));
        expect(retrievedBlock.startTime.hour, equals(7));
        expect(retrievedBlock.startTime.minute, equals(0));
      });

      test('Integration: Multiple TimeBlocks from Habit Schedule', () async {
        // Arrange
        final habit = HabitModel.create(
          title: 'Study Session',
          description: 'Daily study time',
          daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          category: 'Learning',
          reminder: 'Afternoon',
          time: '14:00',
        );

        // Act - Create time blocks for each day
        final timeBlocks = <TimeBlockModel>[];
        final baseDate = DateTime(2023, 1, 2); // Monday
        
        for (int day = 0; day < 5; day++) {
          final currentDate = baseDate.add(Duration(days: day));
          final timeBlock = TimeBlockModel.create(
            title: '${habit.title} - Day ${day + 1}',
            description: habit.description,
            startTime: DateTime(currentDate.year, currentDate.month, currentDate.day, 14, 0),
            endTime: DateTime(currentDate.year, currentDate.month, currentDate.day, 15, 0),
            category: habit.category,
            color: '#2196F3',
          );
          
          timeBlocks.add(timeBlock);
          await timeBlockRepository.addTimeBlock(timeBlock);
        }

        // Assert
        final retrievedBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(retrievedBlocks.length, equals(5));
        
        // Verify each block is scheduled correctly
        for (int i = 0; i < retrievedBlocks.length; i++) {
          final block = retrievedBlocks[i];
          expect(block.startTime.hour, equals(14));
          expect(block.startTime.minute, equals(0));
          expect(block.duration, equals(const Duration(hours: 1)));
        }
      });

      test('Integration: Habit Completion Updates TimeBlock', () async {
        // Arrange
        final habit = HabitModel.create(
          title: 'Daily Reading',
          description: 'Read for 30 minutes',
          daysOfWeek: ['Monday'],
          category: 'Learning',
          reminder: 'Evening',
          time: '20:00',
        );

        final timeBlock = TimeBlockModel.create(
          title: habit.title,
          description: habit.description,
          startTime: DateTime(2023, 1, 2, 20, 0),
          endTime: DateTime(2023, 1, 2, 20, 30),
          category: habit.category,
          color: '#FF9800',
        );

        await timeBlockRepository.addTimeBlock(timeBlock);

        // Act - Mark time block as completed (simulating habit completion)
        final completedTimeBlock = timeBlock.markAsCompleted();
        await timeBlockRepository.updateTimeBlock(completedTimeBlock);

        // Assert
        final retrievedBlock = await timeBlockRepository.getTimeBlock(timeBlock.id);
        expect(retrievedBlock, isNotNull);
        expect(retrievedBlock!.isCompleted, isTrue);
      });
    });

    group('TimeBlock-Activity Integration', () {
      test('Integration: Create TimeBlock from Activity', () async {
        // Arrange
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
        final timeBlock = TimeBlockModel.create(
          title: activity.title,
          description: activity.description,
          startTime: activity.startTime,
          endTime: activity.endTime,
          category: activity.category,
          color: '#F44336',
          isCompleted: activity.isCompleted,
        );

        await timeBlockRepository.addTimeBlock(timeBlock);

        // Assert
        final retrievedBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(retrievedBlocks.length, equals(1));
        
        final retrievedBlock = retrievedBlocks.first;
        expect(retrievedBlock.title, equals(activity.title));
        expect(retrievedBlock.description, equals(activity.description));
        expect(retrievedBlock.startTime, equals(activity.startTime));
        expect(retrievedBlock.endTime, equals(activity.endTime));
        expect(retrievedBlock.category, equals(activity.category));
        expect(retrievedBlock.isCompleted, equals(activity.isCompleted));
      });

      test('Integration: Activity Status Sync with TimeBlock', () async {
        // Arrange
        final activity = ActivityModel(
          id: 'activity-2',
          title: 'Project Review',
          description: 'Review project progress',
          category: 'Work',
          startTime: DateTime(2023, 1, 2, 15, 0),
          endTime: DateTime(2023, 1, 2, 16, 0),
        );

        final timeBlock = TimeBlockModel.create(
          title: activity.title,
          description: activity.description,
          startTime: activity.startTime,
          endTime: activity.endTime,
          category: activity.category,
          color: '#9C27B0',
          isCompleted: activity.isCompleted,
        );

        await timeBlockRepository.addTimeBlock(timeBlock);

        // Act - Toggle activity completion and sync with time block
        final completedActivity = activity.toggleCompletion();
        final updatedTimeBlock = timeBlock.copyWith(isCompleted: completedActivity.isCompleted);
        await timeBlockRepository.updateTimeBlock(updatedTimeBlock);

        // Assert
        final retrievedBlock = await timeBlockRepository.getTimeBlock(timeBlock.id);
        expect(retrievedBlock, isNotNull);
        expect(retrievedBlock!.isCompleted, equals(completedActivity.isCompleted));
        expect(retrievedBlock.isCompleted, isTrue);
      });

      test('Integration: Overdue Activity Creates Urgent TimeBlock', () async {
        // Arrange
        final pastTime = DateTime.now().subtract(const Duration(hours: 2));
        final activity = ActivityModel(
          id: 'overdue-activity',
          title: 'Overdue Task',
          description: 'This task is overdue',
          category: 'Work',
          startTime: pastTime.subtract(const Duration(hours: 1)),
          endTime: pastTime,
          isCompleted: false,
        );

        // Act - Create time block for overdue activity
        final timeBlock = TimeBlockModel.create(
          title: '🚨 ${activity.title}',
          description: 'OVERDUE: ${activity.description}',
          startTime: activity.startTime,
          endTime: activity.endTime,
          category: activity.category,
          color: '#FF5722', // Red color for urgent
          isCompleted: activity.isCompleted,
        );

        await timeBlockRepository.addTimeBlock(timeBlock);

        // Assert
        final retrievedBlock = await timeBlockRepository.getTimeBlock(timeBlock.id);
        expect(retrievedBlock, isNotNull);
        expect(retrievedBlock!.title, startsWith('🚨'));
        expect(retrievedBlock.description, startsWith('OVERDUE:'));
        expect(retrievedBlock.color, equals('#FF5722'));
        expect(retrievedBlock.isPast, isTrue);
      });
    });

    group('TimeBlock Repository Integration', () {
      test('Integration: Bulk TimeBlock Operations', () async {
        // Arrange
        final timeBlocks = <TimeBlockModel>[];
        
        // Create multiple time blocks
        for (int i = 0; i < 10; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'Task $i',
            description: 'Description for task $i',
            startTime: DateTime(2023, 1, 2, 9 + i, 0),
            endTime: DateTime(2023, 1, 2, 10 + i, 0),
            category: i % 2 == 0 ? 'Work' : 'Personal',
            color: i % 2 == 0 ? '#2196F3' : '#4CAF50',
          );
          timeBlocks.add(timeBlock);
        }

        // Act - Create all time blocks
        for (final block in timeBlocks) {
            await timeBlockRepository.addTimeBlock(block);
        }

        // Assert
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(10));

        // Test filtering by category
        final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
        final personalBlocks = allBlocks.where((block) => block.category == 'Personal').toList();
        
        expect(workBlocks.length, equals(5));
        expect(personalBlocks.length, equals(5));

        // Test sorting by start time
        final sortedBlocks = List<TimeBlockModel>.from(allBlocks);
        sortedBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
        
        expect(sortedBlocks.first.startTime.hour, equals(9));
        expect(sortedBlocks.last.startTime.hour, equals(18));
      });

      test('Integration: TimeBlock Search and Filter', () async {
        // Arrange
        final timeBlocks = [
          TimeBlockModel.create(
            title: 'Morning Exercise',
            description: 'Daily workout routine',
            startTime: DateTime(2023, 1, 2, 7, 0),
            endTime: DateTime(2023, 1, 2, 8, 0),
            category: 'Health',
            color: '#4CAF50',
          ),
          TimeBlockModel.create(
            title: 'Work Meeting',
            description: 'Team standup meeting',
            startTime: DateTime(2023, 1, 2, 9, 0),
            endTime: DateTime(2023, 1, 2, 10, 0),
            category: 'Work',
            color: '#2196F3',
          ),
          TimeBlockModel.create(
            title: 'Study Session',
            description: 'Learning new skills',
            startTime: DateTime(2023, 1, 2, 14, 0),
            endTime: DateTime(2023, 1, 2, 16, 0),
            category: 'Learning',
            color: '#FF9800',
          ),
        ];

        for (final block in timeBlocks) {
            await timeBlockRepository.addTimeBlock(block);
        }

        // Act & Assert - Test different search criteria
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        
        // Filter by category
        final healthBlocks = allBlocks.where((block) => block.category == 'Health').toList();
        expect(healthBlocks.length, equals(1));
        expect(healthBlocks.first.title, equals('Morning Exercise'));

        // Filter by time range
        final morningBlocks = allBlocks.where((block) => 
          block.startTime.hour >= 6 && block.startTime.hour < 12).toList();
        expect(morningBlocks.length, equals(2));

        // Filter by duration
        final longBlocks = allBlocks.where((block) => 
          block.duration.inHours >= 2).toList();
        expect(longBlocks.length, equals(1));
        expect(longBlocks.first.title, equals('Study Session'));

        // Filter by completion status
        final incompleteBlocks = allBlocks.where((block) => !block.isCompleted).toList();
        expect(incompleteBlocks.length, equals(3));
      });

      test('Integration: TimeBlock Conflict Detection', () async {
        // Arrange
        final baseTime = DateTime(2023, 1, 2, 10, 0);
        
        // Create first time block
        final firstBlock = TimeBlockModel.create(
          title: 'First Meeting',
          description: 'First meeting of the day',
          startTime: baseTime,
          endTime: baseTime.add(const Duration(hours: 1)),
          category: 'Work',
          color: '#2196F3',
        );

        await timeBlockRepository.addTimeBlock(firstBlock);

        // Act - Try to create overlapping time block
        final overlappingBlock = TimeBlockModel.create(
          title: 'Overlapping Meeting',
          description: 'This overlaps with first meeting',
          startTime: baseTime.add(const Duration(minutes: 30)),
          endTime: baseTime.add(const Duration(hours: 1, minutes: 30)),
          category: 'Work',
          color: '#F44336',
        );

        await timeBlockRepository.addTimeBlock(overlappingBlock);

        // Assert - Both blocks should exist (repository doesn't prevent overlaps)
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(2));

        // Verify overlap detection logic
        final blocks = await timeBlockRepository.getAllTimeBlocks();
        final hasOverlap = _detectOverlaps(blocks);
        expect(hasOverlap, isTrue);
      });
    });

    group('TimeBlock State Management Integration', () {
      test('Integration: TimeBlock State Transitions', () async {
        // Arrange
        final futureTime = DateTime.now().add(const Duration(hours: 2));
        final timeBlock = TimeBlockModel.create(
          title: 'Future Task',
          description: 'Task scheduled for future',
          startTime: futureTime,
          endTime: futureTime.add(const Duration(hours: 1)),
          category: 'Work',
          color: '#2196F3',
        );

        await timeBlockRepository.addTimeBlock(timeBlock);

        // Act & Assert - Test state transitions
        final retrievedBlock = await timeBlockRepository.getTimeBlock(timeBlock.id);
        expect(retrievedBlock, isNotNull);
        
        // Initial state: Pending
        expect(retrievedBlock!.isPending, isTrue);
        expect(retrievedBlock.isInProgress, isFalse);
        expect(retrievedBlock.isPast, isFalse);

        // Simulate time passing - task becomes active
        final now = DateTime.now();
        final activeTime = now.add(const Duration(minutes: 30));
        
        final activeBlock = timeBlock.copyWith(
          startTime: now.subtract(const Duration(minutes: 15)),
          endTime: now.add(const Duration(minutes: 45)),
        );
        
        await timeBlockRepository.updateTimeBlock(activeBlock);
        
        final updatedActiveBlock = await timeBlockRepository.getTimeBlock(timeBlock.id);
        expect(updatedActiveBlock, isNotNull);
        expect(updatedActiveBlock!.isInProgress, isTrue);
        expect(updatedActiveBlock.isPending, isFalse);
        expect(updatedActiveBlock.isPast, isFalse);

        // Simulate task completion - task becomes past
        final pastBlock = timeBlock.copyWith(
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.subtract(const Duration(hours: 1)),
          isCompleted: true,
        );
        
        await timeBlockRepository.updateTimeBlock(pastBlock);
        
        final updatedPastBlock = await timeBlockRepository.getTimeBlock(timeBlock.id);
        expect(updatedPastBlock, isNotNull);
        expect(updatedPastBlock!.isPast, isTrue);
        expect(updatedPastBlock.isPending, isFalse);
        expect(updatedPastBlock.isInProgress, isFalse);
        expect(updatedPastBlock.isCompleted, isTrue);
      });

      test('Integration: TimeBlock Completion Tracking', () async {
        // Arrange
        final timeBlocks = <TimeBlockModel>[];
        
        for (int i = 0; i < 5; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'Task $i',
            description: 'Task number $i',
            startTime: DateTime(2023, 1, 2, 9 + i, 0),
            endTime: DateTime(2023, 1, 2, 10 + i, 0),
            category: 'Work',
            color: '#2196F3',
            isCompleted: i % 2 == 0, // Alternate completion status
          );
          timeBlocks.add(timeBlock);
          await timeBlockRepository.addTimeBlock(timeBlock);
        }

        // Act & Assert
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        
        final completedBlocks = allBlocks.where((block) => block.isCompleted).toList();
        final incompleteBlocks = allBlocks.where((block) => !block.isCompleted).toList();
        
        expect(completedBlocks.length, equals(3)); // Tasks 0, 2, 4
        expect(incompleteBlocks.length, equals(2)); // Tasks 1, 3

        // Test completion percentage
        final completionPercentage = (completedBlocks.length / allBlocks.length) * 100;
        expect(completionPercentage, equals(60.0));
      });
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
