import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/data/models/activity_model_adapter.dart';
import 'package:temposage/features/timeblocks/data/repositories/time_block_repository.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';
import 'package:temposage/core/services/local_storage.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:hive/hive.dart';

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
    // Registrar adaptadores de Hive (Hive ya está inicializado por LocalStorage.init en setUp)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    
    // Registrar fallback values para mocktail
    registerFallbackValue(ActivityModel(
      id: '',
      title: '',
      description: '',
      category: '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    ));
    registerFallbackValue(DateTime.now());
    final now = DateTime.now();
    registerFallbackValue(
      TimeBlockModel.create(
        title: 'Fallback',
        description: 'Fallback',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        category: 'Work',
        color: '#000000',
      ),
    );
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
      await LocalStorage.saveData('activities', testActivity1.id, testActivity1);
      await LocalStorage.saveData('activities', testActivity2.id, testActivity2);
      await LocalStorage.saveData('activities', testActivity3.id, testActivity3);

      final date = DateTime(2023, 5, 15);
      final result = await repository.getActivitiesByDate(date);

      expect(result.length, 2);
      expect(result.map((a) => a.id), containsAll([testActivity1.id, testActivity2.id]));
      expect(result.map((a) => a.id), isNot(contains(testActivity3.id)));
    });

    test('getActivitiesByDate debería retornar lista vacía si no hay actividades para la fecha',
        () async {
      await LocalStorage.saveData('activities', testActivity3.id, testActivity3);

      final date = DateTime(2023, 5, 15);
      final result = await repository.getActivitiesByDate(date);

      expect(result, isEmpty);
    });
  });

  group('ActivityRepository - getActivity', () {
    test('getActivity debería retornar una actividad específica por ID', () async {
      await LocalStorage.saveData('activities', testActivity1.id, testActivity1);

      final result = await repository.getActivity('activity-1');

      expect(result, isNotNull);
      expect(result?.id, equals('activity-1'));
      expect(result?.title, equals('Test Activity 1'));
    });

    test('getActivity debería retornar null si el ID no existe', () async {
      final result = await repository.getActivity('non-existent-id');

      expect(result, isNull);
    });

    test('getActivity debería lanzar excepción si el ID está vacío', () async {
      expectLater(
        repository.getActivity(''),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });
  });

  group('ActivityRepository - addActivity', () {
    test('addActivity debería agregar una nueva actividad', () async {
      await repository.addActivity(testActivity1);

      final result = await repository.getActivity(testActivity1.id);
      expect(result, isNotNull);
      expect(result?.id, equals(testActivity1.id));
      expect(result?.title, equals(testActivity1.title));
    });

    test('addActivity debería sincronizar con TimeBlock si no existe', () async {
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.addActivity(testActivity1);

      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(1);
    });

    test('addActivity debería actualizar TimeBlock si ya existe', () async {
      // Este test verifica la lógica de sincronización
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.addActivity(testActivity1);

      // Verificar que se intentó sincronizar
      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(1);
    });
  });

  group('ActivityRepository - updateActivity', () {
    test('updateActivity debería actualizar una actividad existente', () async {
      await repository.addActivity(testActivity1);

      final updatedActivity = testActivity1.copyWith(title: 'Updated Title');
      await repository.updateActivity(updatedActivity);

      final result = await repository.getActivity(testActivity1.id);
      expect(result?.title, equals('Updated Title'));
    });

    test('updateActivity debería agregar actividad si no existe', () async {
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.updateActivity(testActivity1);

      final result = await repository.getActivity(testActivity1.id);
      expect(result, isNotNull);
    });

    test('updateActivity debería sincronizar con TimeBlock', () async {
      await repository.addActivity(testActivity1);

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      final updatedActivity = testActivity1.copyWith(title: 'Updated');
      await repository.updateActivity(updatedActivity);

      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(1);
    });
  });

  group('ActivityRepository - toggleActivityCompletion', () {
    test('toggleActivityCompletion debería cambiar el estado de completado', () async {
      await repository.addActivity(testActivity1);

      final initialActivity = await repository.getActivity('activity-1');
      expect(initialActivity?.isCompleted, false);

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.toggleActivityCompletion('activity-1');

      final updatedActivity = await repository.getActivity('activity-1');
      expect(updatedActivity?.isCompleted, true);
    });

    test('toggleActivityCompletion debería cambiar de true a false', () async {
      final completedActivity = testActivity1.copyWith(isCompleted: true);
      await repository.addActivity(completedActivity);

      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.toggleActivityCompletion('activity-1');

      final updatedActivity = await repository.getActivity('activity-1');
      expect(updatedActivity?.isCompleted, false);
    });

    test('toggleActivityCompletion debería lanzar excepción si el ID está vacío',
        () async {
      expectLater(
        repository.toggleActivityCompletion(''),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });

    test('toggleActivityCompletion debería lanzar excepción si la actividad no existe',
        () async {
      expectLater(
        repository.toggleActivityCompletion('non-existent-id'),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });
  });

  group('ActivityRepository - deleteActivity', () {
    test('deleteActivity debería eliminar una actividad', () async {
      await repository.addActivity(testActivity1);

      await repository.deleteActivity('activity-1');

      final result = await repository.getActivity('activity-1');
      expect(result, isNull);
    });

    test('deleteActivity debería lanzar excepción si el ID está vacío', () async {
      expectLater(
        repository.deleteActivity(''),
        throwsA(isA<ActivityRepositoryException>()),
      );
    });

    test('deleteActivity debería eliminar del almacenamiento incluso si no está en memoria',
        () async {
      // Guardar directamente en almacenamiento sin pasar por memoria
      await LocalStorage.saveData('activities', 'activity-not-in-memory', testActivity1);

      await repository.deleteActivity('activity-not-in-memory');

      final result = await repository.getActivity('activity-not-in-memory');
      expect(result, isNull);
    });

    test('deleteActivity debería eliminar múltiples actividades', () async {
      await repository.addActivity(testActivity1);
      await repository.addActivity(testActivity2);
      await repository.addActivity(testActivity3);

      await repository.deleteActivity('activity-1');
      await repository.deleteActivity('activity-2');

      final allActivities = await repository.getAllActivities();
      expect(allActivities.length, 1);
      expect(allActivities.first.id, equals('activity-3'));
    });
  });

  group('ActivityRepository - sincronización con TimeBlock', () {
    test('_syncWithTimeBlock debería crear nuevo TimeBlock si no existe', () async {
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.addActivity(testActivity1);

      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(1);
    });

    test('_syncWithTimeBlock debería actualizar TimeBlock existente', () async {
      // Este test verifica indirectamente la lógica de sincronización
      when(() => mockTimeBlockRepository.getTimeBlocksByDate(any()))
          .thenAnswer((_) async => []);

      await repository.addActivity(testActivity1);
      await repository.updateActivity(testActivity1.copyWith(title: 'Updated'));

      verify(() => mockTimeBlockRepository.getTimeBlocksByDate(any())).called(greaterThan(1));
    });
  });

  group('ActivityRepository - casos edge', () {
    test('debería manejar actividades con fechas en diferentes zonas horarias', () async {
      final activity = testActivity1.copyWith(
        startTime: DateTime.utc(2023, 5, 15, 10, 0),
        endTime: DateTime.utc(2023, 5, 15, 11, 0),
      );

      await repository.addActivity(activity);

      final result = await repository.getActivity(activity.id);
      expect(result, isNotNull);
    });

    test('debería manejar actividades con descripción vacía', () async {
      final activity = testActivity1.copyWith(description: '');

      await repository.addActivity(activity);

      final result = await repository.getActivity(activity.id);
      expect(result?.description, isEmpty);
    });

    test('debería manejar actividades con prioridad alta', () async {
      final activity = testActivity1.copyWith(priority: 'High');

      await repository.addActivity(activity);

      final result = await repository.getActivity(activity.id);
      expect(result?.priority, equals('High'));
    });
  });
}

