import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/domain/services/habit_recommendation_service.dart';
import 'package:temposage/features/habits/data/repositories/habit_repository.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/data/models/time_of_day_adapter.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late HabitRecommendationService service;
  late HabitRepositoryImpl habitRepository;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(TimeOfDayConverterAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(TimeOfDayAdapter());
    }
  });

  setUp(() {
    habitRepository = HabitRepositoryImpl();
    service = HabitRecommendationService(
      recommendationService: RecommendationService(),
      habitRepository: habitRepository,
    );
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('should generate habit recommendations from real habit data', () async {
    final habitModel = HabitModel.create(
      title: 'Drink Water',
      description: 'Drink 8 glasses of water',
      daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
      category: 'Health',
      reminder: 'Daily',
      time: '08:00',
    );
    final habitEntity = Habit(
      id: habitModel.id,
      name: habitModel.title,
      description: habitModel.description,
      daysOfWeek: habitModel.daysOfWeek,
      category: habitModel.category,
      reminder: habitModel.reminder,
      time: habitModel.time,
      isDone: habitModel.isCompleted,
      dateCreation: habitModel.dateCreation,
    );
    final habitBox = await Hive.openBox<HabitModel>('habits');
    await habitBox.clear();
    await habitBox.add(habitModel);
    await habitRepository.addHabit(habitEntity);
    final recommendations = await service.getHabitRecommendations();
    expect(recommendations, isA<List<HabitModel>>());
    expect(recommendations.isNotEmpty, true);
  });
}
