import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/models/user_context.dart';

void main() {
  group('UserContext Tests', () {
    test('should create UserContext with default values', () {
      // Arrange & Act
      final context = UserContext();

      // Assert
      expect(context.priority, equals(3));
      expect(context.energyLevel, equals(0.5));
      expect(context.moodLevel, equals(0.5));
      expect(context.predictedCategory, equals(''));
    });

    test('should create UserContext with custom values', () {
      // Arrange & Act
      final context = UserContext(
        priority: 5,
        energyLevel: 0.8,
        moodLevel: 0.9,
        predictedCategory: 'work',
      );

      // Assert
      expect(context.priority, equals(5));
      expect(context.energyLevel, equals(0.8));
      expect(context.moodLevel, equals(0.9));
      expect(context.predictedCategory, equals('work'));
    });

    test('should create UserContext with minimum values', () {
      // Arrange & Act
      final context = UserContext(
        priority: 1,
        energyLevel: 0.0,
        moodLevel: 0.0,
        predictedCategory: 'rest',
      );

      // Assert
      expect(context.priority, equals(1));
      expect(context.energyLevel, equals(0.0));
      expect(context.moodLevel, equals(0.0));
      expect(context.predictedCategory, equals('rest'));
    });

    test('should create UserContext with maximum values', () {
      // Arrange & Act
      final context = UserContext(
        priority: 5,
        energyLevel: 1.0,
        moodLevel: 1.0,
        predictedCategory: 'focus',
      );

      // Assert
      expect(context.priority, equals(5));
      expect(context.energyLevel, equals(1.0));
      expect(context.moodLevel, equals(1.0));
      expect(context.predictedCategory, equals('focus'));
    });

    test('should create UserContext with empty category', () {
      // Arrange & Act
      final context = UserContext(
        priority: 3,
        energyLevel: 0.5,
        moodLevel: 0.5,
        predictedCategory: '',
      );

      // Assert
      expect(context.predictedCategory, isEmpty);
    });

    test('should maintain equality with same values', () {
      // Arrange
      final context1 = UserContext(
        priority: 4,
        energyLevel: 0.7,
        moodLevel: 0.6,
        predictedCategory: 'study',
      );

      final context2 = UserContext(
        priority: 4,
        energyLevel: 0.7,
        moodLevel: 0.6,
        predictedCategory: 'study',
      );

      // Act & Assert
      expect(context1, equals(context2));
      expect(context1.hashCode, equals(context2.hashCode));
    });

    test('should have different hash codes for different contexts', () {
      // Arrange
      final context1 = UserContext(
        priority: 3,
        energyLevel: 0.5,
        moodLevel: 0.5,
        predictedCategory: 'work',
      );

      final context2 = UserContext(
        priority: 4,
        energyLevel: 0.6,
        moodLevel: 0.7,
        predictedCategory: 'study',
      );

      // Act & Assert
      expect(context1.hashCode, isNot(equals(context2.hashCode)));
    });
  });
}
