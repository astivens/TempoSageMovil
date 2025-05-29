import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/domain/services/habit_recommendation_service.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/features/habits/domain/repositories/habit_repository.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:mocktail/mocktail.dart';

class MockRecommendationService extends Mock implements RecommendationService {}

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  group('HabitRecommendationService', () {
    late HabitRecommendationService service;
    late MockRecommendationService mockRecommendationService;
    late MockHabitRepository mockHabitRepository;

    setUp(() {
      mockRecommendationService = MockRecommendationService();
      mockHabitRepository = MockHabitRepository();
      service = HabitRecommendationService(
        recommendationService: mockRecommendationService,
        habitRepository: mockHabitRepository,
      );
    });

    test('should return default recommendations if none found', () async {
      when(() => mockHabitRepository.getAllHabits())
          .thenAnswer((_) async => []);
      when(() => mockRecommendationService.getRecommendations(
            interactionEvents: any(named: 'interactionEvents'),
            type: any(named: 'type'),
          )).thenAnswer((_) async => []);
      final result = await service.getHabitRecommendations();
      expect(result, isA<List<HabitModel>>());
      expect(result.length, greaterThan(0));
    });
  });
}
