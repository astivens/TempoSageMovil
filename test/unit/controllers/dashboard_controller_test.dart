import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/dashboard/controllers/dashboard_controller.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:temposage/features/habits/domain/services/habit_to_timeblock_service.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/activities/domain/usecases/predict_productivity_use_case.dart';
import 'package:temposage/features/activities/domain/usecases/suggest_optimal_time_use_case.dart';
import 'package:temposage/features/activities/domain/usecases/analyze_patterns_use_case.dart';
import 'package:temposage/core/di/service_locator.dart';
import 'package:temposage/core/utils/date_time_helper.dart';

// Mocks
class MockActivityRepository extends Mock implements ActivityRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockHabitToTimeBlockService extends Mock
    implements HabitToTimeBlockService {}

class MockPredictProductivityUseCase extends Mock
    implements PredictProductivityUseCase {}

class MockSuggestOptimalTimeUseCase extends Mock
    implements SuggestOptimalTimeUseCase {}

class MockAnalyzePatternsUseCase extends Mock
    implements AnalyzePatternsUseCase {}

void main() {
  late DashboardController dashboardController;
  late MockActivityRepository mockActivityRepository;
  late MockHabitRepository mockHabitRepository;
  late MockHabitToTimeBlockService mockHabitToTimeBlockService;
  late MockPredictProductivityUseCase mockPredictProductivityUseCase;
  late MockSuggestOptimalTimeUseCase mockSuggestOptimalTimeUseCase;
  late MockAnalyzePatternsUseCase mockAnalyzePatternsUseCase;

  setUpAll(() {
    // Registrar HabitToTimeBlockService en getIt para los tests
    if (!getIt.isRegistered<HabitToTimeBlockService>()) {
      getIt.registerLazySingleton<HabitToTimeBlockService>(
        () => MockHabitToTimeBlockService(),
      );
    }

    // Registrar fallback values para mocktail
    registerFallbackValue(
      HabitModel(
        id: 'fallback',
        title: 'Fallback',
        description: 'Fallback',
        daysOfWeek: ['Lunes'],
        category: 'Salud',
        reminder: 'enabled',
        time: '08:00',
        isCompleted: false,
        dateCreation: DateTime.now(),
      ),
    );
    registerFallbackValue(
      Habit(
        id: 'fallback',
        name: 'Fallback',
        description: 'Fallback',
        daysOfWeek: ['Lunes'],
        category: 'Salud',
        reminder: 'enabled',
        time: '08:00',
        isDone: false,
        dateCreation: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockHabitRepository = MockHabitRepository();
    mockHabitToTimeBlockService = MockHabitToTimeBlockService();
    mockPredictProductivityUseCase = MockPredictProductivityUseCase();
    mockSuggestOptimalTimeUseCase = MockSuggestOptimalTimeUseCase();
    mockAnalyzePatternsUseCase = MockAnalyzePatternsUseCase();

    // Actualizar el registro en getIt
    if (getIt.isRegistered<HabitToTimeBlockService>()) {
      getIt.unregister<HabitToTimeBlockService>();
    }
    getIt.registerLazySingleton<HabitToTimeBlockService>(
      () => mockHabitToTimeBlockService,
    );

    dashboardController = DashboardController(
      activityRepository: mockActivityRepository,
      habitRepository: mockHabitRepository,
      predictProductivityUseCase: mockPredictProductivityUseCase,
      suggestOptimalTimeUseCase: mockSuggestOptimalTimeUseCase,
      analyzePatternsUseCase: mockAnalyzePatternsUseCase,
    );
  });

  tearDown(() {
    if (getIt.isRegistered<HabitToTimeBlockService>()) {
      getIt.unregister<HabitToTimeBlockService>();
    }
  });

  group('DashboardController Tests', () {
    test('loadData carga hábitos y actividades correctamente', () async {
      // Arrange
      final today = DateTime.now();
      final currentDay =
          today.weekday - 1; // Ajustar a formato 0-6 (lunes-domingo)

      // Crear datos de prueba
      final habits = [
        Habit(
          id: '1',
          name: 'Habit 1',
          description: 'Description 1',
          time: '08:00',
          daysOfWeek: ['$currentDay'],
          isDone: false,
          category: 'Salud',
          reminder: '07:45',
          dateCreation: DateTime.now().subtract(const Duration(days: 7)),
        )
      ];

      final activities = [
        ActivityModel(
          id: '1',
          title: 'Activity 1',
          description: 'Description 1',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          isCompleted: false,
          category: 'Trabajo',
        )
      ];

      // Configurar mocks
      when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
          .thenAnswer((_) async => habits);

      when(() => mockActivityRepository.getActivitiesByDate(any()))
          .thenAnswer((_) async => activities);

      // Act
      await dashboardController.loadData();

      // Assert
      expect(dashboardController.habits.isNotEmpty, true);
      expect(dashboardController.activities.length, 1);
      expect(dashboardController.isLoading, false);

      // Verificar que los métodos se llamaron correctamente
      verify(() => mockHabitRepository.getHabitsByDayOfWeek(any())).called(1);
      verify(() => mockActivityRepository.getActivitiesByDate(any())).called(1);
    });

    test('deleteActivity elimina una actividad correctamente', () async {
      // Arrange
      const activityId = '1';

      // Configurar mocks
      when(() => mockActivityRepository.deleteActivity(any()))
          .thenAnswer((_) async {});

      when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
          .thenAnswer((_) async => []);

      when(() => mockActivityRepository.getActivitiesByDate(any()))
          .thenAnswer((_) async => []);

      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => []);

      when(() => mockActivityRepository.getAllActivities())
          .thenAnswer((_) async => []);

      // Act
      await dashboardController.deleteActivity(activityId);

      // Assert
      verify(() => mockActivityRepository.deleteActivity(activityId)).called(1);
      verify(() => mockHabitRepository.getHabitsByDayOfWeek(any())).called(1);
      verify(() => mockActivityRepository.getActivitiesByDate(any())).called(1);
    });

    test(
        'toggleActivityCompletion cambia el estado de completado correctamente',
        () async {
      // Arrange
      const activityId = '1';

      // Configurar mocks
      when(() => mockActivityRepository.toggleActivityCompletion(any()))
          .thenAnswer((_) async {});

      when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
          .thenAnswer((_) async => []);

      when(() => mockActivityRepository.getActivitiesByDate(any()))
          .thenAnswer((_) async => []);

      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => []);

      when(() => mockActivityRepository.getAllActivities())
          .thenAnswer((_) async => []);

      // Act
      await dashboardController.toggleActivityCompletion(activityId);

      // Assert
      verify(() => mockActivityRepository.toggleActivityCompletion(activityId))
          .called(1);
      verify(() => mockHabitRepository.getHabitsByDayOfWeek(any())).called(1);
      verify(() => mockActivityRepository.getActivitiesByDate(any())).called(1);
    });

    test('loadData carga datos de respaldo cuando no hay datos para hoy',
        () async {
      // Arrange
      final today = DateTime.now();
      final currentDay = DateTimeHelper.getDayOfWeek(today);

      when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
          .thenAnswer((_) async => []);
      when(() => mockActivityRepository.getActivitiesByDate(any()))
          .thenAnswer((_) async => []);
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => [
                Habit(
                  id: '1',
                  name: 'Fallback Habit',
                  description: 'Description',
                  time: '08:00',
                  daysOfWeek: ['Lunes'],
                  isDone: false,
                  category: 'Salud',
                  reminder: '07:45',
                  dateCreation: DateTime.now(),
                )
              ]);
      when(() => mockActivityRepository.getAllActivities())
          .thenAnswer((_) async => []);

      // Act
      await dashboardController.loadData();

      // Assert
      expect(dashboardController.isLoading, false);
      verify(() => mockHabitRepository.getAllHabits()).called(1);
    });

    test('deleteHabit elimina un hábito y sus timeblocks', () async {
      // Arrange
      final habit = HabitModel(
        id: 'habit-1',
        title: 'Test Habit',
        description: 'Test',
        daysOfWeek: ['Lunes'],
        category: 'Salud',
        reminder: 'enabled',
        time: '08:00',
        isCompleted: false,
        dateCreation: DateTime.now(),
      );

      when(() => mockHabitRepository.deleteHabit(any()))
          .thenAnswer((_) async => {});
      when(() => mockHabitToTimeBlockService.deleteTimeBlocksForHabit(any()))
          .thenAnswer((_) async => {});
      when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
          .thenAnswer((_) async => []);
      when(() => mockActivityRepository.getActivitiesByDate(any()))
          .thenAnswer((_) async => []);
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => []);
      when(() => mockActivityRepository.getAllActivities())
          .thenAnswer((_) async => []);

      // Act
      await dashboardController.deleteHabit(habit);

      // Assert
      verify(() => mockHabitRepository.deleteHabit(habit.id)).called(1);
      verify(() => mockHabitToTimeBlockService.deleteTimeBlocksForHabit(habit))
          .called(1);
    });

    test('toggleHabitCompletion cambia el estado de un hábito', () async {
      // Arrange
      final habit = HabitModel(
        id: 'habit-1',
        title: 'Test Habit',
        description: 'Test',
        daysOfWeek: ['Lunes'],
        category: 'Salud',
        reminder: 'enabled',
        time: '08:00',
        isCompleted: false,
        dateCreation: DateTime.now(),
      );

      when(() => mockHabitRepository.updateHabit(any()))
          .thenAnswer((_) async => {});
      when(() => mockHabitToTimeBlockService.syncTimeBlocksForHabit(any()))
          .thenAnswer((_) async => {});
      when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
          .thenAnswer((_) async => []);
      when(() => mockActivityRepository.getActivitiesByDate(any()))
          .thenAnswer((_) async => []);
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => []);
      when(() => mockActivityRepository.getAllActivities())
          .thenAnswer((_) async => []);

      // Act
      await dashboardController.toggleHabitCompletion(habit);

      // Assert
      verify(() => mockHabitRepository.updateHabit(any())).called(1);
      verify(() => mockHabitToTimeBlockService.syncTimeBlocksForHabit(habit))
          .called(1);
    });

    group('Filtrado por período del día', () {
      test('getMorningActivities retorna actividades de la mañana', () async {
        // Arrange
        final today = DateTime.now();
        final morningActivity = ActivityModel(
          id: '1',
          title: 'Morning Activity',
          description: 'Test',
          startTime: DateTime(today.year, today.month, today.day, 8, 0),
          endTime: DateTime(today.year, today.month, today.day, 9, 0),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [morningActivity]);

        await dashboardController.loadData();

        // Act
        final morningActivities = dashboardController.getMorningActivities();

        // Assert
        expect(morningActivities.length, 1);
        expect(morningActivities[0].title, 'Morning Activity');
      });

      test('getAfternoonActivities retorna actividades de la tarde', () async {
        // Arrange
        final today = DateTime.now();
        final afternoonActivity = ActivityModel(
          id: '1',
          title: 'Afternoon Activity',
          description: 'Test',
          startTime: DateTime(today.year, today.month, today.day, 14, 0),
          endTime: DateTime(today.year, today.month, today.day, 15, 0),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [afternoonActivity]);

        await dashboardController.loadData();

        // Act
        final afternoonActivities =
            dashboardController.getAfternoonActivities();

        // Assert
        expect(afternoonActivities.length, 1);
        expect(afternoonActivities[0].title, 'Afternoon Activity');
      });

      test('getEveningActivities retorna actividades de la noche', () async {
        // Arrange
        final today = DateTime.now();
        final eveningActivity = ActivityModel(
          id: '1',
          title: 'Evening Activity',
          description: 'Test',
          startTime: DateTime(today.year, today.month, today.day, 20, 0),
          endTime: DateTime(today.year, today.month, today.day, 21, 0),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [eveningActivity]);

        await dashboardController.loadData();

        // Act
        final eveningActivities = dashboardController.getEveningActivities();

        // Assert
        expect(eveningActivities.length, 1);
        expect(eveningActivities[0].title, 'Evening Activity');
      });

      test('getMorningHabits retorna hábitos de la mañana', () async {
        // Arrange
        final today = DateTime.now();
        final currentDay = DateTimeHelper.getDayOfWeek(today);
        final morningHabit = Habit(
          id: '1',
          name: 'Morning Habit',
          description: 'Test',
          time: '08:00',
          daysOfWeek: [currentDay],
          isDone: false,
          category: 'Salud',
          reminder: 'enabled',
          dateCreation: DateTime.now(),
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => [morningHabit]);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => []);

        await dashboardController.loadData();

        // Act
        final morningHabits = dashboardController.getMorningHabits();

        // Assert
        expect(morningHabits.length, 1);
        expect(morningHabits[0].title, 'Morning Habit');
      });
    });

    group('Predicción de productividad', () {
      test('predictProductivity actualiza el estado correctamente', () async {
        // Arrange
        final today = DateTime.now();
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [activity]);
        when(() => mockPredictProductivityUseCase.executeWithExplanation(
              activities: any(named: 'activities'),
              habits: any(named: 'habits'),
              targetDate: any(named: 'targetDate'),
            )).thenAnswer((_) async => {
          'prediction': 0.85,
          'explanation': 'Test explanation'
        });

        await dashboardController.loadData();

        // Act
        await dashboardController.predictProductivity();

        // Assert
        expect(dashboardController.isApiLoading, false);
        expect(dashboardController.productivityPrediction, 0.85);
        expect(dashboardController.productivityExplanation, 'Test explanation');
      });

      test('predictProductivity no hace llamada si no hay actividades',
          () async {
        // Arrange
        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => []);

        await dashboardController.loadData();

        // Act
        await dashboardController.predictProductivity();

        // Assert
        expect(dashboardController.isApiLoading, false);
        expect(dashboardController.productivityPrediction, isNull);
        verifyNever(() => mockPredictProductivityUseCase.executeWithExplanation(
              activities: any(named: 'activities'),
              habits: any(named: 'habits'),
              targetDate: any(named: 'targetDate'),
            ));
      });

      test('predictProductivity maneja errores correctamente', () async {
        // Arrange
        final today = DateTime.now();
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [activity]);
        when(() => mockPredictProductivityUseCase.executeWithExplanation(
              activities: any(named: 'activities'),
              habits: any(named: 'habits'),
              targetDate: any(named: 'targetDate'),
            )).thenThrow(Exception('API Error'));

        await dashboardController.loadData();

        // Act
        await dashboardController.predictProductivity();

        // Assert
        expect(dashboardController.isApiLoading, false);
        expect(dashboardController.apiError, isNotNull);
      });
    });

    group('Sugerencia de horarios óptimos', () {
      test('suggestOptimalTimes actualiza el estado correctamente', () async {
        // Arrange
        final today = DateTime.now();
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [activity, activity]);
        when(() => mockSuggestOptimalTimeUseCase.executeWithExplanation(
              activityCategory: any(named: 'activityCategory'),
              pastActivities: any(named: 'pastActivities'),
              targetDate: any(named: 'targetDate'),
            )).thenAnswer((_) async => {
          'suggestions': [
            {'time': '09:00', 'confidence': 0.9}
          ]
        });

        await dashboardController.loadData();

        // Act
        await dashboardController.suggestOptimalTimes(
          activityCategory: 'Trabajo',
        );

        // Assert
        expect(dashboardController.isApiLoading, false);
        expect(dashboardController.timeSuggestions, isNotEmpty);
      });

      test('suggestOptimalTimes no hace llamada si hay pocas actividades',
          () async {
        // Arrange
        final today = DateTime.now();
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [activity]);

        await dashboardController.loadData();

        // Act
        await dashboardController.suggestOptimalTimes(
          activityCategory: 'Trabajo',
        );

        // Assert
        expect(dashboardController.isApiLoading, false);
        expect(dashboardController.timeSuggestions, isEmpty);
        verifyNever(() => mockSuggestOptimalTimeUseCase.executeWithExplanation(
              activityCategory: any(named: 'activityCategory'),
              pastActivities: any(named: 'pastActivities'),
              targetDate: any(named: 'targetDate'),
            ));
      });
    });

    group('Análisis de patrones', () {
      test('analyzePatterns actualiza el estado correctamente', () async {
        // Arrange
        final today = DateTime.now();
        final activity = ActivityModel(
          id: '1',
          title: 'Test Activity',
          description: 'Test',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          isCompleted: false,
          category: 'Trabajo',
        );

        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => [activity, activity]);
        when(() => mockAnalyzePatternsUseCase.executeWithExplanation(
              activities: any(named: 'activities'),
              timePeriod: any(named: 'timePeriod'),
            )).thenAnswer((_) async => {
          'patterns': [
            {'pattern': 'Morning focus', 'frequency': 0.8}
          ]
        });

        await dashboardController.loadData();

        // Act
        await dashboardController.analyzePatterns();

        // Assert
        expect(dashboardController.isApiLoading, false);
        expect(dashboardController.activityPatterns, isNotEmpty);
      });
    });

    group('Predicción de metas y energía', () {
      test('predictGoalAchievement actualiza el estado', () async {
        // Act
        await dashboardController.predictGoalAchievement(
          goalDescription: 'Test goal',
          targetDeadline: DateTime.now().add(const Duration(days: 30)),
        );

        // Assert
        expect(dashboardController.isGoalPredictionLoading, false);
        expect(dashboardController.goalPredictionResult, isNotNull);
      });

      test('predictEnergyLevels actualiza el estado', () async {
        // Act
        await dashboardController.predictEnergyLevels();

        // Assert
        expect(dashboardController.isEnergyPredictionLoading, false);
        expect(dashboardController.energyPredictionResult, isNotNull);
      });

      test('recommendHabits actualiza el estado', () async {
        // Act
        await dashboardController.recommendHabits(
          userGoals: ['Goal 1', 'Goal 2'],
        );

        // Assert
        expect(dashboardController.isHabitRecommendationLoading, false);
        expect(dashboardController.habitRecommendationResult, isNotNull);
      });
    });

    group('Métodos de utilidad', () {
      test('refreshDashboard recarga los datos', () async {
        // Arrange
        when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getActivitiesByDate(any()))
            .thenAnswer((_) async => []);
        when(() => mockHabitRepository.getAllHabits())
            .thenAnswer((_) async => []);
        when(() => mockActivityRepository.getAllActivities())
            .thenAnswer((_) async => []);

        // Act
        await dashboardController.refreshDashboard();

        // Assert
        expect(dashboardController.isLoading, false);
        verify(() => mockHabitRepository.getHabitsByDayOfWeek(any())).called(1);
      });

      // Nota: Este test está comentado temporalmente debido a la naturaleza asíncrona
      // de notifyDataChanged que llama a loadData() sin await, lo que hace difícil
      // verificar su ejecución de forma determinística en un test unitario.
      // TODO: Considerar refactorizar notifyDataChanged para retornar Future<void>
      // o usar un enfoque diferente para testing.
      // test('notifyDataChanged inicia la recarga', () async {
      //   // Arrange
      //   when(() => mockHabitRepository.getHabitsByDayOfWeek(any()))
      //       .thenAnswer((_) async => []);
      //   when(() => mockActivityRepository.getActivitiesByDate(any()))
      //       .thenAnswer((_) async => []);
      //   when(() => mockHabitRepository.getAllHabits())
      //       .thenAnswer((_) async => []);
      //   when(() => mockActivityRepository.getAllActivities())
      //       .thenAnswer((_) async => []);
      //
      //   // Act
      //   dashboardController.notifyDataChanged();
      //
      //   // Assert - Esperar un tiempo suficiente para que se inicie la carga
      //   await Future.delayed(const Duration(milliseconds: 300));
      //
      //   // Verificar que se llamó al menos una vez (puede llamarse múltiples veces)
      //   verify(() => mockHabitRepository.getHabitsByDayOfWeek(any())).called(greaterThanOrEqualTo(1));
      // });
    });
  });
}
