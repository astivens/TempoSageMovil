import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';

class HabitCubit extends Cubit<List<HabitModel>> {
  final HabitRepository _repository;

  HabitCubit(this._repository) : super([]);

  Future<List<HabitModel>> getHabitsForToday() async {
    final habits = await _repository.getHabitsForToday();
    emit(habits);
    return habits;
  }

  Future<void> completeHabit(HabitModel habit) async {
    await _repository.completeHabit(habit);
    await getHabitsForToday();
  }

  Future<void> deleteHabit(HabitModel habit) async {
    await _repository.deleteHabit(habit.id);
    await getHabitsForToday();
  }
}
