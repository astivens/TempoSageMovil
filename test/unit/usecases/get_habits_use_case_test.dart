import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/habits/domain/usecases/get_habits_use_case.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/core/errors/app_exception.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  group('GetHabitsUseCase', () {
    late GetHabitsUseCase useCase;
    late MockHabitRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(Habit(
        id: '',
        name: '',
        description: '',
        daysOfWeek: [],
        category: '',
        reminder: '',
        time: '',
        isDone: false,
        dateCreation: DateTime.now(),
      ));
    });

    setUp(() {
      mockRepository = MockHabitRepository();
      useCase = GetHabitsUseCase(mockRepository);
    });

    group('getAllHabits', () {
      test('debería retornar lista de hábitos', () async {
        // Arrange
        final habits = [
          Habit(
            id: '1',
            name: 'Habit 1',
            description: 'Test',
            daysOfWeek: ['Lunes'],
            category: 'Health',
            reminder: 'Si',
            time: '08:00',
            isDone: false,
            dateCreation: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getAllHabits())
            .thenAnswer((_) async => habits);

        // Act
        final result = await useCase.getAllHabits();

        // Assert
        expect(result, isA<List<Habit>>());
        expect(result.length, 1);
        expect(result.first.id, equals('1'));
        verify(() => mockRepository.getAllHabits()).called(1);
      });

      test('debería retornar lista vacía cuando no hay hábitos', () async {
        // Arrange
        when(() => mockRepository.getAllHabits())
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase.getAllHabits();

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getAllHabits()).called(1);
      });

      test('debería lanzar ServiceException cuando hay error', () async {
        // Arrange
        when(() => mockRepository.getAllHabits())
            .thenThrow(Exception('Repository error'));

        // Act & Assert
        expectLater(
          useCase.getAllHabits(),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('getHabitsByDay', () {
      test('debería retornar hábitos para un día específico', () async {
        // Arrange
        final habits = [
          Habit(
            id: '1',
            name: 'Morning Habit',
            description: 'Test',
            daysOfWeek: ['Lunes'],
            category: 'Health',
            reminder: 'Si',
            time: '08:00',
            isDone: false,
            dateCreation: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getHabitsByDayOfWeek('Lunes'))
            .thenAnswer((_) async => habits);

        // Act
        final result = await useCase.getHabitsByDay('Lunes');

        // Assert
        expect(result, isA<List<Habit>>());
        expect(result.length, 1);
        expect(result.first.daysOfWeek, contains('Lunes'));
        verify(() => mockRepository.getHabitsByDayOfWeek('Lunes')).called(1);
      });

      test('debería retornar lista vacía cuando no hay hábitos para el día',
          () async {
        // Arrange
        when(() => mockRepository.getHabitsByDayOfWeek('Martes'))
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase.getHabitsByDay('Martes');

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getHabitsByDayOfWeek('Martes')).called(1);
      });

      test('debería lanzar ServiceException cuando hay error', () async {
        // Arrange
        when(() => mockRepository.getHabitsByDayOfWeek(any()))
            .thenThrow(Exception('Repository error'));

        // Act & Assert
        expectLater(
          useCase.getHabitsByDay('Lunes'),
          throwsA(isA<ServiceException>()),
        );
      });

      test('debería manejar diferentes días de la semana', () async {
        // Arrange
        final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

        for (final day in days) {
          when(() => mockRepository.getHabitsByDayOfWeek(day))
              .thenAnswer((_) async => []);
        }

        // Act & Assert
        for (final day in days) {
          final result = await useCase.getHabitsByDay(day);
          expect(result, isEmpty);
        }
      });
    });

    group('getHabitById', () {
      test('debería retornar un hábito específico por ID', () async {
        // Arrange
        final habit = Habit(
          id: 'habit-1',
          name: 'Test Habit',
          description: 'Test',
          daysOfWeek: ['Lunes'],
          category: 'Health',
          reminder: 'Si',
          time: '08:00',
          isDone: false,
          dateCreation: DateTime.now(),
        );

        when(() => mockRepository.getHabitById('habit-1'))
            .thenAnswer((_) async => habit);

        // Act
        final result = await useCase.getHabitById('habit-1');

        // Assert
        expect(result, isA<Habit>());
        expect(result.id, equals('habit-1'));
        expect(result.name, equals('Test Habit'));
        verify(() => mockRepository.getHabitById('habit-1')).called(1);
      });

      test('debería lanzar ServiceException cuando el hábito no existe',
          () async {
        // Arrange
        when(() => mockRepository.getHabitById(any()))
            .thenThrow(Exception('Habit not found'));

        // Act & Assert
        expectLater(
          useCase.getHabitById('non-existent'),
          throwsA(isA<ServiceException>()),
        );
      });

      test('debería lanzar ServiceException cuando hay error', () async {
        // Arrange
        when(() => mockRepository.getHabitById(any()))
            .thenThrow(Exception('Repository error'));

        // Act & Assert
        expectLater(
          useCase.getHabitById('habit-1'),
          throwsA(isA<ServiceException>()),
        );
      });
    });
  });
}

