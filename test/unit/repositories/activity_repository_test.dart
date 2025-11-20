import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/core/services/local_storage.dart';
import 'package:temposage/core/services/service_locator.dart';

class MockTimeBlockRepository extends Mock implements TimeBlockRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ActivityRepository repository;
  late MockTimeBlockRepository mockTimeBlockRepository;
  late Directory tempDir;

  final testActivity1 = ActivityModel(
    id: 'activity-1',
    title: 'Test Activity 1',
    description: 'Test Description 1',
    category: 'Work',
    startTime: DateTime(2023, 5, 15, 10, 0),
    endTime: DateTime(2023, 5, 15, 11, 0),
    priority: 'High',
    sendReminder: true,
    reminderMinutesBefore: 15,
    isCompleted: false,
  );

  final testActivity2 = ActivityModel(
    id: 'activity-2',
    title: 'Test Activity 2',
    description: 'Test Description 2',
    category: 'Personal',
    startTime: DateTime(2023, 5, 15, 14, 0),
    endTime: DateTime(2023, 5, 15, 15, 0),
    priority: 'Medium',
    sendReminder: false,
    isCompleted: true,
  );

  final testActivity3 = ActivityModel(
    id: 'activity-3',
    title: 'Test Activity 3',
    description: 'Test Description 3',
    category: 'Study',
    startTime: DateTime(2023, 5, 16, 10, 0),
    endTime: DateTime(2023, 5, 16, 11, 0),
    priority: 'Low',
    isCompleted: false,
  );

  setUpAll(() {
    registerFallbackValue(ActivityModel(
      id: '',
      title: '',
      description: '',
      category: '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    ));
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('temposage_test_');
    await LocalStorage.init(path: tempDir.path);
    
    mockTimeBlockRepository = MockTimeBlockRepository();
    repository = ActivityRepository(
      timeBlockRepository: mockTimeBlockRepository,
    );

    when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
        .thenAnswer((_) async => []);
    when(() => mockTimeBlockRepository.updateTimeBlock(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await LocalStorage.clearBox('activities');
    await LocalStorage.closeBox('activities');
    await LocalStorage.closeAll();
    await tempDir.delete(recursive: true);
  });

  group('ActivityRepository - init', () {
    test('init debería inicializar el repositorio correctamente', () async {
      await repository.init();
      expect(repository, isNotNull);
    });
  });

  group('ActivityRepository - getAllActivities', () {
    test('getAllActivities debería retornar todas las actividades', () async {
      await LocalStorage.saveData('activities', testActivity1.id, testActivity1);
      await LocalStorage.saveData('activities', testActivity2.id, testActivity2);
      await LocalStorage.saveData('activities', testActivity3.id, testActivity3);

      final result = await repository.getAllActivities();

      expect(result.length, 3);
      expect(result.map((a) => a.id), containsAll([testActivity1.id, testActivity2.id, testActivity3.id]));
    });

    test('getAllActivities debería retornar lista vacía si no hay actividades',
        () async {
      final result = await repository.getAllActivities();
      expect(result, isEmpty);
    });
  });

  group('ActivityRepository - getActivitiesByDate', () {
    test('getActivitiesByDate debería retornar actividades para una fecha específica',
        () async {
      when(() => mockLocalStorage.getAllData<ActivityModel>(any()))
          .thenAnswer((_) async => [testActivity1, testActivity2, testActivity3]);

      final date = DateTime(2023, 5, 15);
      final result = await repository.getActivitiesByDate(date);

      expect(result.length, 2);
      expect(result, contains(testActivity1));
      expect(result, contains(testActivity2));
      expect(result, isNot(contains(testActivity3)));
    });

    test('getActivitiesByDate debería retornar lista vacía si no hay actividades para la fecha',
        () async {
      when(() => mockLocalStorage.getAllData<ActivityModel>(any()))
          .thenAnswer((_) async => [testActivity3]);

      final date = DateTime(2023, 5, 15);
      final result = await repository.getActivitiesByDate(date);

      expect(result, isEmpty);
    });

    test('getActivitiesByDate debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.getAllData<ActivityModel>(any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.getActivitiesByDate(DateTime(2023, 5, 15)),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });
  });

  group('ActivityRepository - getActivity', () {
    test('getActivity debería retornar una actividad específica por ID', () async {
      when(() => mockLocalStorage.getData<ActivityModel>(any(), any()))
          .thenAnswer((_) async => testActivity1);

      final result = await repository.getActivity('activity-1');

      expect(result, equals(testActivity1));
      expect(result?.id, equals('activity-1'));
    });

    test('getActivity debería retornar null si el ID no existe', () async {
      when(() => mockLocalStorage.getData<ActivityModel>(any(), any()))
          .thenAnswer((_) async => null);

      final result = await repository.getActivity('non-existent-id');

      expect(result, isNull);
    });

    test('getActivity debería lanzar excepción si el ID está vacío', () async {
      expect(
        () => repository.getActivity(''),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });

    test('getActivity debería lanzar excepción si hay error', () async {
      when(() => mockLocalStorage.getData<ActivityModel>(any(), any()))
          .thenThrow(Exception('Storage error'));

      expect(
        () => repository.getActivity('activity-1'),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });
  });

  group('ActivityRepository - addActivity', () {
    test('addActivity debería agregar una nueva actividad', () async {
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.addActivity(testActivity1);

      verify(() => mockLocalStorage.saveData<ActivityModel>(
            'activities',
            testActivity1.id,
            testActivity1,
          )).called(1);
    });

    test('addActivity debería sincronizar con TimeBlock si no existe', () async {
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.addActivity(testActivity1);

      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(1);
      verify(() => mockActivityToTimeBlockService.convertSingleActivityToTimeBlock(testActivity1))
          .called(1);
    });

    test('addActivity debería programar notificación si sendReminder es true',
        () async {
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      final activityWithReminder = testActivity1.copyWith(sendReminder: true);
      await repository.addActivity(activityWithReminder);

      verify(() => mockActivityNotificationService.scheduleActivityNotification(
            activityWithReminder,
          )).called(1);
    });

    test('addActivity no debería programar notificación si sendReminder es false',
        () async {
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      final activityWithoutReminder = testActivity1.copyWith(sendReminder: false);
      await repository.addActivity(activityWithoutReminder);

      verifyNever(() => mockActivityNotificationService.scheduleActivityNotification(any()));
    });
  });

  group('ActivityRepository - updateActivity', () {
    test('updateActivity debería actualizar una actividad existente', () async {
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      final updatedActivity = testActivity1.copyWith(title: 'Updated Title');
      await repository.updateActivity(updatedActivity);

      verify(() => mockLocalStorage.saveData<ActivityModel>(
            'activities',
            updatedActivity.id,
            updatedActivity,
          )).called(1);
      verify(() => mockActivityNotificationService.updateActivityNotification(updatedActivity))
          .called(1);
    });

    test('updateActivity debería sincronizar con TimeBlock', () async {
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.updateActivity(testActivity1);

      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(1);
    });
  });

  group('ActivityRepository - toggleActivityCompletion', () {
    test('toggleActivityCompletion debería cambiar el estado de completado', () async {
      when(() => mockLocalStorage.getData<ActivityModel>(any(), any()))
          .thenAnswer((_) async => testActivity1);
      when(() => mockLocalStorage.saveData<ActivityModel>(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.toggleActivityCompletion('activity-1');

      verify(() => mockLocalStorage.getData<ActivityModel>('activities', 'activity-1'))
          .called(1);
    });

    test('toggleActivityCompletion debería lanzar excepción si el ID está vacío',
        () async {
      expect(
        () => repository.toggleActivityCompletion(''),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });

    test('toggleActivityCompletion debería lanzar excepción si la actividad no existe',
        () async {
      when(() => mockLocalStorage.getData<ActivityModel>(any(), any()))
          .thenAnswer((_) async => null);

      expect(
        () => repository.toggleActivityCompletion('non-existent-id'),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });
  });

  group('ActivityRepository - deleteActivity', () {
    test('deleteActivity debería eliminar una actividad', () async {
      when(() => mockLocalStorage.deleteData(any(), any()))
          .thenAnswer((_) async {});

      await repository.deleteActivity('activity-1');

      verify(() => mockLocalStorage.deleteData('activities', 'activity-1')).called(1);
      verify(() => mockActivityNotificationService.cancelActivityNotification('activity-1'))
          .called(1);
    });

    test('deleteActivity debería lanzar excepción si el ID está vacío', () async {
      expect(
        () => repository.deleteActivity(''),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });

    test('deleteActivity debería eliminar del almacenamiento incluso si no está en memoria',
        () async {
      when(() => mockLocalStorage.deleteData(any(), any()))
          .thenAnswer((_) async {});

      await repository.deleteActivity('activity-not-in-memory');

      verify(() => mockLocalStorage.deleteData('activities', 'activity-not-in-memory'))
          .called(1);
    });
  });
}

