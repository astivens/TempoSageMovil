import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:temposage/core/utils/date_time_helper.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';

part 'habit_state.dart';
part 'habit_cubit.freezed.dart';

@injectable
class HabitCubit extends Cubit<HabitState> {
  final HabitRepository repository;

  HabitCubit(this.repository) : super(const HabitState.initial());

  Future<void> _initialize() async {
    try {
      emit(const HabitState.loading());
      final habits = await repository.getAllHabits();
      emit(HabitState.loaded(habits: habits));
    } catch (e) {
      emit(HabitState.error(errorMessage: e.toString()));
    }
  }

  Future<void> getHabitsForToday() async {
    try {
      emit(const HabitState.loading());

      final now = DateTime.now();
      final currentDay = DateTimeHelper.getDayOfWeek(now);

      final habits = await repository.getHabitsByDayOfWeek(currentDay);
      emit(HabitState.loaded(habits: habits));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(HabitState.error(errorMessage: e.toString()));
    }
  }

  Future<void> completeHabit({required Habit habit}) async {
    try {
      emit(const HabitState.loading());
      await repository.updateHabit(
        habit.copyWith(isDone: !habit.isDone),
      );
      await getHabitsForToday();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(HabitState.error(errorMessage: e.toString()));
    }
  }

  Future<void> deleteHabit({required String id}) async {
    try {
      emit(const HabitState.loading());
      await repository.deleteHabit(id);
      await _initialize();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(HabitState.error(errorMessage: e.toString()));
    }
  }

  Future<void> createHabit({
    required String name,
    required String description,
    required List<String> daysOfWeek,
    required String category,
    required String reminder,
    required String time,
  }) async {
    try {
      emit(const HabitState.loading());

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        daysOfWeek: daysOfWeek,
        category: category,
        reminder: reminder,
        time: time,
        isDone: false,
        dateCreation: DateTime.now(),
      );

      await repository.addHabit(habit);
      await _initialize();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(HabitState.error(errorMessage: e.toString()));
    }
  }

  Future<void> updateHabit({
    required String id,
    required String name,
    required String description,
    required List<String> daysOfWeek,
    required String category,
    required String reminder,
    required String time,
    required bool isDone,
  }) async {
    try {
      emit(const HabitState.loading());

      final habit = Habit(
        id: id,
        name: name,
        description: description,
        daysOfWeek: daysOfWeek,
        category: category,
        reminder: reminder,
        time: time,
        isDone: isDone,
        dateCreation: DateTime.now(),
      );

      await repository.updateHabit(habit);
      await _initialize();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(HabitState.error(errorMessage: e.toString()));
    }
  }
}
