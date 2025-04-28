import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:temposage/core/errors/app_exception.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:temposage/features/habits/domain/usecases/get_habits_use_case.dart';

// Generar mocks
@GenerateMocks([HabitRepository])
import 'get_habits_use_case_test.mocks.dart';

void main() {
  late GetHabitsUseCase useCase;
  late MockHabitRepository mockRepository;

  // Configuración que se ejecuta antes de cada test
  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = GetHabitsUseCase(mockRepository);
  });

  // Grupos de tests
  group('getAllHabits', () {
    final habits = [
      Habit(
        id: '1',
        name: 'Meditar',
        description: 'Meditar 10 minutos',
        daysOfWeek: ['Lunes', 'Miércoles', 'Viernes'],
        category: 'Personal',
        reminder: 'none',
        time: '08:00',
        isDone: false,
        dateCreation: DateTime.now(),
      ),
      Habit(
        id: '2',
        name: 'Ejercicio',
        description: 'Hacer ejercicio',
        daysOfWeek: ['Martes', 'Jueves'],
        category: 'Salud',
        reminder: 'none',
        time: '18:00',
        isDone: false,
        dateCreation: DateTime.now(),
      ),
    ];

    test(
        'debería retornar una lista de hábitos cuando la llamada al repositorio es exitosa',
        () async {
      // Arrange
      when(mockRepository.getAllHabits()).thenAnswer((_) async => habits);

      // Act
      final result = await useCase.getAllHabits();

      // Assert
      expect(result, equals(habits));
      verify(mockRepository.getAllHabits()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'debería lanzar ServiceException cuando la llamada al repositorio falla',
        () async {
      // Arrange
      when(mockRepository.getAllHabits()).thenThrow(Exception('Error de test'));

      // Act & Assert
      expect(() => useCase.getAllHabits(), throwsA(isA<ServiceException>()));
      verify(mockRepository.getAllHabits()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('getHabitsByDay', () {
    final habitsForMonday = [
      Habit(
        id: '1',
        name: 'Meditar',
        description: 'Meditar 10 minutos',
        daysOfWeek: ['Lunes', 'Miércoles', 'Viernes'],
        category: 'Personal',
        reminder: 'none',
        time: '08:00',
        isDone: false,
        dateCreation: DateTime.now(),
      ),
    ];

    test(
        'debería retornar hábitos filtrados por día cuando la llamada al repositorio es exitosa',
        () async {
      // Arrange
      when(mockRepository.getHabitsByDayOfWeek('Lunes'))
          .thenAnswer((_) async => habitsForMonday);

      // Act
      final result = await useCase.getHabitsByDay('Lunes');

      // Assert
      expect(result, equals(habitsForMonday));
      verify(mockRepository.getHabitsByDayOfWeek('Lunes')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'debería lanzar ServiceException cuando la llamada al repositorio falla',
        () async {
      // Arrange
      when(mockRepository.getHabitsByDayOfWeek('Lunes'))
          .thenThrow(Exception('Error de test'));

      // Act & Assert
      expect(() => useCase.getHabitsByDay('Lunes'),
          throwsA(isA<ServiceException>()));
      verify(mockRepository.getHabitsByDayOfWeek('Lunes')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('getHabitById', () {
    final habit = Habit(
      id: '1',
      name: 'Meditar',
      description: 'Meditar 10 minutos',
      daysOfWeek: ['Lunes', 'Miércoles', 'Viernes'],
      category: 'Personal',
      reminder: 'none',
      time: '08:00',
      isDone: false,
      dateCreation: DateTime.now(),
    );

    test(
        'debería retornar un hábito cuando la llamada al repositorio es exitosa',
        () async {
      // Arrange
      when(mockRepository.getHabitById('1')).thenAnswer((_) async => habit);

      // Act
      final result = await useCase.getHabitById('1');

      // Assert
      expect(result, equals(habit));
      verify(mockRepository.getHabitById('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'debería lanzar ServiceException cuando la llamada al repositorio falla',
        () async {
      // Arrange
      when(mockRepository.getHabitById('1'))
          .thenThrow(Exception('Error de test'));

      // Act & Assert
      expect(() => useCase.getHabitById('1'), throwsA(isA<ServiceException>()));
      verify(mockRepository.getHabitById('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
