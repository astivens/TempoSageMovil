import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/models/productive_block.dart';

void main() {
  group('ProductiveBlock Tests', () {
    test('should create ProductiveBlock with required values', () {
      // Arrange & Act
      final block = ProductiveBlock(
        weekday: 1,
        hour: 9,
        completionRate: 0.75,
        isProductiveBlock: true,
        category: 'work',
      );

      // Assert
      expect(block.weekday, equals(1));
      expect(block.hour, equals(9));
      expect(block.completionRate, equals(0.75));
      expect(block.isProductiveBlock, isTrue);
      expect(block.category, equals('work'));
    });

    test('should create ProductiveBlock with default values', () {
      // Arrange & Act
      final block = ProductiveBlock(
        weekday: 0,
        hour: 0,
        completionRate: 0.0,
      );

      // Assert
      expect(block.weekday, equals(0));
      expect(block.hour, equals(0));
      expect(block.completionRate, equals(0.0));
      expect(block.isProductiveBlock, isFalse);
      expect(block.category, isNull);
    });

    test('should create ProductiveBlock from map', () {
      // Arrange
      final map = {
        'weekday': 2,
        'hour': 14,
        'completion_rate': 0.85,
        'is_productive': true,
        'category': 'study',
      };

      // Act
      final block = ProductiveBlock.fromMap(map);

      // Assert
      expect(block.weekday, equals(2));
      expect(block.hour, equals(14));
      expect(block.completionRate, equals(0.85));
      expect(block.isProductiveBlock, isTrue);
      expect(block.category, equals('study'));
    });

    test('should create ProductiveBlock from map with missing values', () {
      // Arrange
      final map = {
        'weekday': 3,
        'hour': 10,
      };

      // Act
      final block = ProductiveBlock.fromMap(map);

      // Assert
      expect(block.weekday, equals(3));
      expect(block.hour, equals(10));
      expect(block.completionRate, equals(0.0));
      expect(block.isProductiveBlock, isFalse);
      expect(block.category, isNull);
    });

    test('should convert ProductiveBlock to map', () {
      // Arrange
      final block = ProductiveBlock(
        weekday: 4,
        hour: 15,
        completionRate: 0.9,
        isProductiveBlock: true,
        category: 'exercise',
      );

      // Act
      final map = block.toMap();

      // Assert
      expect(map['weekday'], equals(4));
      expect(map['hour'], equals(15));
      expect(map['completion_rate'], equals(0.9));
      expect(map['is_productive'], isTrue);
      expect(map['category'], equals('exercise'));
    });

    test('should format toString correctly', () {
      // Arrange
      final block = ProductiveBlock(
        weekday: 1,
        hour: 9,
        completionRate: 0.75,
        category: 'work',
      );

      // Act
      final string = block.toString();

      // Assert
      expect(string,
          equals('Martes a las 09:00 (work) (Tasa de completado: 75.0%)'));
    });

    test('should format toString correctly without category', () {
      // Arrange
      final block = ProductiveBlock(
        weekday: 0,
        hour: 14,
        completionRate: 0.5,
      );

      // Act
      final string = block.toString();

      // Assert
      expect(string, equals('Lunes a las 14:00 (Tasa de completado: 50.0%)'));
    });

    test('should sort blocks by completion rate', () {
      // Arrange
      final blocks = [
        ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.5),
        ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.8),
        ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.3),
      ];

      // Act
      final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);

      // Assert
      expect(sortedBlocks[0].completionRate, equals(0.8));
      expect(sortedBlocks[1].completionRate, equals(0.5));
      expect(sortedBlocks[2].completionRate, equals(0.3));
    });

    test('should filter blocks by category', () {
      // Arrange
      final blocks = [
        ProductiveBlock(
            weekday: 1, hour: 9, completionRate: 0.5, category: 'work'),
        ProductiveBlock(
            weekday: 2, hour: 10, completionRate: 0.8, category: 'study'),
        ProductiveBlock(
            weekday: 3, hour: 11, completionRate: 0.3, category: 'work'),
        ProductiveBlock(weekday: 4, hour: 12, completionRate: 0.6),
      ];

      // Act
      final filteredBlocks = ProductiveBlock.filterByCategory(blocks, 'work');

      // Assert
      expect(filteredBlocks.length, equals(3)); // 2 work + 1 null category
      expect(
          filteredBlocks.where((b) => b.category == 'work').length, equals(2));
    });

    test('should return all blocks when filtering with empty category', () {
      // Arrange
      final blocks = [
        ProductiveBlock(
            weekday: 1, hour: 9, completionRate: 0.5, category: 'work'),
        ProductiveBlock(
            weekday: 2, hour: 10, completionRate: 0.8, category: 'study'),
        ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.3),
      ];

      // Act
      final filteredBlocks = ProductiveBlock.filterByCategory(blocks, '');

      // Assert
      expect(filteredBlocks.length, equals(blocks.length));
    });
  });
}
