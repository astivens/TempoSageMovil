import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
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

/// Enhanced Acceptance Tests - Extended Coverage
/// This test suite implements comprehensive acceptance testing for all user requirements
void main() {
  group('Enhanced Acceptance Tests - Extended Coverage', () {
    late AuthService authService;
    late TimeBlockRepository timeBlockRepository;
    late TestCsvService csvService;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
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
      // Initialize services first
      authService = AuthService();
      timeBlockRepository = TimeBlockRepository();
      csvService = TestCsvService();
      
      // Initialize repository first to open boxes
      await timeBlockRepository.init();
      
      // Clear box contents to clean up previous test data
      try {
        final usersBox = Hive.box('users');
        if (usersBox.isOpen) {
          await usersBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open, will be created when needed
      }
      try {
        final authBox = Hive.box('auth');
        if (authBox.isOpen) {
          await authBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open, will be created when needed
      }
      try {
        final timeBlocksBox = Hive.box('timeblocks');
        if (timeBlocksBox.isOpen) {
          await timeBlocksBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open, will be created when needed
      }
      try {
        final habitsBox = Hive.box('habits');
        if (habitsBox.isOpen) {
          await habitsBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open, will be created when needed
      }
    });

    tearDown(() async {
      // Clear box contents instead of closing/deleting to avoid "Box has already been closed" errors
      try {
        final usersBox = Hive.box('users');
        if (usersBox.isOpen) {
          await usersBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open
      }
      try {
        final authBox = Hive.box('auth');
        if (authBox.isOpen) {
          await authBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open
      }
      try {
        final timeBlocksBox = Hive.box('timeblocks');
        if (timeBlocksBox.isOpen) {
          await timeBlocksBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open
      }
      try {
        final habitsBox = Hive.box('habits');
        if (habitsBox.isOpen) {
          await habitsBox.clear();
        }
      } catch (e) {
        // Box might not exist or be open
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    group('User Story Acceptance Tests', () {
      group('US-001: User Authentication', () {
        test('Acceptance: As a user, I want to register an account so I can access the system', () async {
          // Given: A new user wants to access the system
          const email = 'newuser@example.com';
          const name = 'New User';
          const password = 'password123';

          // When: The user registers with valid information
          final user = await authService.register(email, name, password);

          // Then: The user account is created successfully
          expect(user, isA<UserModel>());
          expect(user.email, equals(email));
          expect(user.name, equals(name));
          expect(user.id, isNotEmpty);
        });

        test('Acceptance: As a user, I want to login to my account so I can access my data', () async {
          // Given: A registered user exists
          final user = await authService.register(
            'loginuser@example.com',
            'Login User',
            'password123',
          );

          // When: The user logs in with correct credentials
          final loginResult = await authService.login('loginuser@example.com', 'password123');

          // Then: The user is successfully logged in
          expect(loginResult, isTrue);
          
          final currentUser = await authService.getCurrentUser();
          expect(currentUser, isNotNull);
          expect(currentUser!.email, equals('loginuser@example.com'));
        });

        test('Acceptance: As a user, I want to logout so my session is secure', () async {
          // Given: A logged-in user
          await authService.register('logoutuser@example.com', 'Logout User', 'password123');
          await authService.login('logoutuser@example.com', 'password123');
          
          var currentUser = await authService.getCurrentUser();
          expect(currentUser, isNotNull);

          // When: The user logs out
          await authService.logout();

          // Then: The user session is terminated
          currentUser = await authService.getCurrentUser();
          expect(currentUser, isNull);
        });
      });

      group('US-002: Time Block Management', () {
        test('Acceptance: As a user, I want to create time blocks so I can schedule my activities', () async {
          // Given: A logged-in user
          await authService.register('timeblock@example.com', 'Time Block User', 'password123');
          await authService.login('timeblock@example.com', 'password123');

          // When: The user creates a time block
          final timeBlock = TimeBlockModel.create(
            title: 'Work Meeting',
            description: 'Weekly team meeting',
            startTime: DateTime(2023, 1, 2, 10, 0),
            endTime: DateTime(2023, 1, 2, 11, 0),
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.addTimeBlock(timeBlock);

          // Then: The time block is created and stored
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(allBlocks.length, equals(1));
          
          final createdBlock = allBlocks.first;
          expect(createdBlock.title, equals('Work Meeting'));
          expect(createdBlock.description, equals('Weekly team meeting'));
          expect(createdBlock.category, equals('Work'));
          expect(createdBlock.startTime.hour, equals(10));
          expect(createdBlock.endTime.hour, equals(11));
        });

        test('Acceptance: As a user, I want to update time blocks so I can modify my schedule', () async {
          // Given: A user with an existing time block
          await authService.register('update@example.com', 'Update User', 'password123');
          await authService.login('update@example.com', 'password123');

          // Use unique date for this test to avoid conflicts
          final testDate = DateTime(2023, 1, 3, 9, 0);
          final timeBlock = TimeBlockModel.create(
            title: 'Original Task',
            description: 'Original description',
            startTime: testDate,
            endTime: testDate.add(const Duration(hours: 1)),
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.addTimeBlock(timeBlock);

          // When: The user updates the time block
          final updatedBlock = timeBlock.copyWith(
            title: 'Updated Task',
            description: 'Updated description',
            isCompleted: true,
          );
          await timeBlockRepository.updateTimeBlock(updatedBlock);

          // Then: The time block is updated successfully
          // Filter by test date to avoid counting blocks from other tests
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day &&
            block.startTime.hour == testDate.hour
          ).toList();
          expect(testDateBlocks.length, equals(1),
              reason: 'Should have exactly 1 block for the test date');
          
          final retrievedBlock = testDateBlocks.first;
          expect(retrievedBlock.title, equals('Updated Task'));
          expect(retrievedBlock.description, equals('Updated description'));
          expect(retrievedBlock.isCompleted, isTrue);
        });

        test('Acceptance: As a user, I want to delete time blocks so I can remove unwanted items', () async {
          // Given: A user with multiple time blocks
          await authService.register('delete@example.com', 'Delete User', 'password123');
          await authService.login('delete@example.com', 'password123');

          // Use unique date for this test to avoid conflicts
          final testDate = DateTime(2023, 1, 4, 9, 0);
          final timeBlock1 = TimeBlockModel.create(
            title: 'Task 1',
            description: 'First task',
            startTime: testDate,
            endTime: testDate.add(const Duration(hours: 1)),
            category: 'Work',
            color: '#2196F3',
          );
          
          final timeBlock2 = TimeBlockModel.create(
            title: 'Task 2',
            description: 'Second task',
            startTime: testDate.add(const Duration(hours: 1)),
            endTime: testDate.add(const Duration(hours: 2)),
            category: 'Personal',
            color: '#4CAF50',
          );

          await timeBlockRepository.addTimeBlock(timeBlock1);
          await timeBlockRepository.addTimeBlock(timeBlock2);

          // Filter by test date to avoid counting blocks from other tests
          var allBlocks = await timeBlockRepository.getAllTimeBlocks();
          var testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          expect(testDateBlocks.length, equals(2),
              reason: 'Should have exactly 2 blocks for the test date');

          // When: The user deletes one time block
          await timeBlockRepository.deleteTimeBlock(timeBlock1.id);

          // Then: The time block is deleted
          allBlocks = await timeBlockRepository.getAllTimeBlocks();
          testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          expect(testDateBlocks.length, equals(1),
              reason: 'Should have exactly 1 block for the test date after deletion');
          expect(allBlocks.first.id, equals(timeBlock2.id));
        });
      });

      group('US-003: Habit Tracking', () {
        test('Acceptance: As a user, I want to create habits so I can track my daily routines', () async {
          // Given: A logged-in user
          await authService.register('habit@example.com', 'Habit User', 'password123');
          await authService.login('habit@example.com', 'password123');

          // When: The user creates a habit
          final habit = HabitModel.create(
            title: 'Daily Exercise',
            description: '30 minutes of exercise every day',
            daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
            category: 'Health',
            reminder: 'Morning',
            time: '07:00',
          );

          // Then: The habit is created successfully
          expect(habit, isA<HabitModel>());
          expect(habit.title, equals('Daily Exercise'));
          expect(habit.description, equals('30 minutes of exercise every day'));
          expect(habit.daysOfWeek, equals(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']));
          expect(habit.category, equals('Health'));
          expect(habit.reminder, equals('Morning'));
          expect(habit.time, equals('07:00'));
          expect(habit.streak, equals(0)); // Initial streak
          expect(habit.totalCompletions, equals(0)); // Initial completions
        });

        test('Acceptance: As a user, I want to track habit completion so I can monitor my progress', () async {
          // Given: A user with a habit
          await authService.register('track@example.com', 'Track User', 'password123');
          await authService.login('track@example.com', 'password123');

          final habit = HabitModel.create(
            title: 'Daily Reading',
            description: 'Read for 30 minutes',
            daysOfWeek: ['Everyday'],
            category: 'Learning',
            reminder: 'Evening',
            time: '20:00',
          );

          // When: The user marks the habit as completed
          final completedHabit = habit.copyWith(
            isCompleted: true,
            streak: 1,
            totalCompletions: 1,
            lastCompleted: DateTime.now(),
          );

          // Then: The habit completion is tracked
          expect(completedHabit.isCompleted, isTrue);
          expect(completedHabit.streak, equals(1));
          expect(completedHabit.totalCompletions, equals(1));
          expect(completedHabit.lastCompleted, isNotNull);
        });

        test('Acceptance: As a user, I want to see my habit streak so I can stay motivated', () async {
          // Given: A user with a habit that has been completed multiple times
          await authService.register('streak@example.com', 'Streak User', 'password123');
          await authService.login('streak@example.com', 'password123');

          final habit = HabitModel.create(
            title: 'Morning Meditation',
            description: '10 minutes of meditation',
            daysOfWeek: ['Everyday'],
            category: 'Wellness',
            reminder: 'Morning',
            time: '06:00',
          );

          // When: The user has maintained the habit for several days
          final streakHabit = habit.copyWith(
            streak: 7,
            totalCompletions: 7,
            isCompleted: true,
            lastCompleted: DateTime.now(),
          );

          // Then: The streak information is available
          expect(streakHabit.streak, equals(7));
          expect(streakHabit.totalCompletions, equals(7));
          expect(streakHabit.isCompleted, isTrue);
        });
      });

      group('US-004: Activity Management', () {
        test('Acceptance: As a user, I want to create activities so I can organize my tasks', () async {
          // Given: A logged-in user
          await authService.register('activity@example.com', 'Activity User', 'password123');
          await authService.login('activity@example.com', 'password123');

          // When: The user creates an activity
          final activity = ActivityModel(
            id: 'activity-1',
            title: 'Project Review',
            description: 'Review project progress and plan next steps',
            category: 'Work',
            startTime: DateTime(2023, 1, 2, 14, 0),
            endTime: DateTime(2023, 1, 2, 15, 0),
            priority: 'High',
            sendReminder: true,
            reminderMinutesBefore: 15,
            isCompleted: false,
          );

          // Then: The activity is created successfully
          expect(activity, isA<ActivityModel>());
          expect(activity.title, equals('Project Review'));
          expect(activity.description, equals('Review project progress and plan next steps'));
          expect(activity.category, equals('Work'));
          expect(activity.priority, equals('High'));
          expect(activity.sendReminder, isTrue);
          expect(activity.reminderMinutesBefore, equals(15));
          expect(activity.isCompleted, isFalse);
        });

        test('Acceptance: As a user, I want to mark activities as complete so I can track my progress', () async {
          // Given: A user with an activity
          await authService.register('complete@example.com', 'Complete User', 'password123');
          await authService.login('complete@example.com', 'password123');

          final activity = ActivityModel(
            id: 'activity-2',
            title: 'Team Meeting',
            description: 'Weekly team sync',
            category: 'Work',
            startTime: DateTime(2023, 1, 2, 10, 0),
            endTime: DateTime(2023, 1, 2, 11, 0),
            priority: 'Medium',
            sendReminder: true,
            reminderMinutesBefore: 10,
            isCompleted: false,
          );

          // When: The user completes the activity
          final completedActivity = activity.toggleCompletion();

          // Then: The activity is marked as completed
          expect(completedActivity.isCompleted, isTrue);
          expect(activity.isCompleted, isFalse); // Original should remain unchanged
        });

        test('Acceptance: As a user, I want to see overdue activities so I can prioritize my tasks', () async {
          // Given: A user with a past activity
          await authService.register('overdue@example.com', 'Overdue User', 'password123');
          await authService.login('overdue@example.com', 'password123');

          final pastTime = DateTime.now().subtract(const Duration(hours: 2));
          final activity = ActivityModel(
            id: 'activity-3',
            title: 'Overdue Task',
            description: 'This task is overdue',
            category: 'Work',
            startTime: pastTime.subtract(const Duration(hours: 1)),
            endTime: pastTime,
            priority: 'High',
            sendReminder: true,
            reminderMinutesBefore: 30,
            isCompleted: false,
          );

          // When: The user checks the activity status
          final isOverdue = activity.isOverdue;

          // Then: The system correctly identifies the activity as overdue
          expect(isOverdue, isTrue);
        });
      });

      group('US-005: Data Analysis and Reporting', () {
        test('Acceptance: As a user, I want to see my productivity statistics so I can understand my patterns', () async {
          // Given: A user with multiple time blocks and activities
          await authService.register('stats@example.com', 'Stats User', 'password123');
          await authService.login('stats@example.com', 'password123');

          // Use unique date for this test to avoid conflicts
          final testDate = DateTime(2023, 1, 5, 9, 0);
          final timeBlocks = [
            TimeBlockModel.create(
              title: 'Work Task 1',
              description: 'First work task',
              startTime: testDate,
              endTime: testDate.add(const Duration(hours: 1)),
              category: 'Work',
              color: '#2196F3',
              isCompleted: true,
            ),
            TimeBlockModel.create(
              title: 'Work Task 2',
              description: 'Second work task',
              startTime: testDate.add(const Duration(hours: 1)),
              endTime: testDate.add(const Duration(hours: 2)),
              category: 'Work',
              color: '#2196F3',
              isCompleted: false,
            ),
            TimeBlockModel.create(
              title: 'Personal Task',
              description: 'Personal task',
              startTime: testDate.add(const Duration(hours: 5)),
              endTime: testDate.add(const Duration(hours: 6)),
              category: 'Personal',
              color: '#4CAF50',
              isCompleted: true,
            ),
          ];

          for (final block in timeBlocks) {
            await timeBlockRepository.addTimeBlock(block);
          }

          // When: The user views their productivity statistics
          // Filter by test date to avoid counting blocks from other tests
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          
          final completedBlocks = testDateBlocks.where((block) => block.isCompleted).toList();
          final workBlocks = testDateBlocks.where((block) => block.category == 'Work').toList();
          final personalBlocks = testDateBlocks.where((block) => block.category == 'Personal').toList();

          final completionRate = (completedBlocks.length / testDateBlocks.length) * 100;
          final workCompletionRate = workBlocks.where((block) => block.isCompleted).length / workBlocks.length * 100;

          // Then: The statistics are calculated correctly
          expect(testDateBlocks.length, equals(3),
              reason: 'Should have exactly 3 blocks for the test date');
          expect(completedBlocks.length, equals(2));
          expect(workBlocks.length, equals(2));
          expect(personalBlocks.length, equals(1));
          expect(completionRate, closeTo(66.67, 0.01));
          expect(workCompletionRate, equals(50.0));
        });

        test('Acceptance: As a user, I want to export my data so I can analyze it externally', () async {
          // Given: A user with data in the system
          await authService.register('export@example.com', 'Export User', 'password123');
          await authService.login('export@example.com', 'password123');

          final timeBlocks = [
            TimeBlockModel.create(
              title: 'Export Task 1',
              description: 'First task for export',
              startTime: DateTime(2023, 1, 2, 9, 0),
              endTime: DateTime(2023, 1, 2, 10, 0),
              category: 'Work',
              color: '#2196F3',
              isCompleted: true,
            ),
            TimeBlockModel.create(
              title: 'Export Task 2',
              description: 'Second task for export',
              startTime: DateTime(2023, 1, 2, 10, 0),
              endTime: DateTime(2023, 1, 2, 11, 0),
              category: 'Personal',
              color: '#4CAF50',
              isCompleted: false,
            ),
          ];

          for (final block in timeBlocks) {
            await timeBlockRepository.addTimeBlock(block);
          }

          // When: The user exports their data
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final exportData = allBlocks.map((block) => {
            'id': block.id,
            'title': block.title,
            'description': block.description,
            'category': block.category,
            'start_time': block.startTime.toIso8601String(),
            'end_time': block.endTime.toIso8601String(),
            'duration_minutes': block.duration.inMinutes.toString(),
            'is_completed': block.isCompleted.toString(),
            'color': block.color,
          }).toList();

          final csvData = csvService.convertToCsv(exportData);

          // Then: The data is exported in a usable format
          expect(csvData, isNotEmpty);
          expect(csvData, contains('id,title,description,category,start_time,end_time,duration_minutes,is_completed,color'));
          expect(csvData, contains('Export Task 1'));
          expect(csvData, contains('Export Task 2'));
          expect(csvData, contains('Work'));
          expect(csvData, contains('Personal'));
          expect(csvData, contains('true'));
          expect(csvData, contains('false'));
        });
      });
    });

    group('Business Requirements Acceptance Tests', () {
      group('BR-001: Data Persistence', () {
        test('Acceptance: The system must persist user data across sessions', () async {
          // Given: A user with data in the system
          final user = await authService.register('persist@example.com', 'Persist User', 'password123');
          await authService.login('persist@example.com', 'password123');

          // Use unique date for this test to avoid conflicts
          final testDate = DateTime(2023, 1, 6, 9, 0);
          final timeBlock = TimeBlockModel.create(
            title: 'Persistent Task',
            description: 'This task should persist',
            startTime: testDate,
            endTime: testDate.add(const Duration(hours: 1)),
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.addTimeBlock(timeBlock);

          // When: The user logs out and logs back in
          await authService.logout();
          await authService.login('persist@example.com', 'password123');

          // Then: The user's data is still available
          final currentUser = await authService.getCurrentUser();
          expect(currentUser, isNotNull);
          expect(currentUser!.email, equals('persist@example.com'));

          // Filter by test date to avoid counting blocks from other tests
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          expect(testDateBlocks.length, equals(1),
              reason: 'Should have exactly 1 block for the test date');
          expect(testDateBlocks.first.title, equals('Persistent Task'));
        });

        test('Acceptance: The system must handle concurrent data access safely', () async {
          // Given: Multiple users accessing the system
          final users = <UserModel>[];
          for (int i = 0; i < 3; i++) {
            final user = await authService.register('concurrent$i@example.com', 'User $i', 'password123');
            users.add(user);
          }

          // When: All users create data simultaneously
          // Use unique date for this test to avoid conflicts
          final testDate = DateTime(2023, 1, 7, 9, 0);
          final timeBlockPromises = <Future<TimeBlockModel>>[];
          for (int i = 0; i < users.length; i++) {
            final timeBlock = TimeBlockModel.create(
              title: 'Concurrent Task $i',
              description: 'Task created by user $i',
              startTime: testDate.add(Duration(hours: i)),
              endTime: testDate.add(Duration(hours: i + 1)),
              category: 'Work',
              color: '#2196F3',
            );
            timeBlockPromises.add(
              timeBlockRepository.addTimeBlock(timeBlock).then((_) => timeBlock)
            );
          }

          final createdBlocks = await Future.wait(timeBlockPromises);

          // Then: All data is created without conflicts
          expect(createdBlocks.length, equals(3));
          
          // Filter by test date to avoid counting blocks from other tests
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          expect(testDateBlocks.length, equals(3),
              reason: 'Should have exactly 3 blocks for the test date');
          
          // Verify each user's data is unique
          final titles = testDateBlocks.map((block) => block.title).toList();
          expect(titles, contains('Concurrent Task 0'));
          expect(titles, contains('Concurrent Task 1'));
          expect(titles, contains('Concurrent Task 2'));
        });
      });

      group('BR-002: Performance Requirements', () {
        test('Acceptance: The system must respond to user actions within acceptable time limits', () async {
          // Given: A user interacting with the system
          final startTime = DateTime.now();
          
          // When: The user performs common operations
          final user = await authService.register('performance@example.com', 'Performance User', 'password123');
          final registrationTime = DateTime.now().difference(startTime);

          final loginStartTime = DateTime.now();
          await authService.login('performance@example.com', 'password123');
          final loginTime = DateTime.now().difference(loginStartTime);

          final createStartTime = DateTime.now();
          // Use unique date for this test to avoid conflicts
          final testDate = DateTime(2023, 1, 8, 9, 0);
          final timeBlock = TimeBlockModel.create(
            title: 'Performance Test Task',
            description: 'Task for performance testing',
            startTime: testDate,
            endTime: testDate.add(const Duration(hours: 1)),
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.addTimeBlock(timeBlock);
          final createTime = DateTime.now().difference(createStartTime);

          final retrieveStartTime = DateTime.now();
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final retrieveTime = DateTime.now().difference(retrieveStartTime);

          // Then: All operations complete within acceptable time limits
          expect(registrationTime.inMilliseconds, lessThan(1000)); // Registration should be fast
          expect(loginTime.inMilliseconds, lessThan(500)); // Login should be very fast
          expect(createTime.inMilliseconds, lessThan(100)); // Creation should be very fast
          expect(retrieveTime.inMilliseconds, lessThan(200)); // Retrieval should be fast
          
          // Filter by test date to avoid counting blocks from other tests
          final testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          expect(testDateBlocks.length, equals(1),
              reason: 'Should have exactly 1 block for the test date');
        });

        test('Acceptance: The system must handle large datasets efficiently', () async {
          // Given: A large dataset
          await authService.register('large@example.com', 'Large Dataset User', 'password123');
          await authService.login('large@example.com', 'password123');

          final largeDataset = <TimeBlockModel>[];
          for (int i = 0; i < 50; i++) {
            final timeBlock = TimeBlockModel.create(
              title: 'Large Dataset Task $i',
              description: 'Task $i in large dataset',
              startTime: DateTime(2023, 1, 2, 9 + (i % 12), 0),
              endTime: DateTime(2023, 1, 2, 10 + (i % 12), 0),
              category: i % 2 == 0 ? 'Work' : 'Personal',
              color: i % 2 == 0 ? '#2196F3' : '#4CAF50',
            );
            largeDataset.add(timeBlock);
          }

          // When: The system processes the large dataset
          final createStartTime = DateTime.now();
          for (final block in largeDataset) {
            await timeBlockRepository.addTimeBlock(block);
          }
          final createTime = DateTime.now().difference(createStartTime);

          final retrieveStartTime = DateTime.now();
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          final retrieveTime = DateTime.now().difference(retrieveStartTime);

          final filterStartTime = DateTime.now();
          final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
          final filterTime = DateTime.now().difference(filterStartTime);

          // Then: The system handles the large dataset efficiently
          // Filter by test date to avoid counting blocks from other tests
          final testDate = DateTime(2023, 1, 3);
          final testDateBlocks = allBlocks.where((block) => 
            block.startTime.year == testDate.year &&
            block.startTime.month == testDate.month &&
            block.startTime.day == testDate.day
          ).toList();
          expect(testDateBlocks.length, equals(50),
              reason: 'Should have exactly 50 blocks for the test date');
          expect(createTime.inMilliseconds, lessThan(2000)); // Should create 50 items quickly
          expect(retrieveTime.inMilliseconds, lessThan(500)); // Should retrieve 50 items quickly
          expect(filterTime.inMilliseconds, lessThan(100)); // Should filter quickly
          final testDateWorkBlocks = testDateBlocks.where((block) => block.category == 'Work').toList();
          expect(testDateWorkBlocks.length, equals(25)); // Half should be work tasks
        });
      });

      group('BR-003: Data Integrity', () {
        test('Acceptance: The system must maintain data consistency across all operations', () async {
          // Given: A user with data in the system
          await authService.register('integrity@example.com', 'Integrity User', 'password123');
          await authService.login('integrity@example.com', 'password123');

          final timeBlocks = <TimeBlockModel>[];
          for (int i = 0; i < 10; i++) {
            final timeBlock = TimeBlockModel.create(
              title: 'Integrity Task $i',
              description: 'Task for integrity testing',
              startTime: DateTime(2023, 1, 2, 9 + i, 0),
              endTime: DateTime(2023, 1, 2, 10 + i, 0),
              category: 'Work',
              color: '#2196F3',
            );
            timeBlocks.add(timeBlock);
            await timeBlockRepository.addTimeBlock(timeBlock);
          }

          // When: The user performs various operations
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(allBlocks.length, equals(10));

          // Update some blocks
          for (int i = 0; i < 5; i++) {
            final updatedBlock = allBlocks[i].copyWith(
              isCompleted: true,
              title: 'Updated Integrity Task $i',
            );
            await timeBlockRepository.updateTimeBlock(updatedBlock);
          }

          // Delete some blocks
          for (int i = 5; i < 7; i++) {
            await timeBlockRepository.deleteTimeBlock(allBlocks[i].id);
          }

          // Then: Data consistency is maintained
          final finalBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(finalBlocks.length, equals(8)); // 10 - 2 deleted = 8

          final completedBlocks = finalBlocks.where((block) => block.isCompleted).toList();
          final incompleteBlocks = finalBlocks.where((block) => !block.isCompleted).toList();
          
          expect(completedBlocks.length, equals(5)); // First 5 should be completed
          expect(incompleteBlocks.length, equals(3)); // Remaining 3 should be incomplete

          // Verify updated titles
          for (final block in completedBlocks) {
            expect(block.title, startsWith('Updated Integrity Task'));
          }

          // Verify original titles for incomplete blocks
          for (final block in incompleteBlocks) {
            expect(block.title, startsWith('Integrity Task'));
          }
        });

        test('Acceptance: The system must handle data validation correctly', () async {
          // Given: A user attempting to create data
          await authService.register('validation@example.com', 'Validation User', 'password123');
          await authService.login('validation@example.com', 'password123');

          // When: The user creates valid data
          final validTimeBlock = TimeBlockModel.create(
            title: 'Valid Task',
            description: 'This is a valid task with proper data',
            startTime: DateTime(2023, 1, 2, 9, 0),
            endTime: DateTime(2023, 1, 2, 10, 0),
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.addTimeBlock(validTimeBlock);

          // Then: The valid data is accepted
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(allBlocks.length, equals(1));
          expect(allBlocks.first.title, equals('Valid Task'));

          // When: The user attempts to create invalid data
          try {
            final invalidTimeBlock = TimeBlockModel(
              id: 'invalid',
              title: '', // Empty title
              description: 'Invalid task',
              startTime: DateTime(2023, 1, 2, 10, 0),
              endTime: DateTime(2023, 1, 2, 9, 0), // End before start
              category: 'Work',
              color: '#2196F3',
            );
            await timeBlockRepository.addTimeBlock(invalidTimeBlock);
          } catch (e) {
            // Then: Invalid data is rejected
            expect(e, isA<Exception>());
          }

          // Verify only valid data exists
          final finalBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(finalBlocks.length, equals(1));
        });
      });
    });

    group('Cross-Functional Acceptance Tests', () {
      test('Acceptance: Complete user journey from registration to data analysis', () async {
        // Step 1: User Registration
        final user = await authService.register(
          'journey@example.com',
          'Journey User',
          'password123',
        );
        expect(user.email, equals('journey@example.com'));

        // Step 2: User Login
        await authService.login('journey@example.com', 'password123');
        final currentUser = await authService.getCurrentUser();
        expect(currentUser, isNotNull);

        // Step 3: Create Habits
        final habits = [
          HabitModel.create(
            title: 'Morning Exercise',
            description: 'Daily 30-minute workout',
            daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
            category: 'Health',
            reminder: 'Morning',
            time: '07:00',
          ),
          HabitModel.create(
            title: 'Evening Reading',
            description: 'Read for 30 minutes',
            daysOfWeek: ['Everyday'],
            category: 'Learning',
            reminder: 'Evening',
            time: '20:00',
          ),
        ];

        // Step 4: Create Activities
        final activities = [
          ActivityModel(
            id: 'activity-1',
            title: 'Team Meeting',
            description: 'Weekly team sync',
            category: 'Work',
            startTime: DateTime(2023, 1, 2, 10, 0),
            endTime: DateTime(2023, 1, 2, 11, 0),
            priority: 'High',
            sendReminder: true,
            reminderMinutesBefore: 15,
          ),
          ActivityModel(
            id: 'activity-2',
            title: 'Project Review',
            description: 'Review project progress',
            category: 'Work',
            startTime: DateTime(2023, 1, 2, 14, 0),
            endTime: DateTime(2023, 1, 2, 15, 0),
            priority: 'Medium',
            sendReminder: true,
            reminderMinutesBefore: 10,
          ),
        ];

        // Step 5: Create Time Blocks from Habits and Activities
        final timeBlocks = <TimeBlockModel>[];
        
        // Convert habits to time blocks
        for (final habit in habits) {
          final timeBlock = TimeBlockModel.create(
            title: habit.title,
            description: habit.description,
            startTime: DateTime(2023, 1, 2, 7, 0),
            endTime: DateTime(2023, 1, 2, 7, 30),
            category: habit.category,
            color: '#4CAF50',
          );
          timeBlocks.add(timeBlock);
        }

        // Convert activities to time blocks
        for (final activity in activities) {
          final timeBlock = TimeBlockModel.create(
            title: activity.title,
            description: activity.description,
            startTime: activity.startTime,
            endTime: activity.endTime,
            category: activity.category,
            color: '#2196F3',
            isCompleted: activity.isCompleted,
          );
          timeBlocks.add(timeBlock);
        }

        // Create all time blocks
        for (final block in timeBlocks) {
          await timeBlockRepository.addTimeBlock(block);
        }

        // Step 6: Data Analysis
        // Filter blocks by the test date to avoid counting blocks from other tests
        final testDate = DateTime(2023, 1, 2);
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        final testDateBlocks = allBlocks.where((block) => 
          block.startTime.year == testDate.year &&
          block.startTime.month == testDate.month &&
          block.startTime.day == testDate.day
        ).toList();
        
        expect(testDateBlocks.length, equals(4),
            reason: 'Should have exactly 4 blocks for the test date');

        final workBlocks = testDateBlocks.where((block) => block.category == 'Work').toList();
        final healthBlocks = testDateBlocks.where((block) => block.category == 'Health').toList();
        final learningBlocks = testDateBlocks.where((block) => block.category == 'Learning').toList();

        expect(workBlocks.length, equals(2));
        expect(healthBlocks.length, equals(1));
        expect(learningBlocks.length, equals(1));

        // Step 7: Mark some tasks as completed
        final completedBlocks = <TimeBlockModel>[];
        for (int i = 0; i < 2; i++) {
          final completedBlock = allBlocks[i].markAsCompleted();
          await timeBlockRepository.updateTimeBlock(completedBlock);
          completedBlocks.add(completedBlock);
        }

        // Step 8: Generate statistics
        final finalBlocks = await timeBlockRepository.getAllTimeBlocks();
        final completedCount = finalBlocks.where((block) => block.isCompleted).length;
        final completionRate = (completedCount / finalBlocks.length) * 100;

        expect(completedCount, equals(2));
        expect(completionRate, equals(50.0));

        // Step 9: Export data
        final exportData = finalBlocks.map((block) => {
          'title': block.title,
          'category': block.category,
          'start_time': block.startTime.toIso8601String(),
          'end_time': block.endTime.toIso8601String(),
          'duration_minutes': block.duration.inMinutes.toString(),
          'is_completed': block.isCompleted.toString(),
        }).toList();

        final csvData = csvService.convertToCsv(exportData);
        expect(csvData, isNotEmpty);
        expect(csvData, contains('title,category,start_time,end_time,duration_minutes,is_completed'));
        expect(csvData, contains('Morning Exercise'));
        expect(csvData, contains('Team Meeting'));
        expect(csvData, contains('Project Review'));
        expect(csvData, contains('Evening Reading'));

        // Step 10: User Logout
        await authService.logout();
        final loggedOutUser = await authService.getCurrentUser();
        expect(loggedOutUser, isNull);
      });
    });
  });
}
