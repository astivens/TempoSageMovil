import 'package:flutter/material.dart';
import '../../../../core/services/local_storage.dart';
import '../models/habit_model.dart';
import 'habit_repository.dart';

class HabitRepositoryException implements Exception {
  final String message;
  HabitRepositoryException(this.message);

  @override
  String toString() => 'HabitRepositoryException: $message';
}

class HabitRepositoryImpl implements HabitRepository {
  static const String _boxName = 'habits';

  Future<List<HabitModel>> _getHabits() async {
    try {
      return await LocalStorage.getAllData<HabitModel>(_boxName);
    } catch (e) {
      throw HabitRepositoryException('Error al obtener hábitos: $e');
    }
  }

  @override
  Future<void> init() async {
    try {
      await _getHabits();
      debugPrint('Repositorio de hábitos inicializado');
    } catch (e) {
      debugPrint('Error inicializando repositorio de hábitos: $e');
      throw HabitRepositoryException(
          'Error inicializando repositorio de hábitos: $e');
    }
  }

  @override
  Future<HabitModel> getHabitById(String id) async {
    try {
      if (id.isEmpty) {
        throw HabitRepositoryException('El ID no puede estar vacío');
      }

      final habit = await LocalStorage.getData<HabitModel>(_boxName, id);
      if (habit == null) {
        throw HabitRepositoryException('Hábito no encontrado');
      }
      return habit;
    } catch (e) {
      debugPrint('Error al obtener hábito: $e');
      throw HabitRepositoryException('Error al obtener hábito: $e');
    }
  }

  @override
  Future<void> createHabit(HabitModel habit) async {
    try {
      if (habit.title.isEmpty) {
        throw HabitRepositoryException('El título no puede estar vacío');
      }

      debugPrint('Creando hábito: ${habit.title}');
      await LocalStorage.saveData<HabitModel>(_boxName, habit.id, habit);
    } catch (e) {
      debugPrint('Error al crear hábito: $e');
      throw HabitRepositoryException('Error al crear hábito: $e');
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    try {
      if (habit.title.isEmpty) {
        throw HabitRepositoryException('El título no puede estar vacío');
      }

      debugPrint('Actualizando hábito: ${habit.title}');
      await LocalStorage.saveData<HabitModel>(_boxName, habit.id, habit);
    } catch (e) {
      debugPrint('Error al actualizar hábito: $e');
      throw HabitRepositoryException('Error al actualizar hábito: $e');
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      if (id.isEmpty) {
        throw HabitRepositoryException('El ID no puede estar vacío');
      }

      await LocalStorage.deleteData(_boxName, id);
    } catch (e) {
      debugPrint('Error al eliminar hábito: $e');
      throw HabitRepositoryException('Error al eliminar hábito: $e');
    }
  }

  @override
  Future<List<HabitModel>> getHabitsForToday() async {
    try {
      final habits = await _getHabits();
      final now = DateTime.now();
      final dayOfWeek = now.weekday;

      debugPrint('Cargando hábitos para hoy: ${now.toString()}');
      debugPrint('Día de la semana: $dayOfWeek');
      debugPrint('Total de hábitos encontrados: ${habits.length}');

      final result = habits.where((habit) {
        final matches = habit.daysOfWeek.contains(dayOfWeek);
        if (matches) {
          debugPrint(
              'Hábito coincide con el día actual: ${habit.title} - días: ${habit.daysOfWeek}');
        } else {
          debugPrint(
              'Hábito NO coincide con el día actual: ${habit.title} - días: ${habit.daysOfWeek}');
        }
        return matches;
      }).toList();

      debugPrint('Hábitos filtrados para hoy: ${result.length}');
      return result;
    } catch (e) {
      debugPrint('Error al obtener hábitos para hoy: $e');
      throw HabitRepositoryException('Error al obtener hábitos para hoy: $e');
    }
  }

  @override
  Future<void> markHabitAsCompleted(String id) async {
    try {
      final habit = await getHabitById(id);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final updatedHabit = habit.copyWith(
        isCompleted: !habit.isCompleted,
        lastCompleted: today,
        totalCompletions: habit.isCompleted
            ? habit.totalCompletions - 1
            : habit.totalCompletions + 1,
        streak: _calculateStreak(habit, today),
      );

      await updateHabit(updatedHabit);
    } catch (e) {
      debugPrint('Error al marcar hábito como completado: $e');
      throw HabitRepositoryException(
          'Error al marcar hábito como completado: $e');
    }
  }

  int _calculateStreak(HabitModel habit, DateTime today) {
    if (habit.lastCompleted == null) {
      return 1;
    }

    final difference = today.difference(habit.lastCompleted!).inDays;
    if (difference > 1) {
      return 1;
    }

    return habit.isCompleted ? habit.streak - 1 : habit.streak + 1;
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    try {
      return await _getHabits();
    } catch (e) {
      debugPrint('Error al obtener todos los hábitos: $e');
      throw HabitRepositoryException('Error al obtener todos los hábitos: $e');
    }
  }

  @override
  Future<void> completeHabit(HabitModel habit) async {
    await markHabitAsCompleted(habit.id);
  }

  @override
  Future<List<HabitModel>> getHabitsForDate(DateTime date) async {
    try {
      final habits = await _getHabits();
      final dayOfWeek = date.weekday;

      return habits.where((habit) {
        return habit.daysOfWeek.contains(dayOfWeek);
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener hábitos para la fecha: $e');
      throw HabitRepositoryException(
          'Error al obtener hábitos para la fecha: $e');
    }
  }
}
