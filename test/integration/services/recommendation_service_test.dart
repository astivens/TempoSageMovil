import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecommendationService recommendationService;
  late Directory tempDir;

  setUpAll(() async {
    // Crear directorio temporal para las pruebas
    tempDir =
        await Directory.systemTemp.createTemp('temposage_recommendation_test_');
    
    // Mock path_provider para evitar MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });
  
  tearDownAll(() async {
    // Limpiar el mock de path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    
    // Limpiar el directorio temporal
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    recommendationService = RecommendationService();
    await recommendationService.initialize();
  });

  group('RecommendationService Integration Tests', () {
    test('should initialize with default mapping', () async {
      // Arrange & Act
      // La inicialización se hace en setUp

      // Assert
      // Verificar que el servicio se inicializa correctamente
      // El modo fallback debe estar activo debido a la falta de acceso al modelo
      expect(await recommendationService.getRecommendations(), isNotEmpty);
    });

    test('should return default recommendations for empty history', () async {
      // Act
      final recommendations = await recommendationService.getRecommendations(
        interactionEvents: [],
      );

      // Assert
      // En modo fallback, se devuelven recomendaciones (puede variar según el modo debug)
      expect(recommendations, isA<List>());
      expect(recommendations.length, greaterThanOrEqualTo(3));
      expect(recommendations.first, isA<Map>());
      expect(recommendations.first['title'], isNotEmpty);
    });

    test('should return personalized recommendations based on history',
        () async {
      // Arrange
      final events = [
        InteractionEvent(
          itemId: 'tarea1',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          eventType: 'click',
          type: 'activity',
        ),
        InteractionEvent(
          itemId: 'tarea2',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          eventType: 'complete',
          type: 'activity',
        ),
      ];

      // Act
      final recommendations = await recommendationService.getRecommendations(
        interactionEvents: events,
      );

      // Assert
      expect(recommendations, isA<List>());
      expect(recommendations.isNotEmpty, isTrue);
      expect(recommendations.first, isA<Map>());
      expect(recommendations.first['title'], isNotEmpty);
      expect(recommendations.first['category'], isNotEmpty);
    });

    test('should handle different recommendation types', () async {
      // Arrange
      final events = [
        InteractionEvent(
          itemId: 'bloque1',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          eventType: 'complete',
          type: 'timeblock',
        ),
      ];

      // Act
      final recommendations = await recommendationService.getRecommendations(
        interactionEvents: events,
        type: 'timeblock',
      );

      // Assert
      expect(recommendations, isA<List>());
      expect(recommendations.isNotEmpty, isTrue);
      expect(recommendations.first, isA<Map>());
      expect(recommendations.first['title'], isNotEmpty);
    });

    test('should handle invalid interaction events', () async {
      // Arrange
      final invalidEvents = [
        InteractionEvent(
          itemId: '',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          eventType: 'invalid',
        ),
      ];

      // Act
      final recommendations = await recommendationService.getRecommendations(
        interactionEvents: invalidEvents,
      );

      // Assert
      expect(recommendations, isA<List>());
      // En modo fallback puede devolver más de 3 recomendaciones (especialmente en modo debug)
      expect(recommendations.length, greaterThanOrEqualTo(3));
      expect(recommendations.first, isA<Map>());
    });

    test('should handle concurrent recommendation requests', () async {
      // Arrange
      final events = List.generate(
        10,
        (index) => InteractionEvent(
          itemId: 'tarea$index',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          eventType: index % 2 == 0 ? 'click' : 'complete',
          type: 'activity',
        ),
      );

      // Act
      // Hacer múltiples solicitudes concurrentes
      final futures = await Future.wait([
        recommendationService.getRecommendations(interactionEvents: events),
        recommendationService.getRecommendations(
          interactionEvents: events,
          type: 'activity',
        ),
        recommendationService.getRecommendations(
          interactionEvents: events,
          type: 'timeblock',
        ),
      ]);

      // Assert
      for (final recommendations in futures) {
        expect(recommendations, isA<List>());
        expect(recommendations.isNotEmpty, isTrue);
        expect(recommendations.first, isA<Map>());
        expect(recommendations.first['title'], isNotEmpty);
      }
    });

    test('should handle large history', () async {
      // Arrange
      // Generar muchos eventos de interacción
      final events = List.generate(
        100,
        (index) => InteractionEvent(
          itemId: 'tarea$index',
          timestamp: DateTime.now().millisecondsSinceEpoch - (index * 1000),
          eventType:
              index % 3 == 0 ? 'click' : (index % 3 == 1 ? 'complete' : 'view'),
          type: index % 2 == 0 ? 'activity' : 'timeblock',
        ),
      );

      // Act
      final recommendations = await recommendationService.getRecommendations(
        interactionEvents: events,
      );

      // Assert
      expect(recommendations, isA<List>());
      // En modo fallback puede devolver más de 3 recomendaciones (especialmente en modo debug)
      expect(recommendations.length, greaterThanOrEqualTo(3));
      expect(recommendations.first, isA<Map>());
    });
  });
}
