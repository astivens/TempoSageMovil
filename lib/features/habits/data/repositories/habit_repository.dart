import '../models/habit_model.dart';

abstract class HabitRepository {
  Future<void> init();
  Future<List<HabitModel>> getHabits();
  Future<List<HabitModel>> getHabitsForToday();
  Future<HabitModel> getHabitById(String id);
  Future<List<HabitModel>> getHabitsForDate(DateTime date);
  Future<void> createHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> completeHabit(HabitModel habit);
  Future<void> markHabitAsCompleted(String id);
}
