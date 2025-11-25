import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

void main() {
  group('Habit Entity', () {
    test('debería crear una instancia de Habit con todos los campos', () {
      // Arrange
      final now = DateTime.now();
      final habit = Habit(
        id: 'test-id',
        name: 'Test Habit',
        description: 'Test Description',
        daysOfWeek: ['Monday', 'Wednesday'],
        category: 'Health',
        reminder: 'enabled',
        time: '08:00',
        isDone: false,
        dateCreation: now,
      );

      // Assert
      expect(habit.id, equals('test-id'));
      expect(habit.name, equals('Test Habit'));
      expect(habit.description, equals('Test Description'));
      expect(habit.daysOfWeek, equals(['Monday', 'Wednesday']));
      expect(habit.category, equals('Health'));
      expect(habit.reminder, equals('enabled'));
      expect(habit.time, equals('08:00'));
      expect(habit.isDone, isFalse);
      expect(habit.dateCreation, equals(now));
    });

    test('debería convertir Habit a JSON correctamente', () {
      // Arrange
      final now = DateTime.now();
      final habit = Habit(
        id: 'test-id',
        name: 'Test Habit',
        description: 'Test Description',
        daysOfWeek: ['Monday', 'Wednesday'],
        category: 'Health',
        reminder: 'enabled',
        time: '08:00',
        isDone: true,
        dateCreation: now,
      );

      // Act
      final json = habit.toJson();

      // Assert
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Habit'));
      expect(json['description'], equals('Test Description'));
      expect(json['daysOfWeek'], equals(['Monday', 'Wednesday']));
      expect(json['category'], equals('Health'));
      expect(json['reminder'], equals('enabled'));
      expect(json['time'], equals('08:00'));
      expect(json['isDone'], isTrue);
      expect(json['dateCreation'], equals(now.toIso8601String()));
    });

    test('debería crear Habit desde JSON correctamente', () {
      // Arrange
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'name': 'Test Habit',
        'description': 'Test Description',
        'daysOfWeek': ['Monday', 'Wednesday'],
        'category': 'Health',
        'reminder': 'enabled',
        'time': '08:00',
        'isDone': true,
        'dateCreation': now.toIso8601String(),
      };

      // Act
      final habit = Habit.fromJson(json);

      // Assert
      expect(habit.id, equals('test-id'));
      expect(habit.name, equals('Test Habit'));
      expect(habit.description, equals('Test Description'));
      expect(habit.daysOfWeek, equals(['Monday', 'Wednesday']));
      expect(habit.category, equals('Health'));
      expect(habit.reminder, equals('enabled'));
      expect(habit.time, equals('08:00'));
      expect(habit.isDone, isTrue);
      expect(habit.dateCreation.toIso8601String(), equals(now.toIso8601String()));
    });

    test('debería crear Habit con diferentes valores', () {
      // Arrange & Act
      final habit1 = Habit(
        id: 'id1',
        name: 'Habit 1',
        description: 'Description 1',
        daysOfWeek: ['Monday'],
        category: 'Work',
        reminder: 'disabled',
        time: '09:00',
        isDone: false,
        dateCreation: DateTime(2024, 1, 1),
      );

      final habit2 = Habit(
        id: 'id2',
        name: 'Habit 2',
        description: 'Description 2',
        daysOfWeek: ['Friday', 'Saturday', 'Sunday'],
        category: 'Leisure',
        reminder: 'enabled',
        time: '18:00',
        isDone: true,
        dateCreation: DateTime(2024, 2, 1),
      );

      // Assert
      expect(habit1.id, isNot(equals(habit2.id)));
      expect(habit1.name, isNot(equals(habit2.name)));
      expect(habit1.daysOfWeek.length, equals(1));
      expect(habit2.daysOfWeek.length, equals(3));
      expect(habit1.isDone, isFalse);
      expect(habit2.isDone, isTrue);
    });
  });
}

