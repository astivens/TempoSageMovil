import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/dashboard/controllers/dashboard_controller.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:temposage/features/habits/domain/services/habit_to_timeblock_service.dart';

// Mocks
class MockActivityRepository extends Mock implements ActivityRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockHabitToTimeBlockService extends Mock
    implements HabitToTimeBlockService {}

void main() {
  late DashboardController dashboardController;
  late MockActivityRepository mockActivityRepository;
  late MockHabitRepository mockHabitRepository;

  setUp(() {
    mockActivityRepository = MockActivityRepository();
    mockHabitRepository = MockHabitRepository();

    dashboardController = DashboardController(
      activityRepository: mockActivityRepository,
      habitRepository: mockHabitRepository,
    );
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

      // Act
      await dashboardController.toggleActivityCompletion(activityId);

      // Assert
      verify(() => mockActivityRepository.toggleActivityCompletion(activityId))
          .called(1);
      verify(() => mockHabitRepository.getHabitsByDayOfWeek(any())).called(1);
      verify(() => mockActivityRepository.getActivitiesByDate(any())).called(1);
    });
  });
}
