import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/domain/services/activity_to_timeblock_service.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/habits/data/repositories/habit_repository.dart';
import 'package:temposage/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:temposage/features/habits/domain/services/habit_to_timeblock_service.dart';
import 'package:flutter/foundation.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return instance;
  }

  ServiceLocator._internal() {
    _initRepositories();
  }

  // Repositories
  late final ActivityRepository _activityRepository;
  late final TimeBlockRepository _timeBlockRepository;
  late final HabitRepository _habitRepository;

  // Services
  ActivityToTimeBlockService? _activityToTimeBlockService;
  HabitToTimeBlockService? _habitToTimeBlockService;

  void _initRepositories() {
    _timeBlockRepository = TimeBlockRepository();
    _habitRepository = HabitRepositoryImpl();
    _activityRepository = ActivityRepository(
      timeBlockRepository: _timeBlockRepository,
    );
  }

  ActivityRepository get activityRepository => _activityRepository;
  TimeBlockRepository get timeBlockRepository => _timeBlockRepository;
  HabitRepository get habitRepository => _habitRepository;

  Future<void> initializeAll() async {
    await _activityRepository.init();
    await _timeBlockRepository.init();
    await _habitRepository.init();
    debugPrint('Todos los repositorios inicializados');
  }

  ActivityToTimeBlockService get activityToTimeBlockService {
    _activityToTimeBlockService ??= ActivityToTimeBlockService(
      activityRepository: activityRepository,
      timeBlockRepository: timeBlockRepository,
    );
    return _activityToTimeBlockService!;
  }

  HabitToTimeBlockService get habitToTimeBlockService {
    _habitToTimeBlockService ??=
        HabitToTimeBlockService(habitRepository, timeBlockRepository);
    return _habitToTimeBlockService!;
  }
}
