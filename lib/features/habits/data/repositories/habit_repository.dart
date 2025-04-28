import '../../../../core/services/local_storage.dart';
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
      final habits = await _getHabits();
      return habits.map(_mapModelToEntity).toList();
    } catch (e) {
      throw HabitRepositoryException('Error al obtener todos los hábitos: $e');
    }
  }

  @override
  Future<List<Habit>> getHabitsByDayOfWeek(String dayOfWeek) async {
    try {
      final habits = await _getHabits();
      return habits
          .where((habit) => habit.daysOfWeek.contains(dayOfWeek))
          .map(_mapModelToEntity)
          .toList();
    } catch (e) {
      throw HabitRepositoryException(
          'Error al obtener hábitos por día de la semana: $e');
    }
  }

  @override
  Future<void> addHabit(Habit habit) async {
    try {
      if (habit.name.isEmpty) {
        throw HabitRepositoryException('El nombre no puede estar vacío');
      }

      final habitModel = _mapEntityToModel(habit);
      await LocalStorage.saveData<HabitModel>(
          _boxName, habitModel.id, habitModel);
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
    } catch (e) {
      throw HabitRepositoryException('Error al eliminar hábito: $e');
    }
  }

  // Mappers
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
