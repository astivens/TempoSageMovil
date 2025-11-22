import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/google_ai_service.dart';

void main() {
  group('GoogleAIService', () {
    late GoogleAIService service;

    setUp(() {
      service = GoogleAIService(apiKey: 'test_api_key');
    });

    test('debería inicializar correctamente con API key válida', () {
      expect(service.apiKey, 'test_api_key');
    });

    test('debería manejar mensaje de desarrollo cuando API key es mock', () async {
      final mockService = GoogleAIService(apiKey: 'mock_key_for_development');
      
      final response = await mockService.sendMessage('Hola');
      
      expect(response.role, 'assistant');
      expect(response.text, contains('Google AI Studio no está configurado'));
    });

    test('debería limpiar la conversación correctamente', () {
      // No podemos testear directamente la limpieza del historial
      // pero podemos verificar que el método no lance excepciones
      expect(() => service.clearConversation(), returnsNormally);
    });

    test('debería configurar contexto ML correctamente', () async {
      const contextData = 'Datos de contexto de prueba';
      
      // No podemos testear directamente la configuración del contexto
      // pero podemos verificar que el método no lance excepciones
      expect(() => service.setMLContext(contextData), returnsNormally);
    });

    test('debería manejar errores de API correctamente', () {
      expect(
        () => GoogleAIServiceException('Error de prueba'),
        returnsNormally,
      );
    });

    test('debería crear ChatResponse correctamente', () {
      final userResponse = ChatResponse.fromUser('Mensaje de usuario');
      final aiResponse = ChatResponse.fromAI('Respuesta de IA');
      final errorResponse = ChatResponse.error('Error de prueba');

      expect(userResponse.role, 'user');
      expect(userResponse.text, 'Mensaje de usuario');
      
      expect(aiResponse.role, 'assistant');
      expect(aiResponse.text, 'Respuesta de IA');
      
      expect(errorResponse.role, 'error');
      expect(errorResponse.text, 'Error de prueba');
    });

    test('debería tener timestamp en las respuestas', () {
      final response = ChatResponse.fromUser('Test');
      expect(response.timestamp, isA<DateTime>());
    });

    test('debería manejar excepciones con información de estado', () {
      final exception = GoogleAIServiceException(
        'Error de prueba',
        statusCode: 400,
      );
      
      expect(exception.message, 'Error de prueba');
      expect(exception.statusCode, 400);
      expect(exception.toString(), contains('Error de prueba'));
      expect(exception.toString(), contains('400'));
    });

    test('debería manejar excepciones sin statusCode', () {
      final exception = GoogleAIServiceException('Error sin código');
      
      expect(exception.message, 'Error sin código');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), contains('Error sin código'));
      expect(exception.toString(), isNot(contains('Código')));
    });

    group('sendMessageWithMLContext', () {
      test('debería retornar mensaje de desarrollo cuando API key es mock', () async {
        final mockService = GoogleAIService(apiKey: 'mock_key_for_development');
        
        final response = await mockService.sendMessageWithMLContext(
          'Hola',
          'Contexto ML de prueba',
        );
        
        expect(response.role, 'assistant');
        expect(response.text, contains('Google AI Studio no está configurado'));
      });
    });

    group('conversationHistory', () {
      test('debería retornar lista de contenido', () {
        expect(service.conversationHistory, isA<List>());
      });
    });

    group('dispose', () {
      test('debería disponer recursos sin errores', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('ChatResponse factories', () {
      test('fromUser debería crear respuesta de usuario', () {
        final response = ChatResponse.fromUser('Mensaje usuario');
        
        expect(response.role, 'user');
        expect(response.text, 'Mensaje usuario');
        expect(response.timestamp, isA<DateTime>());
      });

      test('fromAI debería crear respuesta de asistente', () {
        final response = ChatResponse.fromAI('Mensaje IA');
        
        expect(response.role, 'assistant');
        expect(response.text, 'Mensaje IA');
        expect(response.timestamp, isA<DateTime>());
      });

      test('error debería crear respuesta de error', () {
        final response = ChatResponse.error('Error mensaje');
        
        expect(response.role, 'error');
        expect(response.text, 'Error mensaje');
        expect(response.timestamp, isA<DateTime>());
      });

      test('debería aceptar timestamp personalizado', () {
        final customTime = DateTime(2024, 1, 1);
        final response = ChatResponse(
          text: 'Test',
          role: 'user',
          timestamp: customTime,
        );
        
        expect(response.timestamp, equals(customTime));
      });
    });

    group('setMLContext', () {
      test('debería configurar contexto sin errores', () async {
        const contextData = 'Datos ML de prueba';
        
        await service.setMLContext(contextData);
        
        // Verificar que no lanza excepciones
        expect(service.conversationHistory, isA<List>());
      });
    });

    group('clearConversation', () {
      test('debería limpiar sesión sin errores', () {
        expect(() => service.clearConversation(), returnsNormally);
      });

      test('debería permitir múltiples llamadas', () {
        service.clearConversation();
        service.clearConversation();
        expect(() => service.clearConversation(), returnsNormally);
      });
    });
  });
}
