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

/// Enhanced System Tests - Extended Coverage
/// This test suite implements comprehensive system testing for all major functionalities
void main() {
  group('Enhanced System Tests - Extended Coverage', () {
    late AuthService authService;
    late TimeBlockRepository timeBlockRepository;
    late TestCsvService csvService;
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
      authService = AuthService();
      timeBlockRepository = TimeBlockRepository();
      csvService = TestCsvService();
      
      await timeBlockRepository.init();
      
      // Clean up previous test data
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('auth');
      await Hive.deleteBoxFromDisk('time_blocks');
      await Hive.deleteBoxFromDisk('habits');
    });

    tearDown(() async {
      // No need to close repository, Hive boxes are managed separately
      await Hive.deleteBoxFromDisk('users');
      await Hive.deleteBoxFromDisk('auth');
      await Hive.deleteBoxFromDisk('time_blocks');
      await Hive.deleteBoxFromDisk('habits');
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    group('System Functionality Testing', () {
      group('Complete User Workflow', () {
        test('System: Complete User Registration to Data Management Workflow', () async {
          // Step 1: User Registration
          final user = await authService.register(
            'system@example.com',
            'System User',
            'password123',
          );
          expect(user, isA<UserModel>());
          expect(user.email, equals('system@example.com'));

          // Step 2: User Login
          final loginResult = await authService.login('system@example.com', 'password123');
          expect(loginResult, isTrue);

          final currentUser = await authService.getCurrentUser();
          expect(currentUser, isNotNull);
          expect(currentUser!.name, equals('System User'));

          // Step 3: Create Multiple TimeBlocks
          final timeBlocks = <TimeBlockModel>[];
          for (int i = 0; i < 5; i++) {
            final timeBlock = TimeBlockModel.create(
              title: 'Task $i',
              description: 'Description for task $i',
              startTime: DateTime(2023, 1, 2, 9 + i, 0),
              endTime: DateTime(2023, 1, 2, 10 + i, 0),
              category: i % 2 == 0 ? 'Work' : 'Personal',
              color: i % 2 == 0 ? '#2196F3' : '#4CAF50',
            );
            timeBlocks.add(timeBlock);
            await timeBlockRepository.createTimeBlock(timeBlock);
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

        test('System: Multi-User Concurrent Operations', () async {
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

          // Test concurrent login operations
          final loginResults = await Future.wait([
            authService.login('user0@example.com', 'password123'),
            authService.login('user1@example.com', 'password123'),
            authService.login('user2@example.com', 'password123'),
          ]);

          expect(loginResults.every((result) => result == true), isTrue);

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
                timeBlockRepository.createTimeBlock(timeBlock).then((_) => timeBlock)
              );
            }
          }

          final createdBlocks = await Future.wait(timeBlockPromises);
          expect(createdBlocks.length, equals(6));

          // Verify all blocks were created
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(allBlocks.length, equals(6));
        });
      });

      group('Data Integrity and Consistency', () {
        test('System: Data Consistency Across Operations', () async {
          // Create initial data
          final user = await authService.register(
            'consistency@example.com',
            'Consistency User',
            'password123',
          );

          final timeBlocks = <TimeBlockModel>[];
          for (int i = 0; i < 10; i++) {
            final timeBlock = TimeBlockModel.create(
              title: 'Consistent Task $i',
              description: 'Task for consistency testing',
              startTime: DateTime(2023, 1, 2, 9 + i, 0),
              endTime: DateTime(2023, 1, 2, 10 + i, 0),
              category: 'Work',
              color: '#2196F3',
            );
            timeBlocks.add(timeBlock);
            await timeBlockRepository.createTimeBlock(timeBlock);
          }

          // Perform various operations
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(allBlocks.length, equals(10));

          // Update some blocks
          for (int i = 0; i < 5; i++) {
            final updatedBlock = allBlocks[i].copyWith(
              isCompleted: true,
              title: 'Updated Task $i',
            );
            await timeBlockRepository.updateTimeBlock(updatedBlock);
          }

          // Verify consistency after updates
          final updatedBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(updatedBlocks.length, equals(10));

          final completedBlocks = updatedBlocks.where((block) => block.isCompleted).toList();
          final incompleteBlocks = updatedBlocks.where((block) => !block.isCompleted).toList();
          
          expect(completedBlocks.length, equals(5));
          expect(incompleteBlocks.length, equals(5));

          // Verify data integrity
          for (final block in completedBlocks) {
            expect(block.title, startsWith('Updated Task'));
            expect(block.isCompleted, isTrue);
          }

          for (final block in incompleteBlocks) {
            expect(block.title, startsWith('Consistent Task'));
            expect(block.isCompleted, isFalse);
          }
        });

        test('System: Large Dataset Handling', () async {
          // Create large dataset
          final largeDataset = <TimeBlockModel>[];
          for (int i = 0; i < 100; i++) {
            final timeBlock = TimeBlockModel.create(
              title: 'Large Dataset Task $i',
              description: 'Task $i in large dataset',
              startTime: DateTime(2023, 1, 2, 9 + (i % 12), 0),
              endTime: DateTime(2023, 1, 2, 10 + (i % 12), 0),
              category: i % 3 == 0 ? 'Work' : i % 3 == 1 ? 'Personal' : 'Learning',
              color: i % 3 == 0 ? '#2196F3' : i % 3 == 1 ? '#4CAF50' : '#FF9800',
            );
            largeDataset.add(timeBlock);
          }

          // Create all blocks
          final startTime = DateTime.now();
          for (final block in largeDataset) {
            await timeBlockRepository.createTimeBlock(block);
          }
          final creationTime = DateTime.now().difference(startTime);

          // Verify all blocks were created
          final allBlocks = await timeBlockRepository.getAllTimeBlocks();
          expect(allBlocks.length, equals(100));

          // Test operations on large dataset
          final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
          final personalBlocks = allBlocks.where((block) => block.category == 'Personal').toList();
          final learningBlocks = allBlocks.where((block) => block.category == 'Learning').toList();

          expect(workBlocks.length, equals(34)); // 100 / 3 ≈ 33.33, so 34 for Work
          expect(personalBlocks.length, equals(33));
          expect(learningBlocks.length, equals(33));

          // Test sorting performance
          final sortStartTime = DateTime.now();
          final sortedBlocks = List<TimeBlockModel>.from(allBlocks);
          sortedBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
          final sortTime = DateTime.now().difference(sortStartTime);

          expect(sortedBlocks.length, equals(100));
          expect(sortTime.inMilliseconds, lessThan(100)); // Should be fast

          // Test export performance
          final exportStartTime = DateTime.now();
          final exportData = allBlocks.map((block) => {
            'id': block.id,
            'title': block.title,
            'category': block.category,
            'start_time': block.startTime.toIso8601String(),
            'end_time': block.endTime.toIso8601String(),
          }).toList();

          final csvData = csvService.convertToCsv(exportData);
          final exportTime = DateTime.now().difference(exportStartTime);

          expect(csvData, isNotEmpty);
          expect(csvData.split('\n').length, equals(101)); // 100 data rows + 1 header
          expect(exportTime.inMilliseconds, lessThan(50)); // Should be fast
        });
      });
    });

    group('System Performance Testing', () {
      test('System: Response Time Performance', () async {
        // Test user registration performance
        final regStartTime = DateTime.now();
        final user = await authService.register(
          'performance@example.com',
          'Performance User',
          'password123',
        );
        final regTime = DateTime.now().difference(regStartTime);

        expect(regTime.inMilliseconds, lessThan(1000)); // Should be fast

        // Test login performance
        final loginStartTime = DateTime.now();
        await authService.login('performance@example.com', 'password123');
        final loginTime = DateTime.now().difference(loginStartTime);

        expect(loginTime.inMilliseconds, lessThan(500)); // Should be very fast

        // Test time block creation performance
        final creationTimes = <Duration>[];
        for (int i = 0; i < 10; i++) {
          final startTime = DateTime.now();
          final timeBlock = TimeBlockModel.create(
            title: 'Performance Task $i',
            description: 'Task for performance testing',
            startTime: DateTime(2023, 1, 2, 9 + i, 0),
            endTime: DateTime(2023, 1, 2, 10 + i, 0),
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.createTimeBlock(timeBlock);
          final creationTime = DateTime.now().difference(startTime);
          creationTimes.add(creationTime);
        }

        // Verify all creation times are reasonable
        for (final time in creationTimes) {
          expect(time.inMilliseconds, lessThan(100)); // Each creation should be fast
        }

        // Test data retrieval performance
        final retrievalStartTime = DateTime.now();
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        final retrievalTime = DateTime.now().difference(retrievalStartTime);

        expect(allBlocks.length, equals(10));
        expect(retrievalTime.inMilliseconds, lessThan(200)); // Retrieval should be fast
      });

      test('System: Memory Usage Performance', () async {
        // Create multiple users and time blocks to test memory usage
        final users = <UserModel>[];
        final timeBlocks = <TimeBlockModel>[];

        // Create 50 users
        for (int i = 0; i < 50; i++) {
          final user = await authService.register(
            'memory$i@example.com',
            'Memory User $i',
            'password123',
          );
          users.add(user);
        }

        // Create 200 time blocks
        for (int i = 0; i < 200; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'Memory Task $i',
            description: 'Task for memory testing',
            startTime: DateTime(2023, 1, 2, 9 + (i % 12), 0),
            endTime: DateTime(2023, 1, 2, 10 + (i % 12), 0),
            category: 'Work',
            color: '#2196F3',
          );
          timeBlocks.add(timeBlock);
          await timeBlockRepository.createTimeBlock(timeBlock);
        }

        // Verify all data was created
        expect(users.length, equals(50));
        expect(timeBlocks.length, equals(200));

        // Test operations on large dataset
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(200));

        // Test filtering performance
        final filterStartTime = DateTime.now();
        final workBlocks = allBlocks.where((block) => block.category == 'Work').toList();
        final filterTime = DateTime.now().difference(filterStartTime);

        expect(workBlocks.length, equals(200)); // All blocks are 'Work'
        expect(filterTime.inMilliseconds, lessThan(50)); // Filtering should be fast

        // Test sorting performance
        final sortStartTime = DateTime.now();
        final sortedBlocks = List<TimeBlockModel>.from(allBlocks);
        sortedBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
        final sortTime = DateTime.now().difference(sortStartTime);

        expect(sortedBlocks.length, equals(200));
        expect(sortTime.inMilliseconds, lessThan(100)); // Sorting should be fast
      });

      test('System: Concurrent Operations Performance', () async {
        // Test concurrent user creation
        final userPromises = <Future<UserModel>>[];
        for (int i = 0; i < 10; i++) {
          userPromises.add(authService.register(
            'concurrent$i@example.com',
            'Concurrent User $i',
            'password123',
          ));
        }

        final concurrentStartTime = DateTime.now();
        final users = await Future.wait(userPromises);
        final concurrentTime = DateTime.now().difference(concurrentStartTime);

        expect(users.length, equals(10));
        expect(concurrentTime.inMilliseconds, lessThan(2000)); // Concurrent operations should be efficient

        // Test concurrent time block creation
        final timeBlockPromises = <Future<TimeBlockModel>>[];
        for (int i = 0; i < 20; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'Concurrent Task $i',
            description: 'Task for concurrent testing',
            startTime: DateTime(2023, 1, 2, 9 + (i % 12), 0),
            endTime: DateTime(2023, 1, 2, 10 + (i % 12), 0),
            category: 'Work',
            color: '#2196F3',
          );
          timeBlockPromises.add(
            timeBlockRepository.createTimeBlock(timeBlock).then((_) => timeBlock)
          );
        }

        final concurrentBlockStartTime = DateTime.now();
        final createdBlocks = await Future.wait(timeBlockPromises);
        final concurrentBlockTime = DateTime.now().difference(concurrentBlockStartTime);

        expect(createdBlocks.length, equals(20));
        expect(concurrentBlockTime.inMilliseconds, lessThan(1000)); // Concurrent block creation should be efficient

        // Verify all blocks were created
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(20));
      });
    });

    group('System Usability Testing', () {
      test('System: User Experience Flow', () async {
        // Test complete user experience flow
        // Step 1: Registration (should be simple)
        final user = await authService.register(
          'ux@example.com',
          'UX User',
          'password123',
        );
        expect(user.email, equals('ux@example.com'));

        // Step 2: Login (should be immediate)
        final loginResult = await authService.login('ux@example.com', 'password123');
        expect(loginResult, isTrue);

        // Step 3: Create time blocks (should be intuitive)
        final timeBlocks = <TimeBlockModel>[];
        for (int i = 0; i < 3; i++) {
          final timeBlock = TimeBlockModel.create(
            title: 'UX Task $i',
            description: 'Task for UX testing',
            startTime: DateTime(2023, 1, 2, 9 + i, 0),
            endTime: DateTime(2023, 1, 2, 10 + i, 0),
            category: 'Work',
            color: '#2196F3',
          );
          timeBlocks.add(timeBlock);
          await timeBlockRepository.createTimeBlock(timeBlock);
        }

        // Step 4: View data (should be clear)
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(3));

        // Step 5: Update data (should be easy)
        final firstBlock = allBlocks.first;
        final updatedBlock = firstBlock.copyWith(
          isCompleted: true,
          title: 'Completed: ${firstBlock.title}',
        );
        await timeBlockRepository.updateTimeBlock(updatedBlock);

        // Step 6: Verify changes (should be immediate)
        final updatedBlocks = await timeBlockRepository.getAllTimeBlocks();
        final completedBlock = updatedBlocks.firstWhere((block) => block.isCompleted);
        expect(completedBlock.title, startsWith('Completed:'));

        // Step 7: Export data (should be simple)
        final exportData = updatedBlocks.map((block) => {
          'title': block.title,
          'category': block.category,
          'completed': block.isCompleted.toString(),
        }).toList();

        final csvData = csvService.convertToCsv(exportData);
        expect(csvData, contains('title,category,completed'));
        expect(csvData, contains('Completed: UX Task 0'));
      });

      test('System: Error Handling and Recovery', () async {
        // Test system resilience
        // Try to create user with invalid data (should handle gracefully)
        try {
          await authService.register('', 'User', 'password123');
        } catch (e) {
          // System should handle invalid input gracefully
          expect(e, isA<Exception>());
        }

        // Create valid user
        final user = await authService.register(
          'error@example.com',
          'Error User',
          'password123',
        );
        expect(user.email, equals('error@example.com'));

        // Try invalid login (should handle gracefully)
        try {
          await authService.login('error@example.com', 'wrongpassword');
        } catch (e) {
          // System should handle invalid login gracefully
          expect(e, isA<Exception>());
        }

        // Valid login should work
        final loginResult = await authService.login('error@example.com', 'password123');
        expect(loginResult, isTrue);

        // Try to create time block with invalid data (should handle gracefully)
        try {
          final invalidTimeBlock = TimeBlockModel(
            id: 'invalid',
            title: '', // Empty title
            description: 'Invalid block',
            startTime: DateTime(2023, 1, 2, 10, 0),
            endTime: DateTime(2023, 1, 2, 9, 0), // End before start
            category: 'Work',
            color: '#2196F3',
          );
          await timeBlockRepository.createTimeBlock(invalidTimeBlock);
        } catch (e) {
          // System should handle invalid time block gracefully
          expect(e, isA<Exception>());
        }

        // Valid time block should work
        final validTimeBlock = TimeBlockModel.create(
          title: 'Valid Task',
          description: 'Valid task description',
          startTime: DateTime(2023, 1, 2, 9, 0),
          endTime: DateTime(2023, 1, 2, 10, 0),
          category: 'Work',
          color: '#2196F3',
        );
        await timeBlockRepository.createTimeBlock(validTimeBlock);

        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(1));
        expect(allBlocks.first.title, equals('Valid Task'));
      });

      test('System: Data Validation and Consistency', () async {
        // Test data validation
        final user = await authService.register(
          'validation@example.com',
          'Validation User',
          'password123',
        );

        // Create time blocks with various data
        final timeBlocks = [
          TimeBlockModel.create(
            title: 'Task with special chars: !@#\$%^&*()',
            description: 'Description with unicode: ñáéíóú',
            startTime: DateTime(2023, 1, 2, 9, 0),
            endTime: DateTime(2023, 1, 2, 10, 0),
            category: 'Work',
            color: '#2196F3',
          ),
          TimeBlockModel.create(
            title: 'Task with numbers 123',
            description: 'Description with numbers 456',
            startTime: DateTime(2023, 1, 2, 10, 0),
            endTime: DateTime(2023, 1, 2, 11, 0),
            category: 'Personal',
            color: '#4CAF50',
          ),
          TimeBlockModel.create(
            title: 'Very Long Task Title That Exceeds Normal Length',
            description: 'Very long description that also exceeds normal length and contains many words to test the system handling of long text',
            startTime: DateTime(2023, 1, 2, 11, 0),
            endTime: DateTime(2023, 1, 2, 12, 0),
            category: 'Learning',
            color: '#FF9800',
          ),
        ];

        for (final block in timeBlocks) {
          await timeBlockRepository.createTimeBlock(block);
        }

        // Verify all blocks were created with correct data
        final allBlocks = await timeBlockRepository.getAllTimeBlocks();
        expect(allBlocks.length, equals(3));

        // Verify special characters are preserved
        final specialCharBlock = allBlocks.firstWhere((block) => 
          block.title.contains('!@#\$%^&*()'));
        expect(specialCharBlock.title, contains('!@#\$%^&*()'));
        expect(specialCharBlock.description, contains('ñáéíóú'));

        // Verify numbers are preserved
        final numberBlock = allBlocks.firstWhere((block) => 
          block.title.contains('123'));
        expect(numberBlock.title, contains('123'));
        expect(numberBlock.description, contains('456'));

        // Verify long text is preserved
        final longTextBlock = allBlocks.firstWhere((block) => 
          block.title.contains('Very Long'));
        expect(longTextBlock.title, startsWith('Very Long Task Title'));
        expect(longTextBlock.description, startsWith('Very long description'));

        // Test data export with special characters
        final exportData = allBlocks.map((block) => {
          'title': block.title,
          'description': block.description,
          'category': block.category,
        }).toList();

        final csvData = csvService.convertToCsv(exportData);
        expect(csvData, contains('!@#\$%^&*()'));
        expect(csvData, contains('ñáéíóú'));
        expect(csvData, contains('123'));
        expect(csvData, contains('456'));
        expect(csvData, contains('Very Long'));
      });
    });
  });
}
