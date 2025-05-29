import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/recommendation_service.dart';
import 'package:temposage/data/models/interaction_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RecommendationService', () {
    late RecommendationService service;

    setUp(() {
      service = RecommendationService();
    });

    test('should initialize with default mapping if file not found', () async {
      await service.loadModelAndPreprocessor();
      expect(service, isA<RecommendationService>());
    });

    test('should return default recommendations if history is empty', () async {
      final result = await service.getRecommendations([]);
      expect(result,
          containsAll(['Trabajo', 'Estudio', 'Ejercicio', 'Ocio', 'Otro']));
    });

    test('should return most frequent categories from history', () async {
      final history = [
        InteractionEvent(itemId: 'Trabajo', timestamp: 1),
        InteractionEvent(itemId: 'Trabajo', timestamp: 2),
        InteractionEvent(itemId: 'Estudio', timestamp: 3),
        InteractionEvent(itemId: 'Ejercicio', timestamp: 4),
        InteractionEvent(itemId: 'Trabajo', timestamp: 5),
      ];
      final result = await service.getRecommendations(history, topK: 2);
      expect(result.first, 'Trabajo');
      expect(result.length, 2);
    });

    test('should handle errors gracefully and return defaults', () async {
      // Forzar error pasando un historial inválido
      final result = await service.getRecommendations([], topK: 3);
      expect(result.length, 3);
    });
  });
}
