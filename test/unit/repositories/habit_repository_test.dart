import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/habits/data/repositories/habit_repository.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/core/services/local_storage.dart';

class MockLocalStorage extends Mock {}

void main() {
  late HabitRepositoryImpl repository;
  late MockLocalStorage mockLocalStorage;

  final testHabit1 = Habit(
    id: 'habit-1',
    name: 'Morning Exercise',
    description: 'Exercise every morning',
    daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
    category: 'Health',
    reminder: 'enabled',
    time: '07:00',
    isDone: false,
    dateCreation: DateTime(2023, 1, 1),
  );

  final testHabit2 = Habit(
    id: 'habit-2',
    name: 'Read Books',
    description: 'Read for 30 minutes',
    daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    category: 'Learning',
    reminder: 'enabled',
    time: '20:00',
    isDone: true,
    dateCreation: DateTime(2023, 1, 5),
  );

  final testHabit3 = Habit(
    id: 'habit-3',
    name: 'Meditation',
    description: 'Meditate for 10 minutes',
    daysOfWeek: ['Sunday'],
    category: 'Wellness',
    reminder: 'disabled',
    time: '06:00',
    isDone: false,
    dateCreation: DateTime(2023, 2, 1),
  );

  final testHabitModel1 = HabitModel(
    id: 'habit-1',
    title: 'Morning Exercise',
    description: 'Exercise every morning',
    daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
    category: 'Health',
    reminder: 'enabled',
    time: '07:00',
    isCompleted: false,
    dateCreation: DateTime(2023, 1, 1),
    lastCompleted: null,
    streak: 0,
    totalCompletions: 0,
  );

  final testHabitModel2 = HabitModel(
    id: 'habit-2',
    title: 'Read Books',
    description: 'Read for 30 minutes',
    daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    category: 'Learning',
    reminder: 'enabled',
    time: '20:00',
    isCompleted: true,
    dateCreation: DateTime(2023, 1, 5),
    lastCompleted: null,
    streak: 0,
    totalCompletions: 0,
  );

  final testHabitModel3 = HabitModel(
    id: 'habit-3',
    title: 'Meditation',
    description: 'Meditate for 10 minutes',
    daysOfWeek: ['Sunday'],
    category: 'Wellness',
    reminder: 'disabled',
    time: '06:00',
    isCompleted: false,
    dateCreation: DateTime(2023, 2, 1),
    lastCompleted: null,
    streak: 0,
    totalCompletions: 0,
  );

  setUp(() {
    mockLocalStorage = MockLocalStorage();
    repository = HabitRepositoryImpl();
  });

  group('HabitRepositoryImpl - init', () {
    test('init debería inicializar el repositorio correctamente', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenAnswer((_) async => []);

      await repository.init();
      expect(repository, isNotNull);
    });

    test('init debería lanzar excepción si hay error al inicializar', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.init(),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });

  group('HabitRepositoryImpl - getHabitById', () {
    test('getHabitById debería retornar un hábito específico por ID', () async {
      when(() => mockLocalStorage.getData<HabitModel>(any(), any()))
          .thenAnswer((_) async => testHabitModel1);

      final result = await repository.getHabitById('habit-1');

      expect(result.id, equals('habit-1'));
      expect(result.name, equals('Morning Exercise'));
      expect(result.category, equals('Health'));
    });

    test('getHabitById debería lanzar excepción si el ID está vacío', () async {
      expect(
        () => repository.getHabitById(''),
        throwsA(isA<HabitRepositoryException>()),
      );
    });

    test('getHabitById debería lanzar excepción si el hábito no existe', () async {
      when(() => mockLocalStorage.getData<HabitModel>(any(), any()))
          .thenAnswer((_) async => null);

      expect(
        () => repository.getHabitById('non-existent-id'),
        throwsA(isA<HabitRepositoryException>()),
      );
    });

    test('getHabitById debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.getData<HabitModel>(any(), any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.getHabitById('habit-1'),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });

  group('HabitRepositoryImpl - getAllHabits', () {
    test('getAllHabits debería retornar todos los hábitos', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenAnswer((_) async => [testHabitModel1, testHabitModel2, testHabitModel3]);

      final result = await repository.getAllHabits();

      expect(result.length, 3);
      expect(result[0].id, equals('habit-1'));
      expect(result[1].id, equals('habit-2'));
      expect(result[2].id, equals('habit-3'));
    });

    test('getAllHabits debería retornar lista vacía si no hay hábitos', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenAnswer((_) async => []);

      final result = await repository.getAllHabits();

      expect(result, isEmpty);
    });

    test('getAllHabits debería mapear correctamente de Model a Entity', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenAnswer((_) async => [testHabitModel1]);

      final result = await repository.getAllHabits();

      expect(result.length, 1);
      expect(result[0].id, equals(testHabitModel1.id));
      expect(result[0].name, equals(testHabitModel1.title));
      expect(result[0].description, equals(testHabitModel1.description));
      expect(result[0].daysOfWeek, equals(testHabitModel1.daysOfWeek));
      expect(result[0].category, equals(testHabitModel1.category));
      expect(result[0].isDone, equals(testHabitModel1.isCompleted));
    });

    test('getAllHabits debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.getAllHabits(),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });

  group('HabitRepositoryImpl - getHabitsByDayOfWeek', () {
    test('getHabitsByDayOfWeek debería retornar hábitos para un día específico',
        () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenAnswer((_) async => [testHabitModel1, testHabitModel2, testHabitModel3]);

      final result = await repository.getHabitsByDayOfWeek('Monday');

      expect(result.length, 2);
      expect(result[0].id, equals('habit-1'));
      expect(result[1].id, equals('habit-2'));
      expect(result, isNot(contains(anyElement((h) => h.id == 'habit-3'))));
    });

    test('getHabitsByDayOfWeek debería retornar lista vacía si no hay hábitos para el día',
        () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenAnswer((_) async => [testHabitModel3]);

      final result = await repository.getHabitsByDayOfWeek('Monday');

      expect(result, isEmpty);
    });

    test('getHabitsByDayOfWeek debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.getAllData<HabitModel>(any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.getHabitsByDayOfWeek('Monday'),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });

  group('HabitRepositoryImpl - addHabit', () {
    test('addHabit debería agregar un nuevo hábito', () async {
      when(() => mockLocalStorage.saveData<HabitModel>(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.addHabit(testHabit1);

      verify(() => mockLocalStorage.saveData<HabitModel>(
            'habits',
            testHabit1.id,
            any<HabitModel>(),
          )).called(1);
    });

    test('addHabit debería mapear correctamente de Entity a Model', () async {
      when(() => mockLocalStorage.saveData<HabitModel>(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.addHabit(testHabit1);

      verify(() => mockLocalStorage.saveData<HabitModel>(
            'habits',
            testHabit1.id,
            argThat(
              predicate<HabitModel>(
                (model) =>
                    model.id == testHabit1.id &&
                    model.title == testHabit1.name &&
                    model.description == testHabit1.description &&
                    model.daysOfWeek == testHabit1.daysOfWeek &&
                    model.category == testHabit1.category &&
                    model.isCompleted == testHabit1.isDone,
              ),
            ),
          )),
      ).called(1);
    });

    test('addHabit debería lanzar excepción si el nombre está vacío', () async {
      final habitWithEmptyName = testHabit1.copyWith(name: '');

      expect(
        () => repository.addHabit(habitWithEmptyName),
        throwsA(isA<HabitRepositoryException>()),
      );
    });

    test('addHabit debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.saveData<HabitModel>(any(), any(), any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.addHabit(testHabit1),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });

  group('HabitRepositoryImpl - updateHabit', () {
    test('updateHabit debería actualizar un hábito existente', () async {
      when(() => mockLocalStorage.saveData<HabitModel>(any(), any(), any()))
          .thenAnswer((_) async {});

      final updatedHabit = testHabit1.copyWith(name: 'Updated Exercise');
      await repository.updateHabit(updatedHabit);

      verify(() => mockLocalStorage.saveData<HabitModel>(
            'habits',
            updatedHabit.id,
            any<HabitModel>(),
          )).called(1);
    });

    test('updateHabit debería lanzar excepción si el nombre está vacío', () async {
      final habitWithEmptyName = testHabit1.copyWith(name: '');

      expect(
        () => repository.updateHabit(habitWithEmptyName),
        throwsA(isA<HabitRepositoryException>()),
      );
    });

    test('updateHabit debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.saveData<HabitModel>(any(), any(), any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.updateHabit(testHabit1),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });

  group('HabitRepositoryImpl - deleteHabit', () {
    test('deleteHabit debería eliminar un hábito por ID', () async {
      when(() => mockLocalStorage.deleteData(any(), any()))
          .thenAnswer((_) async {});

      await repository.deleteHabit('habit-1');

      verify(() => mockLocalStorage.deleteData('habits', 'habit-1')).called(1);
    });

    test('deleteHabit debería lanzar excepción si el ID está vacío', () async {
      expect(
        () => repository.deleteHabit(''),
        throwsA(isA<HabitRepositoryException>()),
      );
    });

    test('deleteHabit debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.deleteData(any(), any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.deleteHabit('habit-1'),
        throwsA(isA<HabitRepositoryException>()),
      );
    });
  });
}

