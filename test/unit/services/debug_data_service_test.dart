import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/debug_data_service.dart';
import 'package:temposage/core/models/productive_block.dart';

void main() {
  group('DebugDataService', () {
    group('generateFakeProductiveBlocks', () {
      test('debería generar lista de bloques productivos ficticios', () {
        // Act
        final blocks = DebugDataService.generateFakeProductiveBlocks();

        // Assert
        expect(blocks, isNotEmpty);
        expect(blocks, isA<List<ProductiveBlock>>());
        expect(blocks.length, greaterThan(0));
      });

      test('debería generar bloques con datos válidos', () {
        // Act
        final blocks = DebugDataService.generateFakeProductiveBlocks();

        // Assert
        for (final block in blocks) {
          expect(block.weekday, greaterThanOrEqualTo(0));
          expect(block.weekday, lessThan(7));
          expect(block.hour, greaterThanOrEqualTo(0));
          expect(block.hour, lessThan(24));
          expect(block.completionRate, greaterThanOrEqualTo(0.0));
          expect(block.completionRate, lessThanOrEqualTo(1.0));
          expect(block.category, isNotNull);
        }
      });

      test('debería generar múltiples bloques para diferentes días', () {
        // Act
        final blocks = DebugDataService.generateFakeProductiveBlocks();

        // Assert
        final weekdays = blocks.map((b) => b.weekday).toSet();
        expect(weekdays.length, greaterThan(1));
      });
    });

    group('generateFakeProductivityStats', () {
      test('debería generar estadísticas ficticias de productividad', () {
        // Act
        final stats = DebugDataService.generateFakeProductivityStats();

        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['totalBlocks'], isNotNull);
        expect(stats['averageCompletionRate'], isNotNull);
        expect(stats['mostProductiveDay'], isNotNull);
        expect(stats['mostProductiveHour'], isNotNull);
        expect(stats['totalSessions'], isNotNull);
        expect(stats['totalHours'], isNotNull);
        expect(stats['streakDays'], isNotNull);
        expect(stats['categoryStats'], isNotNull);
      });

      test('debería generar estadísticas con valores válidos', () {
        // Act
        final stats = DebugDataService.generateFakeProductivityStats();

        // Assert
        expect(stats['totalBlocks'], isA<int>());
        expect(stats['totalBlocks'], greaterThan(0));
        expect(stats['averageCompletionRate'], isA<double>());
        expect(stats['averageCompletionRate'], greaterThanOrEqualTo(0.0));
        expect(stats['averageCompletionRate'], lessThanOrEqualTo(1.0));
        expect(stats['mostProductiveHour'], isA<int>());
        expect(stats['mostProductiveHour'], greaterThanOrEqualTo(0));
        expect(stats['mostProductiveHour'], lessThan(24));
        expect(stats['streakDays'], isA<int>());
        expect(stats['streakDays'], greaterThanOrEqualTo(0));
      });

      test('debería generar estadísticas de categorías', () {
        // Act
        final stats = DebugDataService.generateFakeProductivityStats();

        // Assert
        final categoryStats = stats['categoryStats'] as Map<String, dynamic>;
        expect(categoryStats, isNotEmpty);
        expect(categoryStats.keys, isNotEmpty);
        
        for (final category in categoryStats.keys) {
          final categoryData = categoryStats[category] as Map<String, dynamic>;
          expect(categoryData['count'], isA<int>());
          expect(categoryData['avgRate'], isA<double>());
          expect(categoryData['totalHours'], isA<int>());
          expect(categoryData['bestHour'], isA<int>());
        }
      });
    });

    group('generateFakeRecommendations', () {
      test('debería generar lista de recomendaciones ficticias', () {
        // Act
        final recommendations = DebugDataService.generateFakeRecommendations();

        // Assert
        expect(recommendations, isNotEmpty);
        expect(recommendations, isA<List<Map<String, dynamic>>>());
        expect(recommendations.length, greaterThan(0));
      });

      test('debería generar recomendaciones con datos válidos', () {
        // Act
        final recommendations = DebugDataService.generateFakeRecommendations();

        // Assert
        for (final recommendation in recommendations) {
          expect(recommendation['title'], isNotNull);
          expect(recommendation['category'], isNotNull);
          expect(recommendation['score'], isNotNull);
          expect(recommendation['description'], isNotNull);
        }
      });
    });
  });
}

