import 'package:flutter/material.dart';
import 'dart:async';
import '../../activities/data/models/activity_model.dart';
import '../../habits/data/models/habit_model.dart';
import '../../activities/data/repositories/activity_repository.dart';
import '../../habits/data/repositories/habit_repository.dart';
import '../../timeblocks/data/repositories/time_block_repository.dart';
import '../../timeblocks/data/models/time_block_model.dart';
import '../../habits/domain/services/habit_to_timeblock_service.dart';
import '../../../../core/services/service_locator.dart';

class DashboardController extends ChangeNotifier {
  final ActivityRepository _activityRepository;
  final HabitRepository _habitRepository;
  final TimeBlockRepository _timeBlockRepository;
  final HabitToTimeBlockService _habitToTimeBlockService;

  List<ActivityModel> _activities = [];
  List<HabitModel> _habits = [];
  List<TimeBlockModel> _timeBlocks = [];
  bool _isLoading = false;

  DashboardController({
    required ActivityRepository activityRepository,
    required HabitRepository habitRepository,
  })  : _activityRepository = activityRepository,
        _habitRepository = habitRepository,
        _timeBlockRepository = ServiceLocator.instance.timeBlockRepository,
        _habitToTimeBlockService =
            ServiceLocator.instance.habitToTimeBlockService;

  List<ActivityModel> get activities => _activities;
  List<HabitModel> get habits => _habits;
  List<TimeBlockModel> get timeBlocks => _timeBlocks;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Precarga asíncrona de timeblocks de hábitos para que estén listos antes
      _preloadHabitTimeBlocks(today);

      // Cargamos todos los datos al mismo tiempo
      final futures = await Future.wait([
        _habitRepository.getHabitsForToday(),
        _activityRepository.getActivitiesByDate(today),
        _timeBlockRepository.getTimeBlocksByDate(today),
      ]);

      _habits = futures[0] as List<HabitModel>;
      _activities = futures[1] as List<ActivityModel>;
      _timeBlocks = futures[2] as List<TimeBlockModel>;

      debugPrint('Cargando hábitos para hoy: ${today.toString()}');
      debugPrint('Hábitos cargados: ${_habits.length}');

      debugPrint('Cargando actividades para hoy: ${today.toString()}');
      debugPrint('Actividades cargadas: ${_activities.length}');

      debugPrint('Cargando timeblocks para hoy: ${today.toString()}');
      debugPrint('Timeblocks iniciales cargados: ${_timeBlocks.length}');

      // Ordenamos los elementos por hora
      _sortAllLists();

      debugPrint(
          'Total de items cargados: ${_activities.length + _habits.length + _timeBlocks.length}');
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Precarga de timeblocks para hábitos sin bloquear la UI
  Future<void> _preloadHabitTimeBlocks(DateTime date) async {
    try {
      // Obtener los hábitos para hoy
      final habitsForToday = await _habitRepository.getHabitsForToday();

      // Si no hay hábitos, no hacemos nada
      if (habitsForToday.isEmpty) return;

      // Actualizar timeblocks para estos hábitos en segundo plano
      // Usando una versión simplificada sin unawaited
      _createTimeBlocksInBackground(habitsForToday, date).then((_) {
        debugPrint('Timeblocks precargados completados');
      });
    } catch (e) {
      debugPrint('Error en precarga de timeblocks: $e');
    }
  }

  // Método para crear timeblocks en segundo plano sin bloquear la UI
  Future<void> _createTimeBlocksInBackground(
      List<HabitModel> habits, DateTime date) async {
    try {
      await _habitToTimeBlockService.convertHabitsToTimeBlocks(date);
      debugPrint('Timeblocks precargados en segundo plano');
    } catch (e) {
      debugPrint('Error creando timeblocks en segundo plano: $e');
    }
  }

  // Método para ordenar todas las listas por hora
  void _sortAllLists() {
    // Ordenar actividades por hora de inicio
    _activities.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Ordenar hábitos por hora
    _habits.sort((a, b) => a.time.hour.compareTo(b.time.hour));

    // Ordenar timeblocks por hora de inicio
    _timeBlocks.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _activityRepository.deleteActivity(activityId);
      await loadData();
    } catch (e) {
      debugPrint('Error al eliminar actividad: $e');
      rethrow;
    }
  }

  Future<void> toggleActivityCompletion(String activityId) async {
    try {
      await _activityRepository.toggleActivityCompletion(activityId);
      await loadData();
    } catch (e) {
      debugPrint('Error al cambiar estado de actividad: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(HabitModel habit) async {
    try {
      await _habitRepository.deleteHabit(habit.id);
      // También eliminar los timeblocks asociados
      await _habitToTimeBlockService.deleteTimeBlocksForHabit(habit);
      await loadData();
    } catch (e) {
      debugPrint('Error al eliminar hábito: $e');
      rethrow;
    }
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    try {
      await _habitRepository.markHabitAsCompleted(habit.id);
      // Actualizar el estado de los timeblocks asociados
      await _habitToTimeBlockService.syncTimeBlocksForHabit(habit);
      await loadData();
    } catch (e) {
      debugPrint('Error al cambiar estado de hábito: $e');
      rethrow;
    }
  }

  String _getCurrentPeriod() {
    final now = TimeOfDay.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 18) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  List<ActivityModel> getMorningActivities() {
    return _activities.where((activity) {
      final hour = activity.startTime.hour;
      return hour >= 5 && hour < 12;
    }).toList();
  }

  List<ActivityModel> getAfternoonActivities() {
    return _activities.where((activity) {
      final hour = activity.startTime.hour;
      return hour >= 12 && hour < 18;
    }).toList();
  }

  List<ActivityModel> getEveningActivities() {
    return _activities.where((activity) {
      final hour = activity.startTime.hour;
      return hour >= 18 || hour < 5;
    }).toList();
  }

  List<HabitModel> getCurrentPeriodHabits() {
    final period = _getCurrentPeriod();
    final filteredHabits = <HabitModel>[];

    for (final habit in _habits) {
      final hour = habit.time.hour;

      if (period == 'morning' && hour >= 5 && hour < 12) {
        filteredHabits.add(habit);
      } else if (period == 'afternoon' && hour >= 12 && hour < 18) {
        filteredHabits.add(habit);
      } else if (period == 'evening' && (hour >= 18 || hour < 5)) {
        filteredHabits.add(habit);
      }
    }

    return filteredHabits;
  }

  List<HabitModel> getMorningHabits() {
    return _habits.where((habit) {
      final hour = habit.time.hour;
      return hour >= 5 && hour < 12;
    }).toList();
  }

  List<HabitModel> getAfternoonHabits() {
    return _habits.where((habit) {
      final hour = habit.time.hour;
      return hour >= 12 && hour < 18;
    }).toList();
  }

  List<HabitModel> getEveningHabits() {
    return _habits.where((habit) {
      final hour = habit.time.hour;
      return hour >= 18 || hour < 5;
    }).toList();
  }
}
