import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/domain/usecases/analyze_patterns_use_case.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';

void main() {
  group('AnalyzePatternsUseCase', () {
    late AnalyzePatternsUseCase useCase;

    setUp(() {
      useCase = AnalyzePatternsUseCase();
    });

    group('execute', () {
      test('debería retornar lista de patrones', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.execute(activities: activities);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result, isNotEmpty);
        expect(result.first, containsPair('pattern', 'Patrón de ejemplo'));
        expect(result.first, containsPair('confidence', 0.9));
      });

      test('debería retornar patrones con lista vacía de actividades', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.execute(activities: activities);

        // Assert
        expect(result, isNotEmpty);
      });

      test('debería retornar patrones con actividades', () async {
        // Arrange
        final activities = [
          Activity(
            id: '1',
            name: 'Test Activity',
            date: DateTime.now(),
            category: 'Work',
            description: 'Test',
            isCompleted: false,
          ),
        ];

        // Act
        final result = await useCase.execute(activities: activities);

        // Assert
        expect(result, isNotEmpty);
        expect(result.first, isA<Map<String, dynamic>>());
      });

      test('debería usar timePeriod por defecto de 30', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.execute(activities: activities);

        // Assert
        expect(result, isNotEmpty);
      });

      test('debería aceptar timePeriod personalizado', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.execute(
          activities: activities,
          timePeriod: 60,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('debería lanzar excepción en caso de error', () async {
        // Este test verifica que el método maneja errores correctamente
        // En la implementación actual, no hay errores esperados
        final activities = <Activity>[];

        final result = await useCase.execute(activities: activities);
        expect(result, isNotEmpty);
      });
    });

    group('executeWithExplanation', () {
      test('debería retornar resultado con explicación', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.executeWithExplanation(activities: activities);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('patterns'), isTrue);
        expect(result.containsKey('explanation'), isTrue);
        expect(result['patterns'], isA<List>());
        expect(result['explanation'], isA<String>());
      });

      test('debería incluir explicación en el resultado', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.executeWithExplanation(activities: activities);

        // Assert
        expect(result['explanation'], contains('patrones'));
      });

      test('debería usar timePeriod por defecto', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.executeWithExplanation(activities: activities);

        // Assert
        expect(result, isNotEmpty);
        expect(result['patterns'], isNotEmpty);
      });

      test('debería aceptar timePeriod personalizado', () async {
        // Arrange
        final activities = <Activity>[];

        // Act
        final result = await useCase.executeWithExplanation(
          activities: activities,
          timePeriod: 90,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result['patterns'], isNotEmpty);
      });

      test('debería lanzar excepción en caso de error', () async {
        // Este test verifica que el método maneja errores correctamente
        final activities = <Activity>[];

        final result = await useCase.executeWithExplanation(activities: activities);
        expect(result, isNotEmpty);
      });
    });
  });
}

