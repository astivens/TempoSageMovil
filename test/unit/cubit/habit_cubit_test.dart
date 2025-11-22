import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/habits/cubit/habit_cubit.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/core/utils/date_time_helper.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  group('HabitCubit', () {
    late HabitCubit cubit;
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
      cubit = HabitCubit(mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('estado inicial debería ser HabitState.initial', () {
      // Assert
      expect(cubit.state, isA<HabitState>());
      cubit.state.when(
        initial: () => expect(true, isTrue),
        loading: () => expect(false, isTrue),
        loaded: (_) => expect(false, isTrue),
        error: (_) => expect(false, isTrue),
      );
    });

    blocTest<HabitCubit, HabitState>(
      'getHabitsForToday debería cargar hábitos del día actual',
      build: () {
        final habits = [
          Habit(
            id: '1',
            name: 'Morning Exercise',
            description: 'Exercise',
            daysOfWeek: ['Lunes'],
            category: 'Health',
            reminder: 'Si',
            time: '08:00',
            isDone: false,
            dateCreation: DateTime.now(),
          ),
        ];
        when(() => mockRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => habits);
        return cubit;
      },
      act: (cubit) => cubit.getHabitsForToday(),
      verify: (cubit) {
        cubit.state.when(
          initial: () => expect(false, isTrue),
          loading: () => expect(false, isTrue),
          loaded: (habits) {
            expect(habits.length, 1);
            expect(habits.first.name, equals('Morning Exercise'));
          },
          error: (_) => expect(false, isTrue),
        );
        verify(() => mockRepository.getHabitsByDayOfWeek(any())).called(1);
      },
    );

    blocTest<HabitCubit, HabitState>(
      'getHabitsForToday debería emitir error cuando falla',
      build: () {
        when(() => mockRepository.getHabitsByDayOfWeek(any()))
            .thenThrow(Exception('Repository error'));
        return cubit;
      },
      act: (cubit) => cubit.getHabitsForToday(),
      verify: (cubit) {
        cubit.state.when(
          initial: () => expect(false, isTrue),
          loading: () => expect(false, isTrue),
          loaded: (_) => expect(false, isTrue),
          error: (errorMessage) {
            expect(errorMessage, contains('Repository error'));
          },
        );
      },
    );

    blocTest<HabitCubit, HabitState>(
      'completeHabit debería actualizar hábito y recargar',
      build: () {
        final habit = Habit(
          id: '1',
          name: 'Test Habit',
          description: 'Test',
          daysOfWeek: ['Lunes'],
          category: 'Health',
          reminder: 'Si',
          time: '08:00',
          isDone: false,
          dateCreation: DateTime.now(),
        );
        when(() => mockRepository.updateHabit(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => [habit.copyWith(isDone: true)]);
        return cubit;
      },
      act: (cubit) => cubit.completeHabit(
        habit: Habit(
          id: '1',
          name: 'Test Habit',
          description: 'Test',
          daysOfWeek: ['Lunes'],
          category: 'Health',
          reminder: 'Si',
          time: '08:00',
          isDone: false,
          dateCreation: DateTime.now(),
        ),
      ),
      verify: (cubit) {
        verify(() => mockRepository.updateHabit(any())).called(1);
        verify(() => mockRepository.getHabitsByDayOfWeek(any())).called(1);
      },
    );

    blocTest<HabitCubit, HabitState>(
      'deleteHabit debería eliminar hábito y recargar',
      build: () {
        when(() => mockRepository.deleteHabit(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllHabits())
            .thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.deleteHabit(id: '1'),
      verify: (cubit) {
        verify(() => mockRepository.deleteHabit('1')).called(1);
        verify(() => mockRepository.getAllHabits()).called(1);
      },
    );

    blocTest<HabitCubit, HabitState>(
      'createHabit debería crear hábito y recargar',
      build: () {
        when(() => mockRepository.addHabit(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllHabits())
            .thenAnswer((_) async => [
          Habit(
            id: '1',
            name: 'New Habit',
            description: 'New Description',
            daysOfWeek: ['Lunes'],
            category: 'Health',
            reminder: 'Si',
            time: '08:00',
            isDone: false,
            dateCreation: DateTime.now(),
          ),
        ]);
        return cubit;
      },
      act: (cubit) => cubit.createHabit(
        name: 'New Habit',
        description: 'New Description',
        daysOfWeek: ['Lunes'],
        category: 'Health',
        reminder: 'Si',
        time: '08:00',
      ),
      verify: (cubit) {
        verify(() => mockRepository.addHabit(any())).called(1);
        verify(() => mockRepository.getAllHabits()).called(1);
      },
    );

    blocTest<HabitCubit, HabitState>(
      'updateHabit debería actualizar hábito y recargar',
      build: () {
        when(() => mockRepository.updateHabit(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllHabits())
            .thenAnswer((_) async => [
          Habit(
            id: '1',
            name: 'Updated Habit',
            description: 'Updated Description',
            daysOfWeek: ['Martes'],
            category: 'Work',
            reminder: 'No',
            time: '09:00',
            isDone: true,
            dateCreation: DateTime.now(),
          ),
        ]);
        return cubit;
      },
      act: (cubit) => cubit.updateHabit(
        id: '1',
        name: 'Updated Habit',
        description: 'Updated Description',
        daysOfWeek: ['Martes'],
        category: 'Work',
        reminder: 'No',
        time: '09:00',
        isDone: true,
      ),
      verify: (cubit) {
        verify(() => mockRepository.updateHabit(any())).called(1);
        verify(() => mockRepository.getAllHabits()).called(1);
      },
    );

    blocTest<HabitCubit, HabitState>(
      'deleteHabit debería emitir error cuando falla',
      build: () {
        when(() => mockRepository.deleteHabit(any()))
            .thenThrow(Exception('Delete error'));
        return cubit;
      },
      act: (cubit) => cubit.deleteHabit(id: '1'),
      verify: (cubit) {
        cubit.state.when(
          initial: () => expect(false, isTrue),
          loading: () => expect(false, isTrue),
          loaded: (_) => expect(false, isTrue),
          error: (errorMessage) {
            expect(errorMessage, contains('Delete error'));
          },
        );
      },
    );

    blocTest<HabitCubit, HabitState>(
      'createHabit debería emitir error cuando falla',
      build: () {
        when(() => mockRepository.addHabit(any()))
            .thenThrow(Exception('Create error'));
        return cubit;
      },
      act: (cubit) => cubit.createHabit(
        name: 'New Habit',
        description: 'Test',
        daysOfWeek: ['Lunes'],
        category: 'Health',
        reminder: 'Si',
        time: '08:00',
      ),
      verify: (cubit) {
        cubit.state.when(
          initial: () => expect(false, isTrue),
          loading: () => expect(false, isTrue),
          loaded: (_) => expect(false, isTrue),
          error: (errorMessage) {
            expect(errorMessage, contains('Create error'));
          },
        );
      },
    );
  });
}

