import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit_model.dart';
import 'habit_repository.dart';
import '../../../../core/services/service_locator.dart';

class HabitRepositoryImpl implements HabitRepository {
  static const String _boxName = 'habits';
  List<HabitModel> _habits = [];

  Future<Box<HabitModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<HabitModel>(_boxName);
    }
    return Hive.box<HabitModel>(_boxName);
  }

  @override
  Future<void> init() async {
    try {
      final box = await _getBox();
      _habits = box.values.toList();
      debugPrint('Hábitos cargados: ${_habits.length}');
    } catch (e) {
      debugPrint('Error inicializando repositorio de hábitos: $e');
      _habits = [];
    }
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    return _habits;
  }

  @override
  Future<HabitModel> getHabitById(String id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    return habit;
  }

  @override
  Future<void> createHabit(HabitModel habit) async {
    try {
      final box = await _getBox();
      await box.put(habit.id, habit);
      _habits.add(habit);
      await ServiceLocator.instance.habitToTimeBlockService
          .convertSingleHabitToTimeBlock(habit);
    } catch (e) {
      debugPrint('Error creando hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    try {
      final box = await _getBox();
      await box.put(habit.id, habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        await ServiceLocator.instance.habitToTimeBlockService
            .syncTimeBlocksForHabit(habit);
      }
    } catch (e) {
      debugPrint('Error actualizando hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      final habit = await getHabitById(id);
      final box = await _getBox();
      await box.delete(id);
      _habits.removeWhere((h) => h.id == id);
      await ServiceLocator.instance.habitToTimeBlockService
          .deleteTimeBlocksForHabit(habit);
    } catch (e) {
      debugPrint('Error eliminando hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeHabit(HabitModel habit) async {
    try {
      final now = DateTime.now();
      final updatedHabit = habit.copyWith(
        isCompleted: true,
        lastCompleted: now,
        totalCompletions: habit.totalCompletions + 1,
        streak: _calculateNewStreak(habit, now),
      );

      final box = await _getBox();
      await box.put(habit.id, updatedHabit);

      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
        await ServiceLocator.instance.habitToTimeBlockService
            .syncTimeBlocksForHabit(updatedHabit);
      }
    } catch (e) {
      debugPrint('Error completando hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> markHabitAsCompleted(String id) async {
    final habit = await getHabitById(id);
    await completeHabit(habit);
  }

  @override
  Future<List<HabitModel>> getHabitsForToday() async {
    final now = DateTime.now();
    final dayOfWeek = now.weekday - 1; // 0 = Monday, 6 = Sunday
    return _habits
        .where((habit) => habit.daysOfWeek.contains(dayOfWeek))
        .toList();
  }

  @override
  Future<List<HabitModel>> getHabitsForDate(DateTime date) async {
    final dayOfWeek = date.weekday - 1; // 0 = Monday, 6 = Sunday
    return _habits
        .where((habit) => habit.daysOfWeek.contains(dayOfWeek))
        .toList();
  }

  int _calculateNewStreak(HabitModel habit, DateTime now) {
    if (habit.lastCompleted == null) return 1;

    final difference = now.difference(habit.lastCompleted!).inDays;
    if (difference == 1) {
      return habit.streak + 1;
    } else if (difference > 1) {
      return 1;
    }
    return habit.streak;
  }
}
