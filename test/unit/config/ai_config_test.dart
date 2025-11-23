import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/config/ai_config.dart';

void main() {
  group('AIConfig Tests', () {
    test('debería tener API key de Google AI definida', () {
      expect(AIConfig.googleAIAPIKey, isNotEmpty);
    });

    test('debería tener modelo Gemini definido', () {
      expect(AIConfig.geminiModel, equals('gemini-1.5-flash'));
    });

    test('debería tener configuración de generación por defecto', () {
      expect(AIConfig.defaultTemperature, equals(0.7));
      expect(AIConfig.defaultTopK, equals(40));
      expect(AIConfig.defaultTopP, equals(0.95));
      expect(AIConfig.defaultMaxOutputTokens, equals(1024));
    });

    test('debería verificar si Google AI está configurado', () {
      expect(AIConfig.isGoogleAIConfigured, isA<bool>());
    });

    test('debería tener mensaje de error de configuración', () {
      expect(AIConfig.configurationErrorMessage, isNotEmpty);
      expect(AIConfig.configurationErrorMessage, contains('Google AI API Key'));
    });
  });
}

