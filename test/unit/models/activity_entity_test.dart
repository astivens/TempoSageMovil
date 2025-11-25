import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';

void main() {
  group('Activity Entity', () {
    test('debería crear una instancia de Activity con todos los campos', () {
      // Arrange
      final now = DateTime.now();
      final activity = Activity(
        id: 'test-id',
        name: 'Test Activity',
        date: now,
        category: 'Work',
        description: 'Test Description',
        isCompleted: false,
      );

      // Assert
      expect(activity.id, equals('test-id'));
      expect(activity.name, equals('Test Activity'));
      expect(activity.date, equals(now));
      expect(activity.category, equals('Work'));
      expect(activity.description, equals('Test Description'));
      expect(activity.isCompleted, isFalse);
    });

    test('debería convertir Activity a JSON correctamente', () {
      // Arrange
      final now = DateTime(2024, 1, 15, 10, 30);
      final activity = Activity(
        id: 'test-id',
        name: 'Test Activity',
        date: now,
        category: 'Work',
        description: 'Test Description',
        isCompleted: true,
      );

      // Act
      final json = activity.toJson();

      // Assert
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Activity'));
      expect(json['date'], equals(now.toIso8601String()));
      expect(json['category'], equals('Work'));
      expect(json['description'], equals('Test Description'));
      expect(json['isCompleted'], isTrue);
    });

    test('debería crear Activity con diferentes valores', () {
      // Arrange & Act
      final activity1 = Activity(
        id: 'id1',
        name: 'Activity 1',
        date: DateTime(2024, 1, 1),
        category: 'Work',
        description: 'Description 1',
        isCompleted: false,
      );

      final activity2 = Activity(
        id: 'id2',
        name: 'Activity 2',
        date: DateTime(2024, 2, 1),
        category: 'Leisure',
        description: 'Description 2',
        isCompleted: true,
      );

      // Assert
      expect(activity1.id, isNot(equals(activity2.id)));
      expect(activity1.name, isNot(equals(activity2.name)));
      expect(activity1.category, isNot(equals(activity2.category)));
      expect(activity1.isCompleted, isFalse);
      expect(activity2.isCompleted, isTrue);
    });

    test('debería manejar Activity completada y no completada', () {
      // Arrange & Act
      final completedActivity = Activity(
        id: 'id1',
        name: 'Completed Activity',
        date: DateTime.now(),
        category: 'Work',
        description: 'Description',
        isCompleted: true,
      );

      final incompleteActivity = Activity(
        id: 'id2',
        name: 'Incomplete Activity',
        date: DateTime.now(),
        category: 'Work',
        description: 'Description',
        isCompleted: false,
      );

      // Assert
      expect(completedActivity.isCompleted, isTrue);
      expect(incompleteActivity.isCompleted, isFalse);
    });
  });
}

