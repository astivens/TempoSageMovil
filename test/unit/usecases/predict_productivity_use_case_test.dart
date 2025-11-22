import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/domain/usecases/predict_productivity_use_case.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

void main() {
  group('PredictProductivityUseCase', () {
    late PredictProductivityUseCase useCase;

    setUp(() {
      useCase = PredictProductivityUseCase();
    });

    group('execute', () {
      test('debería retornar un valor de productividad', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.execute(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, isA<double>());
        expect(result, greaterThanOrEqualTo(0.0));
        expect(result, lessThanOrEqualTo(1.0));
      });

      test('debería retornar valor por defecto de 0.8', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.execute(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, equals(0.8));
      });

      test('debería manejar lista vacía de actividades y hábitos', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.execute(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, isA<double>());
      });

      test('debería manejar actividades y hábitos', () async {
        // Arrange
        final activities = [
          Activity(
            id: '1',
            name: 'Test Activity',
            date: DateTime.now(),
            category: 'Work',
            description: 'Test',
            isCompleted: true,
          ),
        ];
        final habits = [
          Habit(
            id: '1',
            name: 'Test Habit',
            description: 'Test',
            daysOfWeek: ['Lunes'],
            category: 'Health',
            reminder: 'Si',
            time: '08:00',
            isDone: true,
            dateCreation: DateTime.now(),
          ),
        ];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.execute(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, isA<double>());
      });

      test('debería manejar diferentes fechas objetivo', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now().add(const Duration(days: 7));

        // Act
        final result = await useCase.execute(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, isA<double>());
      });
    });

    group('executeWithExplanation', () {
      test('debería retornar resultado con explicación', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.executeWithExplanation(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('prediction'), isTrue);
        expect(result.containsKey('explanation'), isTrue);
        expect(result['prediction'], isA<double>());
        expect(result['explanation'], isA<String>());
      });

      test('debería incluir predicción en el resultado', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.executeWithExplanation(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result['prediction'], equals(0.8));
      });

      test('debería incluir explicación en el resultado', () async {
        // Arrange
        final activities = <Activity>[];
        final habits = <Habit>[];
        final targetDate = DateTime.now();

        // Act
        final result = await useCase.executeWithExplanation(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result['explanation'], contains('predicción'));
      });

      test('debería manejar diferentes combinaciones de datos', () async {
        // Arrange
        final activities = [
          Activity(
            id: '1',
            name: 'Activity 1',
            date: DateTime.now(),
            category: 'Work',
            description: 'Test',
            isCompleted: false,
          ),
        ];
        final habits = [
          Habit(
            id: '1',
            name: 'Habit 1',
            description: 'Test',
            daysOfWeek: ['Lunes', 'Martes'],
            category: 'Health',
            reminder: 'No',
            time: '07:00',
            isDone: false,
            dateCreation: DateTime.now(),
          ),
        ];
        final targetDate = DateTime.now().add(const Duration(days: 1));

        // Act
        final result = await useCase.executeWithExplanation(
          activities: activities,
          habits: habits,
          targetDate: targetDate,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result['prediction'], isA<double>());
      });
    });
  });
}

