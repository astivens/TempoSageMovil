import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:flutter/material.dart';

/// Enhanced Unit Tests for HabitModel following the systematic methodology
/// This test suite implements equivalence classes, boundary values, and path coverage
void main() {
  group('HabitModel - Enhanced Unit Tests', () {
    group('Equivalence Classes Testing', () {
      group('ID Validation', () {
        test('Equivalence Classes Valid ID Class - Standard UUID', () {
          // Arrange
          const validId = '123e4567-e89b-12d3-a456-426614174000';
          
          // Act
          final habit = HabitModel(
            id: validId,
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.id, equals(validId));
          expect(habit.id, isA<String>());
          expect(habit.id.length, greaterThan(0));
        });

        test('Equivalence Classes Invalid ID Class - Empty String', () {
          // Arrange & Act & Assert
          expect(() {
            HabitModel(
              id: '',
              title: 'Test Habit',
              description: 'Test Description',
              daysOfWeek: ['Monday'],
              category: 'Health',
              reminder: 'Morning',
              time: '09:00',
              isCompleted: false,
              dateCreation: DateTime.now(),
            );
          }, returnsNormally); // HabitModel allows empty ID, but it's not recommended
        });
      });

      group('Title Validation', () {
        test('Equivalence Classes Valid Title Class - Standard Length', () {
          // Arrange
          const validTitle = 'Exercise Daily';
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: validTitle,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(validTitle));
          expect(habit.title.length, greaterThan(0));
          expect(habit.title.length, lessThanOrEqualTo(100));
        });

        test('Equivalence Classes Invalid Title Class - Too Long', () {
          // Arrange
          final longTitle = 'A' * 101; // 101 characters
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: longTitle,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(longTitle));
          expect(habit.title.length, equals(101));
        });

        test('Equivalence Classes Valid Title Class - Empty String', () {
          // Arrange & Act
          final habit = HabitModel(
            id: 'test-id',
            title: '',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(''));
        });
      });

      group('Days of Week Validation', () {
        test('Equivalence Classes Valid Days Class - Standard Days', () {
          // Arrange
          const validDays = ['Monday', 'Wednesday', 'Friday'];
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: validDays,
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.daysOfWeek, equals(validDays));
          expect(habit.daysOfWeek.length, equals(3));
        });

        test('Equivalence Classes Invalid Days Class - Empty List', () {
          // Arrange
          const emptyDays = <String>[];
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: emptyDays,
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.daysOfWeek, equals(emptyDays));
          expect(habit.daysOfWeek.isEmpty, isTrue);
        });

        test('Equivalence Classes Valid Days Class - All Days', () {
          // Arrange
          const allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: allDays,
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.daysOfWeek, equals(allDays));
          expect(habit.daysOfWeek.length, equals(7));
        });
      });

      group('Streak Validation', () {
        test('Equivalence Classes Valid Streak Class - Standard Values', () {
          // Arrange
          const validStreak = 30;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: validStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(validStreak));
          expect(habit.streak, greaterThanOrEqualTo(0));
          expect(habit.streak, lessThanOrEqualTo(365));
        });

        test('Equivalence Classes Invalid Streak Class - Negative Values', () {
          // Arrange
          const negativeStreak = -1;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: negativeStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(negativeStreak));
        });

        test('Equivalence Classes Invalid Streak Class - Too High', () {
          // Arrange
          const highStreak = 366;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: highStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(highStreak));
        });
      });
    });

    group('Boundary Values Testing', () {
      group('Title Boundary Values', () {
        test('Boundary Valid Title - Minimum Length (1 character)', () {
          // Arrange
          const minTitle = 'A';
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: minTitle,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(minTitle));
          expect(habit.title.length, equals(1));
        });

        test('Boundary Valid Title - Maximum Length (100 characters)', () {
          // Arrange
          final maxTitle = 'A' * 100;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: maxTitle,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(maxTitle));
          expect(habit.title.length, equals(100));
        });

        test('Boundary Invalid Title - Empty String (0 characters)', () {
          // Arrange
          const emptyTitle = '';
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: emptyTitle,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(emptyTitle));
          expect(habit.title.length, equals(0));
        });

        test('Boundary Invalid Title - Too Long (101 characters)', () {
          // Arrange
          final tooLongTitle = 'A' * 101;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: tooLongTitle,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(tooLongTitle));
          expect(habit.title.length, equals(101));
        });
      });

      group('Streak Boundary Values', () {
        test('Boundary Valid Streak - Minimum Value (0)', () {
          // Arrange
          const minStreak = 0;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: minStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(minStreak));
        });

        test('Boundary Valid Streak - Maximum Value (365)', () {
          // Arrange
          const maxStreak = 365;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: maxStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(maxStreak));
        });

        test('Boundary Invalid Streak - Below Minimum (-1)', () {
          // Arrange
          const belowMinStreak = -1;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: belowMinStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(belowMinStreak));
        });

        test('Boundary Invalid Streak - Above Maximum (366)', () {
          // Arrange
          const aboveMaxStreak = 366;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            streak: aboveMaxStreak,
            totalCompletions: 0,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.streak, equals(aboveMaxStreak));
        });
      });
    });

    group('Path Coverage Testing', () {
      group('Constructor Paths', () {
        test('Path 1: All Parameters Provided', () {
          // Arrange
          final now = DateTime.now();
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday', 'Wednesday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: true,
            lastCompleted: now,
            streak: 5,
            totalCompletions: 10,
            dateCreation: now,
          );
          
          // Assert
          expect(habit.id, equals('test-id'));
          expect(habit.title, equals('Test Habit'));
          expect(habit.description, equals('Test Description'));
          expect(habit.daysOfWeek, equals(['Monday', 'Wednesday']));
          expect(habit.category, equals('Health'));
          expect(habit.reminder, equals('Morning'));
          expect(habit.time, equals('09:00'));
          expect(habit.isCompleted, isTrue);
          expect(habit.lastCompleted, equals(now));
          expect(habit.streak, equals(5));
          expect(habit.totalCompletions, equals(10));
          expect(habit.dateCreation, equals(now));
        });

        test('Path 2: Only Required Parameters', () {
          // Arrange
          final now = DateTime.now();
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: now,
          );
          
          // Assert
          expect(habit.id, equals('test-id'));
          expect(habit.title, equals('Test Habit'));
          expect(habit.isCompleted, isFalse);
          expect(habit.lastCompleted, isNull);
          expect(habit.streak, equals(0)); // Default value
          expect(habit.totalCompletions, equals(0)); // Default value
        });

        test('Path 3: Some Optional Parameters', () {
          // Arrange
          final now = DateTime.now();
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: true,
            streak: 3,
            totalCompletions: 5,
            dateCreation: now,
          );
          
          // Assert
          expect(habit.isCompleted, isTrue);
          expect(habit.lastCompleted, isNull); // Not provided
          expect(habit.streak, equals(3));
          expect(habit.totalCompletions, equals(5));
        });
      });

      group('Factory Constructor Paths', () {
        test('Path 1: Factory Create with All Parameters', () {
          // Arrange
          const title = 'Exercise';
          const description = 'Daily exercise routine';
          const daysOfWeek = ['Monday', 'Wednesday', 'Friday'];
          const category = 'Health';
          const reminder = 'Morning';
          const time = '07:00';
          
          // Act
          final habit = HabitModel.create(
            title: title,
            description: description,
            daysOfWeek: daysOfWeek,
            category: category,
            reminder: reminder,
            time: time,
          );
          
          // Assert
          expect(habit.title, equals(title));
          expect(habit.description, equals(description));
          expect(habit.daysOfWeek, equals(daysOfWeek));
          expect(habit.category, equals(category));
          expect(habit.reminder, equals(reminder));
          expect(habit.time, equals(time));
          expect(habit.id, isNotEmpty);
          expect(habit.isCompleted, isFalse); // Default value
          expect(habit.dateCreation, isA<DateTime>());
        });

        test('Path 2: Factory Create with Minimal Parameters', () {
          // Arrange
          const title = 'Read';
          const description = '';
          const daysOfWeek = ['Sunday'];
          const category = 'Learning';
          const reminder = '';
          const time = '20:00';
          
          // Act
          final habit = HabitModel.create(
            title: title,
            description: description,
            daysOfWeek: daysOfWeek,
            category: category,
            reminder: reminder,
            time: time,
          );
          
          // Assert
          expect(habit.title, equals(title));
          expect(habit.description, equals(description));
          expect(habit.daysOfWeek, equals(daysOfWeek));
          expect(habit.category, equals(category));
          expect(habit.reminder, equals(reminder));
          expect(habit.time, equals(time));
          expect(habit.id, isNotEmpty);
          expect(habit.isCompleted, isFalse);
        });
      });

      group('copyWith Method Paths', () {
        test('Path 1: Copy with All Parameters Changed', () {
          // Arrange
          final originalHabit = HabitModel(
            id: 'original-id',
            title: 'Original Title',
            description: 'Original Description',
            daysOfWeek: ['Monday'],
            category: 'Original Category',
            reminder: 'Original Reminder',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Act
          final copiedHabit = originalHabit.copyWith(
            id: 'new-id',
            title: 'New Title',
            description: 'New Description',
            daysOfWeek: ['Tuesday', 'Thursday'],
            category: 'New Category',
            reminder: 'New Reminder',
            time: '10:00',
            isCompleted: true,
            streak: 5,
            totalCompletions: 10,
          );
          
          // Assert
          expect(copiedHabit.id, equals('new-id'));
          expect(copiedHabit.title, equals('New Title'));
          expect(copiedHabit.description, equals('New Description'));
          expect(copiedHabit.daysOfWeek, equals(['Tuesday', 'Thursday']));
          expect(copiedHabit.category, equals('New Category'));
          expect(copiedHabit.reminder, equals('New Reminder'));
          expect(copiedHabit.time, equals('10:00'));
          expect(copiedHabit.isCompleted, isTrue);
          expect(copiedHabit.streak, equals(5));
          expect(copiedHabit.totalCompletions, equals(10));
          
          // Original should remain unchanged
          expect(originalHabit.id, equals('original-id'));
          expect(originalHabit.title, equals('Original Title'));
        });

        test('Path 2: Copy with No Parameters Changed', () {
          // Arrange
          final originalHabit = HabitModel(
            id: 'original-id',
            title: 'Original Title',
            description: 'Original Description',
            daysOfWeek: ['Monday'],
            category: 'Original Category',
            reminder: 'Original Reminder',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Act
          final copiedHabit = originalHabit.copyWith();
          
          // Assert
          expect(copiedHabit.id, equals(originalHabit.id));
          expect(copiedHabit.title, equals(originalHabit.title));
          expect(copiedHabit.description, equals(originalHabit.description));
          expect(copiedHabit.daysOfWeek, equals(originalHabit.daysOfWeek));
          expect(copiedHabit.category, equals(originalHabit.category));
          expect(copiedHabit.reminder, equals(originalHabit.reminder));
          expect(copiedHabit.time, equals(originalHabit.time));
          expect(copiedHabit.isCompleted, equals(originalHabit.isCompleted));
        });

        test('Path 3: Copy with Some Parameters Changed', () {
          // Arrange
          final originalHabit = HabitModel(
            id: 'original-id',
            title: 'Original Title',
            description: 'Original Description',
            daysOfWeek: ['Monday'],
            category: 'Original Category',
            reminder: 'Original Reminder',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Act
          final copiedHabit = originalHabit.copyWith(
            title: 'New Title',
            isCompleted: true,
            streak: 3,
          );
          
          // Assert
          expect(copiedHabit.id, equals(originalHabit.id)); // Unchanged
          expect(copiedHabit.title, equals('New Title')); // Changed
          expect(copiedHabit.description, equals(originalHabit.description)); // Unchanged
          expect(copiedHabit.daysOfWeek, equals(originalHabit.daysOfWeek)); // Unchanged
          expect(copiedHabit.category, equals(originalHabit.category)); // Unchanged
          expect(copiedHabit.reminder, equals(originalHabit.reminder)); // Unchanged
          expect(copiedHabit.time, equals(originalHabit.time)); // Unchanged
          expect(copiedHabit.isCompleted, isTrue); // Changed
          expect(copiedHabit.streak, equals(3)); // Changed
        });
      });
    });

    group('Business Logic Testing', () {
      group('Data Validation', () {
        test('Valid Habit Creation with All Fields', () {
          // Arrange
          final now = DateTime.now();
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Daily Exercise',
            description: '30 minutes of cardio',
            daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
            category: 'Health',
            reminder: 'Morning',
            time: '07:00',
            isCompleted: false,
            lastCompleted: null,
            streak: 0,
            totalCompletions: 0,
            dateCreation: now,
          );
          
          // Assert
          expect(habit.id, isNotEmpty);
          expect(habit.title, isNotEmpty);
          expect(habit.daysOfWeek, isNotEmpty);
          expect(habit.category, isNotEmpty);
          expect(habit.reminder, isNotEmpty);
          expect(habit.time, isNotEmpty);
          expect(habit.dateCreation, isA<DateTime>());
        });

        test('Habit with Completed Status', () {
          // Arrange
          final now = DateTime.now();
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Daily Reading',
            description: 'Read for 30 minutes',
            daysOfWeek: ['Everyday'],
            category: 'Learning',
            reminder: 'Evening',
            time: '20:00',
            isCompleted: true,
            lastCompleted: now,
            streak: 5,
            totalCompletions: 10,
            dateCreation: now,
          );
          
          // Assert
          expect(habit.isCompleted, isTrue);
          expect(habit.lastCompleted, equals(now));
          expect(habit.streak, equals(5));
          expect(habit.totalCompletions, equals(10));
        });

        test('Habit with Different Categories', () {
          // Arrange
          final categories = ['Health', 'Learning', 'Work', 'Personal', 'Social'];
          
          for (final category in categories) {
            // Act
            final habit = HabitModel(
              id: 'test-id-$category',
              title: 'Test Habit',
              description: 'Test Description',
              daysOfWeek: ['Monday'],
              category: category,
              reminder: 'Morning',
              time: '09:00',
              isCompleted: false,
              dateCreation: DateTime.now(),
            );
            
            // Assert
            expect(habit.category, equals(category));
          }
        });

        test('Habit with Different Time Formats', () {
          // Arrange
          final timeFormats = ['00:00', '12:00', '23:59', '09:30', '15:45'];
          
          for (final time in timeFormats) {
            // Act
            final habit = HabitModel(
              id: 'test-id-$time',
              title: 'Test Habit',
              description: 'Test Description',
              daysOfWeek: ['Monday'],
              category: 'Health',
              reminder: 'Morning',
              time: time,
              isCompleted: false,
              dateCreation: DateTime.now(),
            );
            
            // Assert
            expect(habit.time, equals(time));
          }
        });
      });

      group('Edge Cases and Error Handling', () {
        test('Habit with Special Characters in Title', () {
          // Arrange
          const titleWithSpecialChars = 'Hábito con acéntos y ñ!@#\$%^&*()';
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: titleWithSpecialChars,
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.title, equals(titleWithSpecialChars));
        });

        test('Habit with Very Long Description', () {
          // Arrange
          final longDescription = 'A' * 500;
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: longDescription,
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.description, equals(longDescription));
          expect(habit.description.length, equals(500));
        });

        test('Habit with Empty Days List', () {
          // Arrange
          const emptyDays = <String>[];
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: emptyDays,
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.daysOfWeek, equals(emptyDays));
          expect(habit.daysOfWeek.isEmpty, isTrue);
        });

        test('Habit with Future Creation Date', () {
          // Arrange
          final futureDate = DateTime.now().add(const Duration(days: 30));
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: false,
            dateCreation: futureDate,
          );
          
          // Assert
          expect(habit.dateCreation, equals(futureDate));
          expect(habit.dateCreation.isAfter(DateTime.now()), isTrue);
        });

        test('Habit with Past Last Completed Date', () {
          // Arrange
          final pastDate = DateTime.now().subtract(const Duration(days: 7));
          
          // Act
          final habit = HabitModel(
            id: 'test-id',
            title: 'Test Habit',
            description: 'Test Description',
            daysOfWeek: ['Monday'],
            category: 'Health',
            reminder: 'Morning',
            time: '09:00',
            isCompleted: true,
            lastCompleted: pastDate,
            dateCreation: DateTime.now(),
          );
          
          // Assert
          expect(habit.lastCompleted, equals(pastDate));
          expect(habit.lastCompleted!.isBefore(DateTime.now()), isTrue);
        });
      });
    });
  });
}
