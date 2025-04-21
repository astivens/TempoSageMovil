import '../models/habit_model.dart';
import 'habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final List<HabitModel> _habits = [];

  @override
  Future<List<HabitModel>> getHabits() async {
    // TODO: Implementar obtención de hábitos
    return _habits;
  }

  @override
  Future<HabitModel> getHabitById(String id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    return habit;
  }

  @override
  Future<void> createHabit(HabitModel habit) async {
    // TODO: Implementar creación de hábito
    _habits.add(habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    // TODO: Implementar actualización de hábito
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    // TODO: Implementar eliminación de hábito
    _habits.removeWhere((h) => h.id == id);
  }

  @override
  Future<void> completeHabit(HabitModel habit) async {
    // TODO: Implementar completar hábito
  }

  @override
  Future<void> markHabitAsCompleted(String id) async {
    // TODO: Implementar marcar hábito como completado
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      final lastCompleted = habit.lastCompleted;

      // Actualizar la racha
      int newStreak = habit.streak;
      if (lastCompleted != null) {
        final difference = now.difference(lastCompleted).inDays;
        if (difference == 1) {
          newStreak++;
        } else if (difference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      _habits[index] = habit.copyWith(
        isCompleted: true,
        streak: newStreak,
        totalCompletions: habit.totalCompletions + 1,
        lastCompleted: now,
      );
    }
  }

  @override
  Future<List<HabitModel>> getHabitsForToday() async {
    // TODO: Implementar obtención de hábitos de hoy
    final now = DateTime.now();
    return getHabitsForDate(now);
  }

  @override
  Future<List<HabitModel>> getHabitsForDate(DateTime date) async {
    final dayOfWeek = date.weekday - 1; // Convertir a 0-6 (Lunes-Domingo)
    return _habits
        .where((habit) => habit.daysOfWeek.contains(dayOfWeek))
        .toList();
  }
}
