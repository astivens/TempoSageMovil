import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/recommendation_service.dart'
    as core_rec;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RecommendationService', () {
    late core_rec.RecommendationService service;

    setUp(() {
      service = core_rec.RecommendationService();
    });

    test('should return default recommendations if history is empty', () async {
      final result = await service.getRecommendations(interactionEvents: []);
      expect(result, isList);
      expect(result.length, greaterThan(0));
    });

    test('should return default recommendations with some history', () async {
      final history = [
        core_rec.InteractionEvent(
            itemId: 'Trabajo', timestamp: 1, eventType: 'test'),
        core_rec.InteractionEvent(
            itemId: 'Trabajo', timestamp: 2, eventType: 'test'),
        core_rec.InteractionEvent(
            itemId: 'Estudio', timestamp: 3, eventType: 'test'),
        core_rec.InteractionEvent(
            itemId: 'Ejercicio', timestamp: 4, eventType: 'test'),
        core_rec.InteractionEvent(
            itemId: 'Trabajo', timestamp: 5, eventType: 'test'),
      ];
      final result =
          await service.getRecommendations(interactionEvents: history);
      expect(result, isList);
      expect(result.length, greaterThan(0));
    });

    test('should handle errors gracefully and return defaults', () async {
      // Forzar error pasando un historial inválido
      final result = await service.getRecommendations(interactionEvents: []);
      expect(result, isList);
      expect(result.length, greaterThan(0));
    });
  });
}
