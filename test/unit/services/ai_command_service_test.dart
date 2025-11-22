import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/ai_command_service.dart';

void main() {
  group('AICommandService', () {
    late AICommandService service;

    setUp(() {
      service = AICommandService(apiKey: 'test_api_key');
    });

    group('Constructor', () {
      test('debería inicializar con apiKey', () {
        // Arrange & Act
        final testService = AICommandService(apiKey: 'test_key');

        // Assert
        expect(testService, isNotNull);
      });
    });

    group('getHelpText', () {
      test('debería retornar texto de ayuda', () {
        // Act
        final helpText = service.getHelpText();

        // Assert
        expect(helpText, isA<String>());
        expect(helpText, isNotEmpty);
        expect(helpText, contains('comandos'));
      });

      test('debería incluir ejemplos de comandos', () {
        // Act
        final helpText = service.getHelpText();

        // Assert
        expect(helpText, contains('Crear'));
        expect(helpText, contains('actividad'));
      });
    });

    group('processCommand', () {
      test('debería retornar tipo unknown cuando hay error', () async {
        // Arrange
        final serviceWithInvalidKey = AICommandService(apiKey: 'invalid_key');

        // Act
        final result = await serviceWithInvalidKey.processCommand('test command');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['type'], equals('unknown'));
        expect(result['parameters'], isA<Map>());
        expect(result['parameters']['error'], isA<String>());
      });

      test('debería manejar errores de red', () async {
        // Arrange
        final serviceWithInvalidKey = AICommandService(apiKey: 'invalid_key');

        // Act
        final result = await serviceWithInvalidKey.processCommand('crear actividad');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['type'], equals('unknown'));
      });

      test('debería incluir error en parámetros cuando falla', () async {
        // Arrange
        final serviceWithInvalidKey = AICommandService(apiKey: 'invalid_key');

        // Act
        final result = await serviceWithInvalidKey.processCommand('test');

        // Assert
        expect(result['parameters'].containsKey('error'), isTrue);
      });
    });
  });
}

