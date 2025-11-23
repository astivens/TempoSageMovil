import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/models/productive_block.dart';

/// Enhanced ProductiveBlock Tests following the methodology from the design document
/// This test suite implements equivalence classes, boundary values, and path coverage
void main() {
  group('ProductiveBlock - Enhanced Unit Tests', () {
    
    // ========================================
    // EQUIVALENCE CLASSES TESTING
    // ========================================
    
    group('Equivalence Classes Testing', () {
      
      group('Weekday Validation - Equivalence Classes', () {
        test('Valid Weekday Class - Standard Values (1-7)', () {
          // Arrange & Act
          final validWeekdays = [1, 2, 3, 4, 5, 6, 7];
          
          for (final weekday in validWeekdays) {
            final block = ProductiveBlock(
              weekday: weekday,
              hour: 9,
              completionRate: 0.75,
            );
            
            // Assert
            expect(block.weekday, equals(weekday));
          }
        });

        test('Invalid Weekday Class - Out of Range Values', () {
          // Arrange
          final invalidWeekdays = [0, 8, -1, 15];
          
          for (final weekday in invalidWeekdays) {
            // Act & Assert - Should not throw but weekday should be as assigned
            final block = ProductiveBlock(
              weekday: weekday,
              hour: 9,
              completionRate: 0.75,
            );
            
            expect(block.weekday, equals(weekday));
          }
        });
      });

      group('Hour Validation - Equivalence Classes', () {
        test('Valid Hour Class - Standard Values (0-23)', () {
          // Arrange & Act
          final validHours = [0, 6, 9, 12, 15, 18, 23];
          
          for (final hour in validHours) {
            final block = ProductiveBlock(
              weekday: 1,
              hour: hour,
              completionRate: 0.75,
            );
            
            // Assert
            expect(block.hour, equals(hour));
          }
        });

        test('Invalid Hour Class - Out of Range Values', () {
          // Arrange
          final invalidHours = [-1, 24, 25, 100];
          
          for (final hour in invalidHours) {
            // Act & Assert - Should not throw but hour should be as assigned
            final block = ProductiveBlock(
              weekday: 1,
              hour: hour,
              completionRate: 0.75,
            );
            
            expect(block.hour, equals(hour));
          }
        });
      });

      group('Completion Rate Validation - Equivalence Classes', () {
        test('Valid Completion Rate Class - Standard Values (0.0-1.0)', () {
          // Arrange & Act
          final validRates = [0.0, 0.25, 0.5, 0.75, 1.0];
          
          for (final rate in validRates) {
            final block = ProductiveBlock(
              weekday: 1,
              hour: 9,
              completionRate: rate,
            );
            
            // Assert
            expect(block.completionRate, equals(rate));
          }
        });

        test('Invalid Completion Rate Class - Out of Range Values', () {
          // Arrange
          final invalidRates = [-0.1, 1.1, 2.0, -1.0];
          
          for (final rate in invalidRates) {
            // Act & Assert - Should not throw but rate should be as assigned
            final block = ProductiveBlock(
              weekday: 1,
              hour: 9,
              completionRate: rate,
            );
            
            expect(block.completionRate, equals(rate));
          }
        });
      });

      group('Category Validation - Equivalence Classes', () {
        test('Valid Category Class - Standard Categories', () {
          // Arrange & Act
          final validCategories = ['work', 'study', 'exercise', 'rest', 'personal'];
          
          for (final category in validCategories) {
            final block = ProductiveBlock(
              weekday: 1,
              hour: 9,
              completionRate: 0.75,
              category: category,
            );
            
            // Assert
            expect(block.category, equals(category));
          }
        });

        test('Valid Category Class - Null Category', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 0.75,
            category: null,
          );
          
          // Assert
          expect(block.category, isNull);
        });

        test('Invalid Category Class - Empty String', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 0.75,
            category: '',
          );
          
          // Assert
          expect(block.category, equals(''));
        });
      });
    });

    // ========================================
    // BOUNDARY VALUES TESTING
    // ========================================
    
    group('Boundary Values Testing', () {
      
      group('Weekday Boundary Values', () {
        test('Minimum Valid Weekday - 1 (Monday)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.weekday, equals(1));
        });

        test('Maximum Valid Weekday - 7 (Sunday)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 7,
            hour: 9,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.weekday, equals(7));
        });

        test('Boundary Invalid - Below Minimum (0)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 0,
            hour: 9,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.weekday, equals(0));
        });

        test('Boundary Invalid - Above Maximum (8)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 8,
            hour: 9,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.weekday, equals(8));
        });
      });

      group('Hour Boundary Values', () {
        test('Minimum Valid Hour - 0 (Midnight)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 0,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.hour, equals(0));
        });

        test('Maximum Valid Hour - 23 (11 PM)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 23,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.hour, equals(23));
        });

        test('Boundary Invalid - Below Minimum (-1)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: -1,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.hour, equals(-1));
        });

        test('Boundary Invalid - Above Maximum (24)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 24,
            completionRate: 0.75,
          );
          
          // Assert
          expect(block.hour, equals(24));
        });
      });

      group('Completion Rate Boundary Values', () {
        test('Minimum Valid Rate - 0.0', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 0.0,
          );
          
          // Assert
          expect(block.completionRate, equals(0.0));
        });

        test('Maximum Valid Rate - 1.0', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 1.0,
          );
          
          // Assert
          expect(block.completionRate, equals(1.0));
        });

        test('Boundary Invalid - Below Minimum (-0.1)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: -0.1,
          );
          
          // Assert
          expect(block.completionRate, equals(-0.1));
        });

        test('Boundary Invalid - Above Maximum (1.1)', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 1.1,
          );
          
          // Assert
          expect(block.completionRate, equals(1.1));
        });
      });
    });

    // ========================================
    // PATH COVERAGE TESTING
    // ========================================
    
    group('Path Coverage Testing', () {
      
      group('Constructor Paths', () {
        test('Path 1: All Parameters Provided', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 2,
            hour: 14,
            completionRate: 0.85,
            isProductiveBlock: true,
            category: 'work',
          );
          
          // Assert
          expect(block.weekday, equals(2));
          expect(block.hour, equals(14));
          expect(block.completionRate, equals(0.85));
          expect(block.isProductiveBlock, isTrue);
          expect(block.category, equals('work'));
        });

        test('Path 2: Only Required Parameters', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 3,
            hour: 10,
            completionRate: 0.5,
          );
          
          // Assert
          expect(block.weekday, equals(3));
          expect(block.hour, equals(10));
          expect(block.completionRate, equals(0.5));
          expect(block.isProductiveBlock, isFalse);
          expect(block.category, isNull);
        });

        test('Path 3: Some Optional Parameters', () {
          // Arrange & Act
          final block = ProductiveBlock(
            weekday: 4,
            hour: 16,
            completionRate: 0.9,
            isProductiveBlock: true,
          );
          
          // Assert
          expect(block.weekday, equals(4));
          expect(block.hour, equals(16));
          expect(block.completionRate, equals(0.9));
          expect(block.isProductiveBlock, isTrue);
          expect(block.category, isNull);
        });
      });

      group('fromMap Paths', () {
        test('Path 1: Complete Map with All Fields', () {
          // Arrange
          final map = {
            'weekday': 5,
            'hour': 12,
            'completion_rate': 0.75,
            'is_productive': true,
            'category': 'study',
          };
          
          // Act
          final block = ProductiveBlock.fromMap(map);
          
          // Assert
          expect(block.weekday, equals(5));
          expect(block.hour, equals(12));
          expect(block.completionRate, equals(0.75));
          expect(block.isProductiveBlock, isTrue);
          expect(block.category, equals('study'));
        });

        test('Path 2: Partial Map with Missing Fields', () {
          // Arrange
          final map = {
            'weekday': 6,
            'hour': 18,
          };
          
          // Act
          final block = ProductiveBlock.fromMap(map);
          
          // Assert
          expect(block.weekday, equals(6));
          expect(block.hour, equals(18));
          expect(block.completionRate, equals(0.0));
          expect(block.isProductiveBlock, isFalse);
          expect(block.category, isNull);
        });

        test('Path 3: Empty Map', () {
          // Arrange
          final map = <String, dynamic>{};
          
          // Act
          final block = ProductiveBlock.fromMap(map);
          
          // Assert
          expect(block.weekday, equals(0));
          expect(block.hour, equals(0));
          expect(block.completionRate, equals(0.0));
          expect(block.isProductiveBlock, isFalse);
          expect(block.category, isNull);
        });
      });

      group('toMap Paths', () {
        test('Path 1: Complete Block to Map', () {
          // Arrange
          final block = ProductiveBlock(
            weekday: 1,
            hour: 9,
            completionRate: 0.8,
            isProductiveBlock: true,
            category: 'work',
          );
          
          // Act
          final map = block.toMap();
          
          // Assert
          expect(map['weekday'], equals(1));
          expect(map['hour'], equals(9));
          expect(map['completion_rate'], equals(0.8));
          expect(map['is_productive'], isTrue);
          expect(map['category'], equals('work'));
        });

        test('Path 2: Minimal Block to Map', () {
          // Arrange
          final block = ProductiveBlock(
            weekday: 2,
            hour: 14,
            completionRate: 0.5,
          );
          
          // Act
          final map = block.toMap();
          
          // Assert
          expect(map['weekday'], equals(2));
          expect(map['hour'], equals(14));
          expect(map['completion_rate'], equals(0.5));
          expect(map['is_productive'], isFalse);
          expect(map['category'], isNull);
        });
      });
    });

    // ========================================
    // BUSINESS LOGIC TESTING
    // ========================================
    
    group('Business Logic Testing', () {
      
      group('toString Method', () {
        test('toString with Category', () {
          // Arrange
          final block = ProductiveBlock(
            weekday: 1, // Tuesday (0=Lunes, 1=Martes)
            hour: 9,
            completionRate: 0.75,
            category: 'work',
          );
          
          // Act
          final result = block.toString();
          
          // Assert
          expect(result, equals('Martes a las 09:00 (work) (Tasa de completado: 75.0%)'));
        });

        test('toString without Category', () {
          // Arrange
          final block = ProductiveBlock(
            weekday: 2, // Wednesday (0=Lunes, 1=Martes, 2=Miércoles)
            hour: 14,
            completionRate: 0.5,
          );
          
          // Act
          final result = block.toString();
          
          // Assert
          expect(result, equals('Miércoles a las 14:00 (Tasa de completado: 50.0%)'));
        });

        test('toString with Zero Completion Rate', () {
          // Arrange
          final block = ProductiveBlock(
            weekday: 3, // Thursday (0=Lunes, 1=Martes, 2=Miércoles, 3=Jueves)
            hour: 10,
            completionRate: 0.0,
          );
          
          // Act
          final result = block.toString();
          
          // Assert
          expect(result, equals('Jueves a las 10:00 (Tasa de completado: 0.0%)'));
        });
      });

      group('sortByCompletionRate Method', () {
        test('Sort Blocks by Completion Rate - Descending Order', () {
          // Arrange
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.3),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.8),
            ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.5),
            ProductiveBlock(weekday: 4, hour: 12, completionRate: 0.9),
          ];
          
          // Act
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
          
          // Assert
          expect(sortedBlocks[0].completionRate, equals(0.9));
          expect(sortedBlocks[1].completionRate, equals(0.8));
          expect(sortedBlocks[2].completionRate, equals(0.5));
          expect(sortedBlocks[3].completionRate, equals(0.3));
        });

        test('Sort Empty List', () {
          // Arrange
          final blocks = <ProductiveBlock>[];
          
          // Act
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
          
          // Assert
          expect(sortedBlocks, isEmpty);
        });

        test('Sort Single Element List', () {
          // Arrange
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.7),
          ];
          
          // Act
          final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
          
          // Assert
          expect(sortedBlocks.length, equals(1));
          expect(sortedBlocks[0].completionRate, equals(0.7));
        });
      });

      group('filterByCategory Method', () {
        test('Filter Blocks by Specific Category', () {
          // Arrange
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.5, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.8, category: 'study'),
            ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.3, category: 'work'),
            ProductiveBlock(weekday: 4, hour: 12, completionRate: 0.6),
          ];
          
          // Act
          final filteredBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
          
          // Assert
          // The filter includes blocks with 'work' category AND blocks without category
          expect(filteredBlocks.length, equals(3)); // 2 work + 1 without category
          expect(filteredBlocks.where((b) => b.category == 'work').length, equals(2));
        });

        test('Filter Blocks by Empty Category', () {
          // Arrange
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.5, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.8),
            ProductiveBlock(weekday: 3, hour: 11, completionRate: 0.3, category: 'study'),
          ];
          
          // Act
          final filteredBlocks = ProductiveBlock.filterByCategory(blocks, '');
          
          // Assert
          expect(filteredBlocks.length, equals(blocks.length));
        });

        test('Filter Blocks by Non-existent Category', () {
          // Arrange
          final blocks = [
            ProductiveBlock(weekday: 1, hour: 9, completionRate: 0.5, category: 'work'),
            ProductiveBlock(weekday: 2, hour: 10, completionRate: 0.8, category: 'study'),
          ];
          
          // Act
          final filteredBlocks = ProductiveBlock.filterByCategory(blocks, 'non-existent');
          
          // Assert
          expect(filteredBlocks, isEmpty);
        });
      });
    });

    // ========================================
    // EDGE CASES AND ERROR HANDLING
    // ========================================
    
    group('Edge Cases and Error Handling', () {
      test('Large Dataset Performance', () {
        // Arrange
        final blocks = List.generate(1000, (index) => 
          ProductiveBlock(
            weekday: (index % 7) + 1,
            hour: index % 24,
            completionRate: index / 1000.0,
            category: index % 2 == 0 ? 'work' : 'study',
          ),
        );
        
        // Act
        final sortedBlocks = ProductiveBlock.sortByCompletionRate(blocks);
        final filteredBlocks = ProductiveBlock.filterByCategory(blocks, 'work');
        
        // Assert
        expect(sortedBlocks.length, equals(1000));
        expect(filteredBlocks.length, equals(500)); // Half should be 'work'
        expect(sortedBlocks.first.completionRate, equals(0.999));
      });

      test('Special Characters in Category', () {
        // Arrange
        final block = ProductiveBlock(
          weekday: 1,
          hour: 9,
          completionRate: 0.75,
          category: 'trabajo/estudio',
        );
        
        // Act
        final map = block.toMap();
        final fromMap = ProductiveBlock.fromMap(map);
        
        // Assert
        expect(fromMap.category, equals('trabajo/estudio'));
      });

      test('Precision Handling in Completion Rate', () {
        // Arrange
        final block = ProductiveBlock(
          weekday: 1,
          hour: 9,
          completionRate: 0.333333333,
        );
        
        // Act
        final map = block.toMap();
        final fromMap = ProductiveBlock.fromMap(map);
        
        // Assert
        expect(fromMap.completionRate, equals(0.333333333));
      });

      test('Null Safety in Map Operations', () {
        // Arrange
        final map = {
          'weekday': null,
          'hour': null,
          'completion_rate': null,
          'is_productive': null,
          'category': null,
        };
        
        // Act
        final block = ProductiveBlock.fromMap(map);
        
        // Assert
        expect(block.weekday, equals(0));
        expect(block.hour, equals(0));
        expect(block.completionRate, equals(0.0));
        expect(block.isProductiveBlock, isFalse);
        expect(block.category, isNull);
      });
    });
  });
}
