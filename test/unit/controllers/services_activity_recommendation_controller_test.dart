import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/services/activity_recommendation_controller.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/core/di/service_locator.dart';
import 'package:get_it/get_it.dart';

class MockRecommendationService extends Mock implements RecommendationService {}

class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ActivityRecommendationController (services) Tests', () {
    late ActivityRecommendationController controller;
    late MockRecommendationService mockRecommendationService;
    late MockActivityRepository mockActivityRepository;
    late GetIt getItInstance;

    setUp(() {
      mockRecommendationService = MockRecommendationService();
      mockActivityRepository = MockActivityRepository();
      getItInstance = GetIt.instance;

      // Registrar mocks en GetIt si no están registrados
      if (!getItInstance.isRegistered<ActivityRepository>()) {
        getItInstance.registerFactory<ActivityRepository>(
          () => mockActivityRepository,
        );
      }

      controller = ActivityRecommendationController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Constructor y getters', () {
      test('debería inicializar con valores por defecto', () {
        // Assert
        expect(controller.isLoading, isTrue);
        expect(controller.resultMessage, equals('Inicializando...'));
        expect(controller.recommendations, isEmpty);
        expect(controller.activityDetails, isNotNull);
        expect(controller.isModelInitialized, isFalse);
        expect(controller.recentlyCreatedActivities, isEmpty);
      });
    });

    group('initialize', () {
      test('debería inicializar el servicio correctamente', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});

        // Act
        await controller.initialize();

        // Assert
        expect(controller.isModelInitialized, isTrue);
        expect(controller.isLoading, isFalse);
        expect(controller.resultMessage, equals('Modelo cargado correctamente'));
        verify(() => mockRecommendationService.initialize()).called(1);
      });

      test('debería manejar errores durante la inicialización', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenThrow(Exception('Initialization error'));

        // Act
        try {
          await controller.initialize();
        } catch (e) {
          // Expected to throw
        }

        // Assert
        expect(controller.isModelInitialized, isFalse);
        expect(controller.isLoading, isFalse);
        expect(controller.resultMessage, contains('Error al cargar el modelo'));
      });

      test('debería no inicializar si ya está inicializado', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});

        // Act
        await controller.initialize();
        await controller.initialize();

        // Assert
        verify(() => mockRecommendationService.initialize()).called(1);
      });
    });

    group('_loadActivityMapping', () {
      test('debería cargar el mapeo de actividades correctamente', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});

        // Act
        await controller.initialize();

        // Assert
        expect(controller.activityDetails, isNotNull);
        expect(controller.activityDetails!.length, greaterThan(0));
      });
    });

    group('getRecommendations', () {
      test('debería obtener recomendaciones correctamente', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        when(() => mockActivityRepository.getActivitiesByDate(today))
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
            )).thenAnswer((_) async => [
          {'title': 'Actividad 1'},
          {'title': 'Actividad 2'},
        ]);

        // Act
        await controller.initialize();
        await controller.getRecommendations();

        // Assert
        expect(controller.recommendations.length, 2);
        expect(controller.isLoading, isFalse);
        expect(controller.resultMessage, contains('exitosamente'));
      });

      test('debería manejar errores durante la obtención de recomendaciones',
          () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        when(() => mockActivityRepository.getActivitiesByDate(today))
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
            )).thenThrow(Exception('Recommendation error'));

        // Act
        await controller.initialize();
        await controller.getRecommendations();

        // Assert
        expect(controller.isLoading, isFalse);
        expect(controller.resultMessage, contains('Error'));
      });

      test('debería filtrar actividades recientemente creadas', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        when(() => mockActivityRepository.getActivitiesByDate(today))
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
            )).thenAnswer((_) async => [
          {'title': 'Actividad 1'},
          {'title': 'Actividad 2'},
        ]);

        // Act
        await controller.initialize();
        await controller.getRecommendations();
        controller.recentlyCreatedActivities.add('Actividad 1');
        await controller.getRecommendations();

        // Assert
        expect(controller.recommendations.length, 1);
      });
    });

    group('getActivityTitle', () {
      test('debería retornar el título de la actividad', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        await controller.initialize();

        // Act
        final title = controller.getActivityTitle('1');

        // Assert
        expect(title, isNotEmpty);
        expect(title, isNot(equals('Actividad 1')));
      });

      test('debería retornar título por defecto si no existe', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        await controller.initialize();

        // Act
        final title = controller.getActivityTitle('999');

        // Assert
        expect(title, equals('Actividad 999'));
      });
    });

    group('getActivityCategory', () {
      test('debería retornar la categoría de la actividad', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        await controller.initialize();

        // Act
        final category = controller.getActivityCategory('1');

        // Assert
        expect(category, isNotEmpty);
        expect(category, isNot(equals('Sin categoría')));
      });

      test('debería retornar categoría por defecto si no existe', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        await controller.initialize();

        // Act
        final category = controller.getActivityCategory('999');

        // Assert
        expect(category, equals('Sin categoría'));
      });
    });

    group('getActivityDescription', () {
      test('debería retornar la descripción de la actividad', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        await controller.initialize();

        // Act
        final description = controller.getActivityDescription('1');

        // Assert
        expect(description, isNotEmpty);
      });

      test('debería retornar descripción vacía si no existe', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        await controller.initialize();

        // Act
        final description = controller.getActivityDescription('999');

        // Assert
        expect(description, isEmpty);
      });
    });

    group('createActivityFromRecommendation', () {
      test('debería crear una actividad desde una recomendación', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        when(() => mockActivityRepository.getActivitiesByDate(today))
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
            )).thenAnswer((_) async => []);
        when(() => mockActivityRepository.addActivity(any()))
            .thenAnswer((_) async {});

        // Act
        await controller.initialize();
        final activity = await controller.createActivityFromRecommendation('1');

        // Assert
        expect(activity, isNotNull);
        expect(activity!.title, isNotEmpty);
        expect(activity.category, isNotEmpty);
      });

      test('debería usar tiempos por defecto si no se proporcionan', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        when(() => mockActivityRepository.getActivitiesByDate(today))
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
            )).thenAnswer((_) async => []);
        when(() => mockActivityRepository.addActivity(any()))
            .thenAnswer((_) async {});

        // Act
        await controller.initialize();
        final activity = await controller.createActivityFromRecommendation('1');

        // Assert
        expect(activity, isNotNull);
        expect(activity!.startTime, isNotNull);
        expect(activity.endTime, isNotNull);
        expect(activity.endTime.difference(activity.startTime).inHours, 1);
      });

      test('debería manejar errores durante la creación', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockActivityRepository.addActivity(any()))
            .thenThrow(Exception('Add error'));

        // Act
        await controller.initialize();
        final activity = await controller.createActivityFromRecommendation('1');

        // Assert
        expect(activity, isNull);
      });

      test('debería añadir a recentlyCreatedActivities', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        when(() => mockActivityRepository.getActivitiesByDate(today))
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
            )).thenAnswer((_) async => []);
        when(() => mockActivityRepository.addActivity(any()))
            .thenAnswer((_) async {});

        // Act
        await controller.initialize();
        await controller.createActivityFromRecommendation('1');

        // Assert
        expect(controller.recentlyCreatedActivities, isNotEmpty);
      });
    });
  });
}

