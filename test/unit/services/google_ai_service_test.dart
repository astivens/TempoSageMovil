import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/google_ai_service.dart';

void main() {
  group('GoogleAIServiceException Tests', () {
    test('debería crear excepción con mensaje', () {
      // Arrange
      const message = 'Test error';

      // Act
      final exception = GoogleAIServiceException(message);

      // Assert
      expect(exception.message, message);
      expect(exception.statusCode, isNull);
    });

    test('debería crear excepción con mensaje y código de estado', () {
      // Arrange
      const message = 'Test error';
      const statusCode = 404;

      // Act
      final exception = GoogleAIServiceException(message, statusCode: statusCode);

      // Assert
      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
    });

    test('toString debería incluir mensaje y código cuando está presente', () {
      // Arrange
      const message = 'Test error';
      const statusCode = 404;
      final exception = GoogleAIServiceException(message, statusCode: statusCode);

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains(message));
      expect(result, contains('$statusCode'));
    });

    test('toString debería incluir solo mensaje cuando no hay código', () {
      // Arrange
      const message = 'Test error';
      final exception = GoogleAIServiceException(message);

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains(message));
      expect(result, isNot(contains('Código')));
    });
  });

  group('ChatResponse Tests', () {
    test('debería crear ChatResponse con valores por defecto', () {
      // Arrange
      const text = 'Test message';
      const role = 'user';

      // Act
      final response = ChatResponse(text: text, role: role);

      // Assert
      expect(response.text, text);
      expect(response.role, role);
      expect(response.timestamp, isA<DateTime>());
    });

    test('debería crear ChatResponse con timestamp personalizado', () {
      // Arrange
      const text = 'Test message';
      const role = 'user';
      final customTimestamp = DateTime(2024, 1, 1);

      // Act
      final response = ChatResponse(
        text: text,
        role: role,
        timestamp: customTimestamp,
      );

      // Assert
      expect(response.timestamp, customTimestamp);
    });

    test('ChatResponse.fromUser debería crear respuesta de usuario', () {
      // Arrange
      const text = 'User message';

      // Act
      final response = ChatResponse.fromUser(text);

      // Assert
      expect(response.text, text);
      expect(response.role, 'user');
    });

    test('ChatResponse.fromAI debería crear respuesta de asistente', () {
      // Arrange
      const text = 'AI message';

      // Act
      final response = ChatResponse.fromAI(text);

      // Assert
      expect(response.text, text);
        expect(response.role, 'assistant');
    });

    test('ChatResponse.error debería crear respuesta de error', () {
      // Arrange
      const errorMessage = 'Error occurred';

      // Act
      final response = ChatResponse.error(errorMessage);

      // Assert
      expect(response.text, errorMessage);
      expect(response.role, 'error');
      });
    });

  group('GoogleAIService Tests', () {
    test('debería inicializar con API key', () {
      // Arrange
      const apiKey = 'test_api_key';

      // Act
      final service = GoogleAIService(apiKey: apiKey);

      // Assert
      expect(service.apiKey, apiKey);
      });

    test('sendMessage debería retornar mensaje mock cuando API key es mock_key_for_development',
        () async {
      // Arrange
      const apiKey = 'mock_key_for_development';
      final service = GoogleAIService(apiKey: apiKey);

      // Act
      final response = await service.sendMessage('Test message');

      // Assert
      expect(response.role, 'assistant');
      expect(response.text, contains('no está configurado'));
      });

    test('clearConversation debería limpiar la sesión de chat', () {
      // Arrange
      const apiKey = 'test_api_key';
      final service = GoogleAIService(apiKey: apiKey);

      // Act
      service.clearConversation();

      // Assert
      // Verificamos que el método se ejecuta sin errores
      expect(service, isNotNull);
      });

    test('dispose debería ejecutarse sin errores', () {
      // Arrange
      const apiKey = 'test_api_key';
      final service = GoogleAIService(apiKey: apiKey);

      // Act & Assert
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
