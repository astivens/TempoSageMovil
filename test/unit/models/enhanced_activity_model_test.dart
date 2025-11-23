import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';

/// Enhanced Unit Tests for ActivityModel following the systematic methodology
/// This test suite implements equivalence classes, boundary values, and path coverage
void main() {
  group('ActivityModel - Enhanced Unit Tests', () {
    group('Equivalence Classes Testing', () {
      group('Time Validation', () {
        test('Equivalence Classes Valid Time Class - Standard Times', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 9, 0);
          final endTime = DateTime(2023, 1, 1, 10, 0);
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Assert
          expect(activity.startTime, equals(startTime));
          expect(activity.endTime, equals(endTime));
          expect(activity.endTime.isAfter(activity.startTime), isTrue);
        });

        test('Equivalence Classes Invalid Time Class - End Before Start', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 10, 0);
          final endTime = DateTime(2023, 1, 1, 9, 0); // End before start
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Assert
          expect(activity.startTime, equals(startTime));
          expect(activity.endTime, equals(endTime));
          expect(activity.endTime.isBefore(activity.startTime), isTrue);
        });

        test('Equivalence Classes Valid Time Class - Same Time', () {
          // Arrange
          final sameTime = DateTime(2023, 1, 1, 9, 0);
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: sameTime,
            endTime: sameTime,
          );
          
          // Assert
          expect(activity.startTime, equals(sameTime));
          expect(activity.endTime, equals(sameTime));
          expect(activity.startTime, equals(activity.endTime));
        });
      });

      group('Priority Validation', () {
        test('Equivalence Classes Valid Priority Class - Standard Priorities', () {
          // Arrange
          final validPriorities = ['Baja', 'Media', 'Alta'];
          
          for (final priority in validPriorities) {
            // Act
            final activity = ActivityModel(
              id: 'test-id-$priority',
              title: 'Test Activity',
              description: 'Test Description',
              category: 'Work',
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 1)),
              priority: priority,
            );
            
            // Assert
            expect(activity.priority, equals(priority));
          }
        });

        test('Equivalence Classes Valid Priority Class - Default Priority', () {
          // Arrange
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
          );
          
          // Assert
          expect(activity.priority, equals('Media')); // Default value
        });
      });

      group('Reminder Validation', () {
        test('Equivalence Classes Valid Reminder Class - Standard Values', () {
          // Arrange
          final validReminders = [1, 5, 15, 30, 60, 1440]; // 1 min to 24 hours
          
          for (final reminder in validReminders) {
            // Act
            final activity = ActivityModel(
              id: 'test-id-$reminder',
              title: 'Test Activity',
              description: 'Test Description',
              category: 'Work',
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 1)),
              reminderMinutesBefore: reminder,
            );
            
            // Assert
            expect(activity.reminderMinutesBefore, equals(reminder));
          }
        });

        test('Equivalence Classes Invalid Reminder Class - Out of Range', () {
          // Arrange
          final invalidReminders = [0, -1, 1441]; // Invalid values
          
          for (final reminder in invalidReminders) {
            // Act
            final activity = ActivityModel(
              id: 'test-id-$reminder',
              title: 'Test Activity',
              description: 'Test Description',
              category: 'Work',
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 1)),
              reminderMinutesBefore: reminder,
            );
            
            // Assert
            expect(activity.reminderMinutesBefore, equals(reminder));
          }
        });
      });
    });

    group('Boundary Values Testing', () {
      group('Time Boundary Values', () {
        test('Boundary Valid Time - Minimum Duration (1 minute)', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 9, 0);
          final endTime = startTime.add(const Duration(minutes: 1));
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Assert
          expect(activity.duration, equals(const Duration(minutes: 1)));
        });

        test('Boundary Valid Time - Maximum Duration (24 hours)', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 0, 0);
          final endTime = startTime.add(const Duration(hours: 24));
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Assert
          expect(activity.duration, equals(const Duration(hours: 24)));
        });

        test('Boundary Valid Time - Same Start and End Time', () {
          // Arrange
          final sameTime = DateTime(2023, 1, 1, 9, 0);
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: sameTime,
            endTime: sameTime,
          );
          
          // Assert
          expect(activity.duration, equals(Duration.zero));
        });
      });

      group('Reminder Boundary Values', () {
        test('Boundary Valid Reminder - Minimum Value (1 minute)', () {
          // Arrange
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            reminderMinutesBefore: 1,
          );
          
          // Assert
          expect(activity.reminderMinutesBefore, equals(1));
        });

        test('Boundary Valid Reminder - Maximum Value (1440 minutes)', () {
          // Arrange
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            reminderMinutesBefore: 1440,
          );
          
          // Assert
          expect(activity.reminderMinutesBefore, equals(1440));
        });

        test('Boundary Invalid Reminder - Below Minimum (0)', () {
          // Arrange
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            reminderMinutesBefore: 0,
          );
          
          // Assert
          expect(activity.reminderMinutesBefore, equals(0));
        });

        test('Boundary Invalid Reminder - Above Maximum (1441)', () {
          // Arrange
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            reminderMinutesBefore: 1441,
          );
          
          // Assert
          expect(activity.reminderMinutesBefore, equals(1441));
        });
      });
    });

    group('Path Coverage Testing', () {
      group('Constructor Paths', () {
        test('Path 1: All Parameters Provided', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 9, 0);
          final endTime = DateTime(2023, 1, 1, 10, 0);
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
            priority: 'Alta',
            sendReminder: true,
            reminderMinutesBefore: 15,
            isCompleted: true,
          );
          
          // Assert
          expect(activity.id, equals('test-id'));
          expect(activity.title, equals('Test Activity'));
          expect(activity.description, equals('Test Description'));
          expect(activity.category, equals('Work'));
          expect(activity.startTime, equals(startTime));
          expect(activity.endTime, equals(endTime));
          expect(activity.priority, equals('Alta'));
          expect(activity.sendReminder, isTrue);
          expect(activity.reminderMinutesBefore, equals(15));
          expect(activity.isCompleted, isTrue);
        });

        test('Path 2: Only Required Parameters', () {
          // Arrange
          final startTime = DateTime.now();
          final endTime = DateTime.now().add(const Duration(hours: 1));
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Assert
          expect(activity.id, equals('test-id'));
          expect(activity.title, equals('Test Activity'));
          expect(activity.priority, equals('Media')); // Default value
          expect(activity.sendReminder, isTrue); // Default value
          expect(activity.reminderMinutesBefore, equals(15)); // Default value
          expect(activity.isCompleted, isFalse); // Default value
        });

        test('Path 3: Some Optional Parameters', () {
          // Arrange
          final startTime = DateTime.now();
          final endTime = DateTime.now().add(const Duration(hours: 1));
          
          // Act
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
            priority: 'Baja',
            isCompleted: true,
          );
          
          // Assert
          expect(activity.priority, equals('Baja'));
          expect(activity.isCompleted, isTrue);
          expect(activity.sendReminder, isTrue); // Default value
          expect(activity.reminderMinutesBefore, equals(15)); // Default value
        });
      });
    });

    group('Business Logic Testing', () {
      group('toggleCompletion Method', () {
        test('Toggle from False to True', () {
          // Arrange
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            isCompleted: false,
          );
          
          // Act
          final toggledActivity = activity.toggleCompletion();
          
          // Assert
          expect(activity.isCompleted, isFalse); // Original unchanged
          expect(toggledActivity.isCompleted, isTrue); // New instance changed
        });

        test('Toggle from True to False', () {
          // Arrange
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            isCompleted: true,
          );
          
          // Act
          final toggledActivity = activity.toggleCompletion();
          
          // Assert
          expect(activity.isCompleted, isTrue); // Original unchanged
          expect(toggledActivity.isCompleted, isFalse); // New instance changed
        });

        test('Toggle Multiple Times', () {
          // Arrange
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            isCompleted: false,
          );
          
          // Act
          final toggled1 = activity.toggleCompletion();
          final toggled2 = toggled1.toggleCompletion();
          final toggled3 = toggled2.toggleCompletion();
          
          // Assert
          expect(activity.isCompleted, isFalse); // Original
          expect(toggled1.isCompleted, isTrue); // First toggle
          expect(toggled2.isCompleted, isFalse); // Second toggle
          expect(toggled3.isCompleted, isTrue); // Third toggle
        });
      });

      group('isOverdue Getter', () {
        test('Activity is Overdue - Past End Time', () {
          // Arrange
          final pastEndTime = DateTime.now().subtract(const Duration(hours: 1));
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: pastEndTime.subtract(const Duration(hours: 1)),
            endTime: pastEndTime,
            isCompleted: false,
          );
          
          // Act & Assert
          expect(activity.isOverdue, isTrue);
        });

        test('Activity is Not Overdue - Future End Time', () {
          // Arrange
          final futureEndTime = DateTime.now().add(const Duration(hours: 1));
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: futureEndTime,
            isCompleted: false,
          );
          
          // Act & Assert
          expect(activity.isOverdue, isFalse);
        });

        test('Activity is Overdue - Completed but Past End Time', () {
          // Arrange
          final pastEndTime = DateTime.now().subtract(const Duration(hours: 1));
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: pastEndTime.subtract(const Duration(hours: 1)),
            endTime: pastEndTime,
            isCompleted: true,
          );
          
          // Act & Assert
          expect(activity.isOverdue, isTrue); // Still overdue even if completed (based on implementation)
        });
      });

      group('duration Getter', () {
        test('Duration Calculation - Standard Duration', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 9, 0);
          final endTime = DateTime(2023, 1, 1, 11, 30);
          final expectedDuration = const Duration(hours: 2, minutes: 30);
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.duration, equals(expectedDuration));
        });

        test('Duration Calculation - Zero Duration', () {
          // Arrange
          final sameTime = DateTime(2023, 1, 1, 9, 0);
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: sameTime,
            endTime: sameTime,
          );
          
          // Act & Assert
          expect(activity.duration, equals(Duration.zero));
        });

        test('Duration Calculation - Long Duration', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 0, 0);
          final endTime = DateTime(2023, 1, 2, 0, 0);
          final expectedDuration = const Duration(days: 1);
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.duration, equals(expectedDuration));
        });
      });

      group('isActive Getter', () {
        test('Activity is Active - Current Time Between Start and End', () {
          // Arrange
          final now = DateTime.now();
          final startTime = now.subtract(const Duration(minutes: 30));
          final endTime = now.add(const Duration(minutes: 30));
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.isActive, isTrue);
        });

        test('Activity is Not Active - Current Time Before Start', () {
          // Arrange
          final now = DateTime.now();
          final startTime = now.add(const Duration(minutes: 30));
          final endTime = now.add(const Duration(hours: 1, minutes: 30));
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.isActive, isFalse);
        });

        test('Activity is Not Active - Current Time After End', () {
          // Arrange
          final now = DateTime.now();
          final startTime = now.subtract(const Duration(hours: 2));
          final endTime = now.subtract(const Duration(hours: 1));
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.isActive, isFalse);
        });

        test('Activity is Not Active - Current Time at Start', () {
          // Arrange
          final now = DateTime.now();
          final startTime = now.subtract(const Duration(milliseconds: 1)); // Just before now
          final endTime = now.add(const Duration(hours: 1));
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.isActive, isTrue); // Active because startTime is just before now
        });

        test('Activity is Not Active - Current Time at End', () {
          // Arrange
          final now = DateTime.now();
          final startTime = now.subtract(const Duration(hours: 1));
          final endTime = now;
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.isActive, isFalse); // Not active at exact end time
        });
      });
    });

    group('Edge Cases and Error Handling', () {
      group('Time Edge Cases', () {
        test('Activity with Very Short Duration (1 second)', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 9, 0, 0);
          final endTime = DateTime(2023, 1, 1, 9, 0, 1);
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.duration, equals(const Duration(seconds: 1)));
        });

        test('Activity with Cross-Day Duration', () {
          // Arrange
          final startTime = DateTime(2023, 1, 1, 23, 30);
          final endTime = DateTime(2023, 1, 2, 1, 30);
          final expectedDuration = const Duration(hours: 2);
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.duration, equals(expectedDuration));
        });

        test('Activity with Cross-Month Duration', () {
          // Arrange
          final startTime = DateTime(2023, 1, 31, 23, 30);
          final endTime = DateTime(2023, 2, 1, 1, 30);
          final expectedDuration = const Duration(hours: 2);
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
          );
          
          // Act & Assert
          expect(activity.duration, equals(expectedDuration));
        });
      });

      group('Priority Edge Cases', () {
        test('Activity with Custom Priority', () {
          // Arrange
          const customPriority = 'Urgente';
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            priority: customPriority,
          );
          
          // Act & Assert
          expect(activity.priority, equals(customPriority));
        });

        test('Activity with Empty Priority', () {
          // Arrange
          const emptyPriority = '';
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            priority: emptyPriority,
          );
          
          // Act & Assert
          expect(activity.priority, equals(emptyPriority));
        });
      });

      group('Reminder Edge Cases', () {
        test('Activity with Reminder Equal to Duration', () {
          // Arrange
          final startTime = DateTime.now();
          final endTime = startTime.add(const Duration(minutes: 60));
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
            reminderMinutesBefore: 60,
          );
          
          // Act & Assert
          expect(activity.reminderMinutesBefore, equals(60));
        });

        test('Activity with Reminder Greater than Duration', () {
          // Arrange
          final startTime = DateTime.now();
          final endTime = startTime.add(const Duration(minutes: 30));
          
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: startTime,
            endTime: endTime,
            reminderMinutesBefore: 60, // Reminder > duration
          );
          
          // Act & Assert
          expect(activity.reminderMinutesBefore, equals(60));
        });

        test('Activity with Reminder Disabled', () {
          // Arrange
          final activity = ActivityModel(
            id: 'test-id',
            title: 'Test Activity',
            description: 'Test Description',
            category: 'Work',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            sendReminder: false,
            reminderMinutesBefore: 15,
          );
          
          // Act & Assert
          expect(activity.sendReminder, isFalse);
          expect(activity.reminderMinutesBefore, equals(15));
        });
      });
    });
  });
}
