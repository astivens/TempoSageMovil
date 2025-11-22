import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/ollama_ai_service.dart';
import 'package:temposage/services/google_ai_service.dart';

void main() {
  group('OllamaAIService', () {
    late OllamaAIService service;

    setUp(() {
      service = OllamaAIService(
        baseUrl: 'http://localhost:8000',
        model: 'llama3',
      );
    });

    group('Constructor', () {
      test('debería inicializar con valores por defecto', () {
        // Arrange & Act
        final defaultService = OllamaAIService();

        // Assert
        expect(defaultService.baseUrl, equals('http://192.168.1.8:8000'));
        expect(defaultService.model, equals('llama3'));
      });

      test('debería inicializar con valores personalizados', () {
        // Arrange & Act
        final customService = OllamaAIService(
          baseUrl: 'http://custom:9000',
          model: 'custom-model',
        );

        // Assert
        expect(customService.baseUrl, equals('http://custom:9000'));
        expect(customService.model, equals('custom-model'));
      });
    });

    group('clearConversation', () {
      test('debería limpiar el historial de conversación', () {
        // Act
        service.clearConversation();

        // Assert - No debería lanzar excepciones
        expect(() => service.clearConversation(), returnsNormally);
      });

      test('debería permitir múltiples llamadas', () {
        // Act
        service.clearConversation();
        service.clearConversation();

        // Assert
        expect(() => service.clearConversation(), returnsNormally);
      });
    });

    group('sendMessage', () {
      test('debería manejar errores de conexión', () async {
        // Arrange
        final serviceWithInvalidUrl = OllamaAIService(
          baseUrl: 'http://invalid-url:9999',
          model: 'llama3',
        );

        // Act & Assert
        expectLater(
          serviceWithInvalidUrl.sendMessage('test'),
          throwsA(isA<Exception>()),
        );
      });

      test('debería manejar errores de servidor', () async {
        // Arrange
        final serviceWithInvalidUrl = OllamaAIService(
          baseUrl: 'http://localhost:9999',
          model: 'llama3',
        );

        // Act & Assert
        expectLater(
          serviceWithInvalidUrl.sendMessage('test'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

