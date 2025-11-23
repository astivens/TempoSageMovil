import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/domain/services/activity_to_timeblock_service.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockTimeBlockRepository extends Mock implements TimeBlockRepository {}

void main() {
  late ActivityToTimeBlockService service;
  late MockActivityRepository mockActivityRepository;
  late MockTimeBlockRepository mockTimeBlockRepository;

  setUpAll(() {
    registerFallbackValue(
      TimeBlockModel.create(
        title: 'Fallback',
        description: 'Fallback',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: 'Work',
        color: '#7AA2F7',
      ),
    );
  });

  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockTimeBlockRepository = MockTimeBlockRepository();
    service = ActivityToTimeBlockService(
      activityRepository: mockActivityRepository,
      timeBlockRepository: mockTimeBlockRepository,
    );
  });

  group('ActivityToTimeBlockService - convertSingleActivityToTimeBlock', () {
    test('debería crear un nuevo TimeBlock cuando no existe uno similar',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Test Activity',
        description: 'Test Description',
        category: 'Work',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
        priority: 'High',
      );

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);
      when(() => mockTimeBlockRepository.addTimeBlock(any()))
          .thenAnswer((_) async {});

      final result = await service.convertSingleActivityToTimeBlock(activity);

      expect(result, isNotNull);
      expect(result?.title, equals(activity.title));
      expect(result?.startTime, equals(activity.startTime));
      expect(result?.endTime, equals(activity.endTime));
      expect(result?.category, equals(activity.category));
      expect(result?.isFocusTime, isTrue);
      verify(() => mockTimeBlockRepository.addTimeBlock(any())).called(1);
    });

    test('debería actualizar TimeBlock existente cuando ya existe uno similar',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Test Activity',
        description: 'Test Description',
        category: 'Work',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
        priority: 'High',
      );

      final existingTimeBlock = TimeBlockModel.create(
        title: 'Test Activity',
        description: '[ACTIVITY_GENERATED] ID: activity-1',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
        category: 'Work',
        color: '#7AA2F7',
      );

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => [existingTimeBlock]);
      when(() => mockTimeBlockRepository.updateTimeBlock(any()))
          .thenAnswer((_) async {});

      final result = await service.convertSingleActivityToTimeBlock(activity);

      expect(result, isNotNull);
      verify(() => mockTimeBlockRepository.updateTimeBlock(any())).called(1);
      verifyNever(() => mockTimeBlockRepository.addTimeBlock(any()));
    });

    test('debería crear TimeBlock con isFocusTime true cuando priority es High',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'High Priority Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
        priority: 'High',
      );

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);
      when(() => mockTimeBlockRepository.addTimeBlock(any()))
          .thenAnswer((_) async {});

      final result = await service.convertSingleActivityToTimeBlock(activity);

      expect(result, isNotNull);
      expect(result?.isFocusTime, isTrue);
    });

    test('debería crear TimeBlock con isFocusTime false cuando priority no es High',
        () async {
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Low Priority Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
        priority: 'Low',
      );

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);
      when(() => mockTimeBlockRepository.addTimeBlock(any()))
          .thenAnswer((_) async {});

      final result = await service.convertSingleActivityToTimeBlock(activity);

      expect(result, isNotNull);
      expect(result?.isFocusTime, isFalse);
    });
  });

  group('ActivityToTimeBlockService - convertActivitiesToTimeBlocks', () {
    test('debería convertir múltiples actividades a TimeBlocks', () async {
      final date = DateTime(2023, 5, 15);
      final activities = [
        ActivityModel(
          id: 'activity-1',
          title: 'Activity 1',
          description: 'Test 1',
          category: 'Work',
          startTime: DateTime(2023, 5, 15, 10, 0),
          endTime: DateTime(2023, 5, 15, 11, 0),
        ),
        ActivityModel(
          id: 'activity-2',
          title: 'Activity 2',
          description: 'Test 2',
          category: 'Personal',
          startTime: DateTime(2023, 5, 15, 14, 0),
          endTime: DateTime(2023, 5, 15, 15, 0),
        ),
      ];

      // Simular que no hay TimeBlocks existentes
      when(() => mockActivityRepository.getActivitiesByDate(date))
          .thenAnswer((_) async => activities);
      // El servicio llama a getTimeBlocksByDate con activity.startTime, no con date
      // Por lo tanto, necesitamos mockear para cualquier fecha
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);
      
      // Capturar los TimeBlocks que se agregan
      final addedTimeBlocks = <TimeBlockModel>[];
      when(() => mockTimeBlockRepository.addTimeBlock(any()))
          .thenAnswer((invocation) async {
        final timeBlock = invocation.positionalArguments[0] as TimeBlockModel;
        addedTimeBlocks.add(timeBlock);
      });

      final result = await service.convertActivitiesToTimeBlocks(date);

      // El servicio debería retornar los TimeBlocks creados
      expect(result.length, equals(2));
      expect(addedTimeBlocks.length, equals(2));
      verify(() => mockTimeBlockRepository.addTimeBlock(any())).called(2);
    });

    test('debería retornar lista vacía cuando no hay actividades', () async {
      final date = DateTime(2023, 5, 15);

      when(() => mockActivityRepository.getActivitiesByDate(date))
          .thenAnswer((_) async => []);

      final result = await service.convertActivitiesToTimeBlocks(date);

      expect(result, isEmpty);
    });

    test('debería actualizar TimeBlocks existentes en lugar de crear duplicados',
        () async {
      final date = DateTime(2023, 5, 15);
      final activity = ActivityModel(
        id: 'activity-1',
        title: 'Test Activity',
        description: 'Test',
        category: 'Work',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
      );

      final existingTimeBlock = TimeBlockModel.create(
        title: 'Test Activity',
        description: '[ACTIVITY_GENERATED] ID: activity-1',
        startTime: DateTime(2023, 5, 15, 10, 0),
        endTime: DateTime(2023, 5, 15, 11, 0),
        category: 'Work',
        color: '#7AA2F7',
      );

      when(() => mockActivityRepository.getActivitiesByDate(date))
          .thenAnswer((_) async => [activity]);
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(date))
          .thenAnswer((_) async => [existingTimeBlock]);
      when(() => mockTimeBlockRepository.updateTimeBlock(any()))
          .thenAnswer((_) async {});

      final result = await service.convertActivitiesToTimeBlocks(date);

      expect(result.length, 1);
      verify(() => mockTimeBlockRepository.updateTimeBlock(any())).called(1);
      verifyNever(() => mockTimeBlockRepository.addTimeBlock(any()));
    });
  });
}

