import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/domain/services/activity_to_timeblock_service.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/habits/data/repositories/habit_repository.dart';
import 'package:temposage/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:temposage/features/habits/domain/services/habit_to_timeblock_service.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return instance;
  }

  ServiceLocator._internal();

  // Repositories
  ActivityRepository? _activityRepository;
  TimeBlockRepository? _timeBlockRepository;
  HabitRepository? _habitRepository;

  // Services
  ActivityToTimeBlockService? _activityToTimeBlockService;
  HabitToTimeBlockService? _habitToTimeBlockService;

  ActivityRepository get activityRepository {
    _activityRepository ??= ActivityRepository();
    return _activityRepository!;
  }

  TimeBlockRepository get timeBlockRepository {
    _timeBlockRepository ??= TimeBlockRepository();
    return _timeBlockRepository!;
  }

  HabitRepository get habitRepository {
    _habitRepository ??= HabitRepositoryImpl();
    return _habitRepository!;
  }

  ActivityToTimeBlockService get activityToTimeBlockService {
    _activityToTimeBlockService ??= ActivityToTimeBlockService(
      activityRepository: activityRepository,
      timeBlockRepository: timeBlockRepository,
    );
    return _activityToTimeBlockService!;
  }

  HabitToTimeBlockService get habitToTimeBlockService {
    _habitToTimeBlockService ??= HabitToTimeBlockService(
      habitRepository: habitRepository,
      timeBlockRepository: timeBlockRepository,
    );
    return _habitToTimeBlockService!;
  }
}
