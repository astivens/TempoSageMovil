/// Configuración para servicios de IA
class AIConfig {
  /// API Key para Google AI Studio
  static const String googleAIAPIKey = 'AIzaSyAZLctX7BoYBmuYEPXAmZjBIun3Dcl4HwA'; 

  /// Modelo de Google AI a utilizar
  static const String geminiModel = 'gemini-1.5-flash';

  /// Configuración de generación por defecto
  static const double defaultTemperature = 0.7;
  static const int defaultTopK = 40;
  static const double defaultTopP = 0.95;
  static const int defaultMaxOutputTokens = 1024;

  /// Verifica si la API key está configurada correctamente
  static bool get isGoogleAIConfigured => 
      googleAIAPIKey.isNotEmpty && googleAIAPIKey != 'AIzaSyAZLctX7BoYBmuYEPXAmZjBIun3Dcl4HwA';

  /// Mensaje de error cuando la API key no está configurada
  static String get configurationErrorMessage => 
      'Google AI API Key no está configurada. '
      'Por favor, configura la variable de entorno GOOGLE_AI_API_KEY '
      'o reemplaza el valor por defecto en AIConfig.';
}
