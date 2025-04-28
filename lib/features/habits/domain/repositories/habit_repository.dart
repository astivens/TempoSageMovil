import '../entities/habit.dart';

abstract class HabitRepository {
  Future<void> init();
  Future<List<Habit>> getAllHabits();
  Future<Habit> getHabitById(String id);
  Future<List<Habit>> getHabitsByDayOfWeek(String dayOfWeek);
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
}
