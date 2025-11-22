import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/domain/usecases/suggest_optimal_time_use_case.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockTimeBlockRepository extends Mock implements TimeBlockRepository {}

void main() {
  late SuggestOptimalTimeUseCase useCase;
  late MockActivityRepository mockActivityRepository;
  late MockTimeBlockRepository mockTimeBlockRepository;

  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockTimeBlockRepository = MockTimeBlockRepository();
    useCase = SuggestOptimalTimeUseCase(
      activityRepository: mockActivityRepository,
      timeBlockRepository: mockTimeBlockRepository,
    );
  });

  group('SuggestOptimalTimeUseCase - execute', () {
    test('debería retornar slots libres cuando no hay actividades ni timeblocks',
        () async {
      final targetDate = DateTime(2023, 5, 15);
      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenAnswer((_) async => []);
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(targetDate))
          .thenAnswer((_) async => []);

      final result = await useCase.execute(
        activityCategory: 'Work',
        pastActivities: [],
        targetDate: targetDate,
      );

      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result[0]['score'], 1.0);
    });

    test('debería encontrar slots libres entre actividades ocupadas', () async {
      final targetDate = DateTime(2023, 5, 15);
      final activity1 = ActivityModel(
        id: 'activity-1',
        title: 'Morning Meeting',
        description: 'Team meeting',
        category: 'Work',
        startTime: DateTime(2023, 5, 15, 9, 0),
        endTime: DateTime(2023, 5, 15, 10, 0),
      );
      final activity2 = ActivityModel(
        id: 'activity-2',
        title: 'Lunch',
        description: 'Lunch break',
        category: 'Personal',
        startTime: DateTime(2023, 5, 15, 13, 0),
        endTime: DateTime(2023, 5, 15, 14, 0),
      );

      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenAnswer((_) async => [activity1, activity2]);
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(targetDate))
          .thenAnswer((_) async => []);

      final result = await useCase.execute(
        activityCategory: 'Work',
        pastActivities: [],
        targetDate: targetDate,
      );

      expect(result, isNotEmpty);
      expect(result.length, greaterThan(0));
    });

    test('debería considerar timeblocks existentes al calcular slots libres',
        () async {
      final targetDate = DateTime(2023, 5, 15);
      final timeBlock = TimeBlockModel.create(
        title: 'Existing Block',
        description: 'Test',
        startTime: DateTime(2023, 5, 15, 11, 0),
        endTime: DateTime(2023, 5, 15, 12, 0),
        category: 'Work',
        color: '#7AA2F7',
      );

      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenAnswer((_) async => []);
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(targetDate))
          .thenAnswer((_) async => [timeBlock]);

      final result = await useCase.execute(
        activityCategory: 'Work',
        pastActivities: [],
        targetDate: targetDate,
      );

      expect(result, isNotEmpty);
    });

    test('debería sugerir siguiente día si no hay slots libres', () async {
      final targetDate = DateTime(2023, 5, 15);
      final activities = List.generate(10, (index) {
        return ActivityModel(
          id: 'activity-$index',
          title: 'Activity $index',
          description: 'Test',
          category: 'Work',
          startTime: DateTime(2023, 5, 15, 8 + index, 0),
          endTime: DateTime(2023, 5, 15, 9 + index, 0),
        );
      });

      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenAnswer((_) async => activities);
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(targetDate))
          .thenAnswer((_) async => []);

      final result = await useCase.execute(
        activityCategory: 'Work',
        pastActivities: [],
        targetDate: targetDate,
      );

      expect(result, isNotEmpty);
    });

    test('debería lanzar excepción si hay error al obtener actividades',
        () async {
      final targetDate = DateTime(2023, 5, 15);
      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenThrow(Exception('Database error'));

      expect(
        () => useCase.execute(
          activityCategory: 'Work',
          pastActivities: [],
          targetDate: targetDate,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SuggestOptimalTimeUseCase - executeWithExplanation', () {
    test('debería retornar sugerencias con explicación', () async {
      final targetDate = DateTime(2023, 5, 15);
      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenAnswer((_) async => []);
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(targetDate))
          .thenAnswer((_) async => []);

      final result = await useCase.executeWithExplanation(
        activityCategory: 'Work',
        pastActivities: [],
        targetDate: targetDate,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['suggestions'], isNotEmpty);
      expect(result['explanation'], isA<String>());
      expect(result['explanation'], isNotEmpty);
    });

    test('debería lanzar excepción si hay error', () async {
      final targetDate = DateTime(2023, 5, 15);
      when(() => mockActivityRepository.getActivitiesByDate(targetDate))
          .thenThrow(Exception('Database error'));

      expect(
        () => useCase.executeWithExplanation(
          activityCategory: 'Work',
          pastActivities: [],
          targetDate: targetDate,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

