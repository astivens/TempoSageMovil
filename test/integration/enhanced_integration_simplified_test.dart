import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/auth/data/services/auth_service.dart';
import 'package:temposage/features/auth/data/models/user_model.dart';
import 'dart:io';

// Simple CSV service for testing
class TestCsvService {
  String convertToCsv(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    final headers = data.first.keys.toList();
    final csv = StringBuffer();
    
    // Add headers
    csv.write(headers.join(','));
    
    // Add data rows
    for (final row in data) {
      csv.write('\n');
      final values = headers.map((header) => row[header]?.toString() ?? '').toList();
      csv.write(values.join(','));
    }
    
    return csv.toString();
  }
}

// Simple in-memory repository for testing
class TestTimeBlockRepository {
  final List<TimeBlockModel> _timeBlocks = [];

  Future<void> addTimeBlock(TimeBlockModel timeBlock) async {
    _timeBlocks.add(timeBlock);
  }

  Future<List<TimeBlockModel>> getAllTimeBlocks() async {
    return List.from(_timeBlocks);
  }

  Future<TimeBlockModel?> getTimeBlock(String id) async {
    try {
      return _timeBlocks.firstWhere((block) => block.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTimeBlock(TimeBlockModel timeBlock) async {
    final index = _timeBlocks.indexWhere((block) => block.id == timeBlock.id);
    if (index != -1) {
      _timeBlocks[index] = timeBlock;
    }
  }

  Future<void> deleteTimeBlock(String id) async {
    _timeBlocks.removeWhere((block) => block.id == id);
  }

  void clear() {
    _timeBlocks.clear();
  }
}

/// Enhanced Integration Tests - Simplified Version
/// This test suite implements comprehensive integration testing without complex repository dependencies
void main() {
  group('Enhanced Integration Tests - Simplified', () {
    late AuthService authService;
    late TestTimeBlockRepository timeBlockRepository;
    late TestCsvService csvService;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(TimeBlockModelAdapter());
      }
    });

    setUp(() async {
      authService = AuthService();
      timeBlockRepository = TestTimeBlockRepository();
      csvService = TestCsvService();
      
      // Clean up previous test data
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('auth');
    });

    tearDown(() async {
      timeBlockRepository.clear();
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('auth');
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

    group('Complete System Integration', () {
      test('Integration: Complete User Workflow', () async {
        // Step 1: User Registration
        final user = await authService.register(
          'integration@example.com',
          'Integration User',
          'password123',
        );
        expect(user.email, equals('integration@example.com'));

        // Step 2: User Login
        final loginResult = await authService.login('integration@example.com', 'password123');
        expect(loginResult, isTrue);

        final currentUser = await authService.getCurrentUser();
        expect(currentUser, isNotNull);
        expect(currentUser!.name, equals('Integration User'));

        // Step 3: Create Multiple TimeBlocks
        final timeBlocks = <TimeBlockModel>[];
        for (int i = 0; i < 5; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'Integration Task $i',
            description: 'Description for task $i',
            startTime: DateTime(2023, 1, 2, 9 + i, 0),
            endTime: DateTime(2023, 1, 2, 10 + i, 0),
            category: i % 2 == 0 ? 'Work' : 'Personal',
            color: i % 2 == 0 ? '#2196F3' : '#4CAF50',
          );
          timeBlocks.add(timeBlock);
          await timeBlockRepository.addTimeBlock(timeBlock);
        }

        // Step 4: Verify Data Creation
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(5));

        // Step 5: Data Analysis and Processing
        final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
        final personalBlocks = allBlocks.where((block) => block.category == 'Personal').toList();
        
        expect(workBlocks.length, equals(3));
        expect(personalBlocks.length, equals(2));

        // Step 6: Data Export
        final exportData = allBlocks.map((block) => {
          'id': block.id,
          'title': block.title,
          'category': block.category,
          'start_time': block.startTime.toIso8601String(),
          'end_time': block.endTime.toIso8601String(),
          'is_completed': block.isCompleted.toString(),
        }).toList();

        final csvData = csvService.convertToCsv(exportData);
        expect(csvData, isNotEmpty);
        expect(csvData, contains('id,title,category,start_time,end_time,is_completed'));

        // Step 7: User Logout
        await authService.logout();
        final loggedOutUser = await authService.getCurrentUser();
        expect(loggedOutUser, isNull);
      });

      test('Integration: Multi-User Concurrent Operations', () async {
        // Create multiple users simultaneously
        final users = <UserModel>[];
        for (int i = 0; i < 3; i++) {
          final user = await authService.register(
            'user$i@example.com',
            'User $i',
            'password123',
          );
          users.add(user);
        }

        // Verify all users were created
        expect(users.length, equals(3));
        expect(users[0].email, equals('user0@example.com'));
        expect(users[1].email, equals('user1@example.com'));
        expect(users[2].email, equals('user2@example.com'));

        // Test login for the first user only (to avoid conflicts)
        final loginResult = await authService.login('user0@example.com', 'password123');
        expect(loginResult, isTrue);

        final currentUser = await authService.getCurrentUser();
        expect(currentUser, isNotNull);
        expect(currentUser!.email, equals('user0@example.com'));

        // Test concurrent data creation
        final timeBlockPromises = <Future<TimeBlockModel>>[];
        for (int userIndex = 0; userIndex < 3; userIndex++) {
          for (int taskIndex = 0; taskIndex < 2; taskIndex++) {
            final timeBlock = TimeBlockModel.create(
              title: 'User $userIndex Task $taskIndex',
              description: 'Task created by user $userIndex',
              startTime: DateTime(2023, 1, 2, 9 + userIndex * 2 + taskIndex, 0),
              endTime: DateTime(2023, 1, 2, 10 + userIndex * 2 + taskIndex, 0),
              category: 'Work',
              color: '#2196F3',
            );
            timeBlockPromises.add(
              timeBlockRepository.addTimeBlock(timeBlock).then((_) => timeBlock)
            );
          }
        }

        final createdBlocks = await Future.wait(timeBlockPromises);
        expect(createdBlocks.length, equals(6));

        // Verify all blocks were created
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(6));
      });

      test('Integration: Data Consistency and Validation', () async {
        // Create user and data
        await authService.register('consistency@example.com', 'Consistency User', 'password123');
        await authService.login('consistency@example.com', 'password123');

        // Create time blocks with various data
        final timeBlocks = [
          TimeBlockModel.create(
            title: 'Consistent Task 1',
            description: 'First task for consistency testing',
            startTime: DateTime(2023, 1, 2, 9, 0),
            endTime: DateTime(2023, 1, 2, 10, 0),
            category: 'Work',
            color: '#2196F3',
          ),
          TimeBlockModel.create(
            title: 'Consistent Task 2',
            description: 'Second task for consistency testing',
            startTime: DateTime(2023, 1, 2, 10, 0),
            endTime: DateTime(2023, 1, 2, 11, 0),
            category: 'Personal',
            color: '#4CAF50',
          ),
        ];

        for (final block in timeBlocks) {
          await timeBlockRepository.addTimeBlock(block);
        }

        // Verify initial state
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(2));

        // Update some blocks
        final updatedBlock = allBlocks[0].copyWith(
          isCompleted: true,
          title: 'Updated Consistent Task 1',
        );
        await timeBlockRepository.updateTimeBlock(updatedBlock);

        // Delete one block
        await timeBlockRepository.deleteTimeBlock(allBlocks[1].id);

        // Verify final state
        final finalBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(finalBlocks.length, equals(1));
        
        final remainingBlock = finalBlocks.first;
        expect(remainingBlock.title, equals('Updated Consistent Task 1'));
        expect(remainingBlock.isCompleted, isTrue);
      });
    });

    group('Performance Integration Testing', () {
      test('Integration: Bulk Operations Performance', () async {
        // Test bulk time block creation
        final startTime = DateTime.now();
        
        for (int i = 0; i < 50; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'Bulk Task $i',
            description: 'Task $i for bulk testing',
            startTime: DateTime(2023, 1, 2, 9 + (i % 12), 0),
            endTime: DateTime(2023, 1, 2, 10 + (i % 12), 0),
            category: i % 2 == 0 ? 'Work' : 'Personal',
            color: i % 2 == 0 ? '#2196F3' : '#4CAF50',
          );
          await timeBlockRepository.addTimeBlock(timeBlock);
        }

        final creationTime = DateTime.now().difference(startTime);
        expect(creationTime.inMilliseconds, lessThan(1000)); // Should be fast

        // Test bulk retrieval
        final retrievalStartTime = DateTime.now();
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        final retrievalTime = DateTime.now().difference(retrievalStartTime);

        expect(allBlocks.length, equals(50));
        expect(retrievalTime.inMilliseconds, lessThan(100)); // Should be very fast

        // Test bulk operations
        final operationStartTime = DateTime.now();
        
        // Filter operations
        final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
        final personalBlocks = allBlocks.where((block) => block.category == 'Personal').toList();
        
        // Sort operations
        final sortedBlocks = List<TimeBlockModel>.from(allBlocks);
        sortedBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
        
        // Update operations
        for (int i = 0; i < 10; i++) {
          final updatedBlock = allBlocks[i].copyWith(isCompleted: true);
          await timeBlockRepository.updateTimeBlock(updatedBlock);
        }

        final operationTime = DateTime.now().difference(operationStartTime);

        // Verify results
        expect(workBlocks.length, equals(25));
        expect(personalBlocks.length, equals(25));
        expect(sortedBlocks.length, equals(50));
        expect(operationTime.inMilliseconds, lessThan(500)); // Should be fast

        // Test export performance
        final exportStartTime = DateTime.now();
        final exportData = allBlocks.map((block) => {
          'title': block.title,
          'category': block.category,
          'start_time': block.startTime.toIso8601String(),
          'end_time': block.endTime.toIso8601String(),
          'is_completed': block.isCompleted.toString(),
        }).toList();

        final csvData = csvService.convertToCsv(exportData);
        final exportTime = DateTime.now().difference(exportStartTime);

        expect(csvData, isNotEmpty);
        expect(csvData.split('\n').length, equals(51)); // 50 data rows + 1 header
        expect(exportTime.inMilliseconds, lessThan(100)); // Should be very fast
      });
    });
  });
}
