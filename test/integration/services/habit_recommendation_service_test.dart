import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/domain/services/habit_recommendation_service.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class FakeHabit extends Fake implements Habit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HabitRecommendationService habitRecommendationService;
  late RecommendationService recommendationService;
  late MockHabitRepository mockHabitRepository;

  setUpAll(() {
    // Registrar valores de fallback para Mocktail
    registerFallbackValue(FakeHabit());
  });

  setUp(() async {
    mockHabitRepository = MockHabitRepository();
    recommendationService = RecommendationService();
    habitRecommendationService = HabitRecommendationService(
      recommendationService: recommendationService,
      habitRepository: mockHabitRepository,
    );
    await recommendationService.initialize();
  });

  group('HabitRecommendationService Integration Tests', () {
    test('should return default recommendations if none found', () async {
      // Arrange
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => []);

      // Act
      final result = await habitRecommendationService.getHabitRecommendations();

      // Assert
      expect(result, isA<List<HabitModel>>());
      expect(result.length, greaterThan(0));
      expect(result.first.title, isNotEmpty);
    });

    test('should return personalized recommendations based on user habits',
        () async {
      // Arrange
      final now = DateTime.now();
      final habits = [
        Habit(
          id: '1',
          name: 'Leer',
          description: 'Leer un libro',
          daysOfWeek: ['Lunes', 'Miércoles'],
          category: 'Lectura',
          reminder: 'Diaria',
          time: '20:00',
          isDone: true,
          dateCreation: now,
        ),
        Habit(
          id: '2',
          name: 'Correr',
          description: 'Correr 5km',
          daysOfWeek: ['Martes', 'Jueves'],
          category: 'Salud',
          reminder: 'Diaria',
          time: '07:00',
          isDone: false,
          dateCreation: now,
        ),
      ];
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => habits);

      // Act
      final result = await habitRecommendationService.getHabitRecommendations();

      // Assert
      expect(result, isA<List<HabitModel>>());
      expect(result.length, greaterThan(0));
      expect(result.first.title, isNotEmpty);
    });

    test('should suggest optimal time for a habit', () async {
      // Arrange
      final now = DateTime.now();
      final habitModel = HabitModel.create(
        title: 'Ejercicio',
        description: 'Hacer ejercicio',
        daysOfWeek: ['Lunes', 'Miércoles'],
        category: 'Salud',
        reminder: 'Diaria',
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
        isDone: true,
        dateCreation: now,
      );
      final similarHabit = habitEntity.copyWith(time: '07:00');
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => [similarHabit]);
      when(() => mockHabitRepository.updateHabit(any()))
          .thenAnswer((_) async {});

      // Act
      await habitRecommendationService.suggestOptimalTime(habitModel);

      // Assert
      verify(() => mockHabitRepository.updateHabit(any())).called(1);
    });
  });
}
