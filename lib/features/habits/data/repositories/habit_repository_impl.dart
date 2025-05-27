import 'package:flutter/material.dart';
import '../../../../core/services/local_storage.dart';
import '../../../../core/services/service_locator.dart';
import '../models/habit_model.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';

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
    } catch (e) {
      throw HabitRepositoryException(
          'Error inicializando repositorio de hábitos: $e');
    }
  }

  @override
  Future<Habit> getHabitById(String id) async {
    try {
      if (id.isEmpty) {
        throw HabitRepositoryException('El ID no puede estar vacío');
      }

      final habit = await LocalStorage.getData<HabitModel>(_boxName, id);
      if (habit == null) {
        throw HabitRepositoryException('Hábito no encontrado');
      }
      return _mapModelToEntity(habit);
    } catch (e) {
      throw HabitRepositoryException('Error al obtener hábito: $e');
    }
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    try {
      debugPrint('📋 Obteniendo todos los hábitos...');
      final habits = await _getHabits();
      debugPrint('📊 Total de hábitos encontrados: ${habits.length}');

      for (final habit in habits) {
        debugPrint(
            '   - ${habit.title} (días: ${habit.daysOfWeek.join(', ')})');
      }

      return habits.map(_mapModelToEntity).toList();
    } catch (e) {
      debugPrint('❌ Error al obtener todos los hábitos: $e');
      throw HabitRepositoryException('Error al obtener todos los hábitos: $e');
    }
  }

  @override
  Future<List<Habit>> getHabitsByDayOfWeek(String dayOfWeek) async {
    try {
      debugPrint('🗓️ Buscando hábitos para el día: $dayOfWeek');
      final habits = await _getHabits();
      debugPrint('📊 Total de hábitos en storage: ${habits.length}');

      for (final habit in habits) {
        debugPrint(
            '   - ${habit.title}: días [${habit.daysOfWeek.join(', ')}]');
      }

      final filteredHabits = habits
          .where((habit) => habit.daysOfWeek.contains(dayOfWeek))
          .toList();

      debugPrint(
          '✅ Hábitos encontrados para $dayOfWeek: ${filteredHabits.length}');
      for (final habit in filteredHabits) {
        debugPrint('   ✓ ${habit.title}');
      }

      return filteredHabits.map(_mapModelToEntity).toList();
    } catch (e) {
      debugPrint('❌ Error al obtener hábitos por día de la semana: $e');
      throw HabitRepositoryException(
          'Error al obtener hábitos por día de la semana: $e');
    }
  }

  Future<bool> _isDuplicate(HabitModel habitToCheck) async {
    try {
      final habits = await _getHabits();

      for (final existingHabit in habits) {
        if (existingHabit.id != habitToCheck.id &&
            existingHabit.title.toLowerCase() ==
                habitToCheck.title.toLowerCase()) {
          final commonDays = existingHabit.daysOfWeek
              .where((day) => habitToCheck.daysOfWeek.contains(day))
              .length;

          if (commonDays > 0) {
            debugPrint(
                'Posible duplicado de hábito detectado: ${habitToCheck.title}');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error al verificar duplicado de hábito: $e');
      return false;
    }
  }

  @override
  Future<void> addHabit(Habit habit) async {
    try {
      if (habit.name.isEmpty) {
        throw HabitRepositoryException('El nombre no puede estar vacío');
      }

      final habitModel = _mapEntityToModel(habit);

      final isDuplicate = await _isDuplicate(habitModel);
      if (isDuplicate) {
        debugPrint('Evitando guardar un hábito duplicado: ${habit.name}');
        return;
      }

      await LocalStorage.saveData<HabitModel>(
          _boxName, habitModel.id, habitModel);
      debugPrint('Hábito guardado correctamente: ${habit.name}');

      // Programar notificaciones para este hábito si es necesario
      if (habit.reminder == 'Si') {
        await ServiceLocator.instance.habitNotificationService
            .scheduleHabitNotification(habit);
      }

      // Planificar bloques de tiempo para los próximos 3 días
      await ServiceLocator.instance.habitToTimeBlockService
          .planificarBloquesParaNuevoHabito(habitModel, daysAhead: 3);
    } catch (e) {
      throw HabitRepositoryException('Error al crear hábito: $e');
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    try {
      if (habit.name.isEmpty) {
        throw HabitRepositoryException('El nombre no puede estar vacío');
      }

      final habitModel = _mapEntityToModel(habit);
      await LocalStorage.saveData<HabitModel>(
          _boxName, habitModel.id, habitModel);

      // Actualizar notificaciones para este hábito
      await ServiceLocator.instance.habitNotificationService
          .updateHabitNotifications(habit);

      // Planificar bloques de tiempo para los próximos 3 días
      await ServiceLocator.instance.habitToTimeBlockService
          .planificarBloquesParaNuevoHabito(habitModel, daysAhead: 3);
    } catch (e) {
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

      // Cancelar notificaciones para este hábito
      await ServiceLocator.instance.habitNotificationService
          .cancelHabitNotifications(id);
    } catch (e) {
      throw HabitRepositoryException('Error al eliminar hábito: $e');
    }
  }

  Habit _mapModelToEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.title,
      description: model.description,
      daysOfWeek: model.daysOfWeek,
      category: model.category,
      reminder: model.reminder,
      time: model.time,
      isDone: model.isCompleted,
      dateCreation: model.dateCreation,
    );
  }

  HabitModel _mapEntityToModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      title: entity.name,
      description: entity.description,
      daysOfWeek: entity.daysOfWeek,
      category: entity.category,
      reminder: entity.reminder,
      time: entity.time,
      isCompleted: entity.isDone,
      dateCreation: entity.dateCreation,
      lastCompleted: null,
      streak: 0,
      totalCompletions: 0,
    );
  }
}
