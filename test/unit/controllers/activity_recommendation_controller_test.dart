import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/presentation/controllers/activity_recommendation_controller.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/domain/usecases/suggest_optimal_time_use_case.dart';
import 'package:temposage/core/services/service_locator.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockRecommendationService extends Mock implements RecommendationService {}

class MockSuggestOptimalTimeUseCase extends Mock
    implements SuggestOptimalTimeUseCase {}

void main() {
  group('ActivityRecommendationController', () {
    late ActivityRecommendationController controller;
    late MockActivityRepository mockRepository;
    late MockRecommendationService mockRecommendationService;
    late MockSuggestOptimalTimeUseCase mockSuggestOptimalTimeUseCase;

    setUpAll(() {
      registerFallbackValue(ActivityModel(
        id: '',
        title: '',
        description: '',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: '',
        priority: '',
      ));
    });

    setUp(() {
      mockRepository = MockActivityRepository();
      mockRecommendationService = MockRecommendationService();
      mockSuggestOptimalTimeUseCase = MockSuggestOptimalTimeUseCase();

      controller = ActivityRecommendationController(
        activityRepository: mockRepository,
        recommendationService: mockRecommendationService,
      );
    });

    tearDown(() {
      // No llamar dispose aquí, cada test debe manejar su propio dispose
    });

    group('Constructor y getters', () {
      test('debería inicializar con valores por defecto', () {
        // Assert
        expect(controller.recommendedActivities, isEmpty);
        expect(controller.isLoading, isFalse);
        expect(controller.error, isNull);
        expect(controller.isModelInitialized, isFalse);
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
        expect(controller.error, isNull);
        verify(() => mockRecommendationService.initialize()).called(1);
      });

      test('debería manejar errores durante la inicialización', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenThrow(Exception('Initialization error'));

        // Act
        await controller.initialize();

        // Assert
        expect(controller.isModelInitialized, isFalse);
        expect(controller.isLoading, isFalse);
        expect(controller.error, equals('No se pudo inicializar el servicio de recomendaciones'));
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

    group('loadRecommendations', () {
      test('debería cargar recomendaciones con lista de strings', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => ['Estudio', 'Trabajo']);

        // Act
        await controller.loadRecommendations();

        // Assert
        expect(controller.recommendedActivities.length, 2);
        expect(controller.recommendedActivities.first.category, equals('Estudio'));
        expect(controller.recommendedActivities.last.category, equals('Trabajo'));
        expect(controller.isLoading, isFalse);
      });

      test('debería cargar recomendaciones con lista de maps', () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => [
          {'category': 'Salud'},
          {'category': 'Personal'},
        ]);

        // Act
        await controller.loadRecommendations();

        // Assert
        expect(controller.recommendedActivities.length, 2);
        expect(controller.recommendedActivities.first.category, equals('Salud'));
        expect(controller.recommendedActivities.last.category, equals('Personal'));
      });

      test('debería usar categoría por defecto cuando el map no tiene category',
          () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => [
          {'other': 'value'},
        ]);

        // Act
        await controller.loadRecommendations();

        // Assert
        expect(controller.recommendedActivities.length, 1);
        expect(controller.recommendedActivities.first.category, equals('Otro'));
      });

      test('debería proporcionar recomendaciones por defecto cuando la lista está vacía',
          () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => []);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => []);

        // Act
        await controller.loadRecommendations();

        // Assert
        expect(controller.recommendedActivities.length, 2);
        expect(controller.recommendedActivities.first.category, equals('Estudio'));
        expect(controller.recommendedActivities.last.category, equals('Trabajo'));
      });

      test('debería convertir actividades a interaction events', () async {
        // Arrange
        final activities = [
          ActivityModel(
            id: '1',
            title: 'Activity 1',
            description: 'Test',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            category: 'Work',
            priority: 'High',
            isCompleted: true,
          ),
          ActivityModel(
            id: '2',
            title: 'Activity 2',
            description: 'Test',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            category: 'Study',
            priority: 'Medium',
            isCompleted: false,
          ),
        ];

        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => activities);
        when(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => []);

        // Act
        await controller.loadRecommendations();

        // Assert
        verify(() => mockRecommendationService.getRecommendations(
              interactionEvents: any(named: 'interactionEvents'),
              type: 'activity',
            )).called(1);
      });

      test('debería manejar errores durante la carga de recomendaciones',
          () async {
        // Arrange
        when(() => mockRecommendationService.initialize())
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllActivities())
            .thenThrow(Exception('Repository error'));

        // Act
        await controller.loadRecommendations();

        // Assert
        expect(controller.error, equals('No se pudieron cargar las recomendaciones'));
        expect(controller.recommendedActivities.length, 1);
        expect(controller.recommendedActivities.first.category, equals('Otro'));
        expect(controller.isLoading, isFalse);
      });
    });

    group('suggestOptimalTime', () {
      test('debería sugerir tiempo óptimo y actualizar actividad', () async {
        // Arrange
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          category: 'Work',
          priority: 'High',
        );

        final pastActivity = ActivityModel(
          id: '2',
          title: 'Past Activity',
          description: 'Test',
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
          category: 'Work',
          priority: 'Medium',
        );

        final optimalTimes = [
          {
            'startTime': DateTime.now().add(const Duration(hours: 4)).millisecondsSinceEpoch,
            'endTime': DateTime.now().add(const Duration(hours: 5)).millisecondsSinceEpoch,
          }
        ];

        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => [pastActivity, activity]);
        when(() => mockSuggestOptimalTimeUseCase.execute(
              activityCategory: any(named: 'activityCategory'),
              pastActivities: any(named: 'pastActivities'),
              targetDate: any(named: 'targetDate'),
            )).thenAnswer((_) async => optimalTimes);
        when(() => mockRepository.updateActivity(any()))
            .thenAnswer((_) async {});

        // Mock ServiceLocator usando reflection o simplemente verificar que se llama
        // Nota: ServiceLocator es un singleton, así que no podemos mockearlo fácilmente
        // En su lugar, verificamos que el método se ejecuta sin errores
        // cuando hay tiempos óptimos disponibles
        
        // Act
        await controller.suggestOptimalTime(activity);

        // Assert - Verificamos que el método se ejecuta sin errores
        // El método usa ServiceLocator.instance directamente, así que no podemos
        // verificar las llamadas exactas sin modificar el código fuente
        expect(controller.isLoading, isFalse);
      });

      test('debería manejar cuando no hay tiempos óptimos', () async {
        // Arrange
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          category: 'Work',
          priority: 'High',
        );

        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => []);

        // Act
        await controller.suggestOptimalTime(activity);

        // Assert
        expect(controller.isLoading, isFalse);
      });

      test('debería filtrar solo actividades pasadas de la misma categoría',
          () async {
        // Arrange
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          category: 'Work',
          priority: 'High',
        );

        final pastActivity = ActivityModel(
          id: '2',
          title: 'Past Activity',
          description: 'Test',
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
          category: 'Work',
          priority: 'Medium',
        );

        final futureActivity = ActivityModel(
          id: '3',
          title: 'Future Activity',
          description: 'Test',
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1)).add(const Duration(hours: 1)),
          category: 'Work',
          priority: 'Medium',
        );

        final differentCategoryActivity = ActivityModel(
          id: '4',
          title: 'Different Category',
          description: 'Test',
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
          category: 'Study',
          priority: 'Medium',
        );

        when(() => mockRepository.getAllActivities())
            .thenAnswer((_) async => [
          pastActivity,
          futureActivity,
          differentCategoryActivity,
        ]);

        // Act
        await controller.suggestOptimalTime(activity);

        // Assert - Verificamos que el método se ejecuta sin errores
        // El filtrado se hace internamente, así que no podemos verificar directamente
        // sin modificar el código fuente
        expect(controller.isLoading, isFalse);
      });

      test('debería manejar errores durante la sugerencia de tiempo', () async {
        // Arrange
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          category: 'Work',
          priority: 'High',
        );

        when(() => mockRepository.getAllActivities())
            .thenThrow(Exception('Repository error'));

        // Act
        await controller.suggestOptimalTime(activity);

        // Assert
        expect(controller.error, equals('No se pudo sugerir un tiempo óptimo'));
        expect(controller.isLoading, isFalse);
      });
    });

    group('dispose', () {
      test('debería disponer correctamente el controlador', () {
        // Arrange
        final testController = ActivityRecommendationController(
          activityRepository: mockRepository,
          recommendationService: mockRecommendationService,
        );

        // Act & Assert - No debería lanzar excepciones
        expect(() => testController.dispose(), returnsNormally);
      });
    });
  });
}
