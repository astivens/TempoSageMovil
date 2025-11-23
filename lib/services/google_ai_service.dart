import 'package:injectable/injectable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Excepción específica para errores del servicio de Google AI
class GoogleAIServiceException implements Exception {
  final String message;
  final int? statusCode;

  GoogleAIServiceException(this.message, {this.statusCode});

  @override
  String toString() =>
      'GoogleAIServiceException: $message${statusCode != null ? ' (Código: $statusCode)' : ''}';
}

/// Modelo para las respuestas del chat
class ChatResponse {
  final String text;
  final String role;
  final DateTime timestamp;

  ChatResponse({
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatResponse.fromUser(String text) {
    return ChatResponse(
      text: text,
      role: 'user',
    );
  }

  factory ChatResponse.fromAI(String text) {
    return ChatResponse(
      text: text,
      role: 'assistant',
    );
  }

  factory ChatResponse.error(String errorMessage) {
    return ChatResponse(
      text: errorMessage,
      role: 'error',
    );
  }
}

/// Servicio para interactuar con Google AI Studio API
@singleton
class GoogleAIService {
  final String apiKey;
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GoogleAIService({
    required this.apiKey,
  }) {
    _initializeModel();
  }

  /// Inicializa el modelo de Google AI
  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// Obtiene o crea la sesión de chat
  ChatSession get _session {
    _chatSession ??= _model.startChat();
    return _chatSession!;
  }

  /// Envía un mensaje al modelo de IA y recibe una respuesta
  Future<ChatResponse> sendMessage(String message) async {
    try {
      // Verificar si la API key es válida
      if (apiKey == 'mock_key_for_development') {
        return ChatResponse.fromAI(
          '⚠️ Google AI Studio no está configurado. '
          'Por favor, configura tu API key en AIConfig.',
        );
      }

      final response = await _session.sendMessage(
        Content.text(message),
      );

      final aiResponse = response.text ?? 'No se pudo generar una respuesta.';
      return ChatResponse.fromAI(aiResponse);
    } on Exception catch (e) {
      // Manejar errores específicos de la API
      if (e.toString().contains('API_KEY_INVALID')) {
        throw GoogleAIServiceException(
          'API Key inválida. Verifica tu configuración.',
        );
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        throw GoogleAIServiceException(
          'Cuota de API excedida. Intenta más tarde.',
        );
      } else if (e.toString().contains('SAFETY')) {
        throw GoogleAIServiceException(
          'El contenido fue bloqueado por filtros de seguridad.',
        );
      }
      
      throw GoogleAIServiceException('Error de API: $e');
    } catch (e) {
      if (e is GoogleAIServiceException) {
        rethrow;
      }
      throw GoogleAIServiceException('Error inesperado: $e');
    }
  }

  /// Limpia el historial de la conversación
  void clearConversation() {
    _chatSession = null; // Se recreará cuando se necesite
  }

  /// Configura datos de contexto para mejorar las respuestas basadas en ML
  Future<void> setMLContext(String contextData) async {
    // Reiniciar la sesión con el contexto
    _chatSession = _model.startChat(
      history: [
        Content.text(
          '''Eres TempoSage AI, un asistente especializado en productividad que utiliza modelos de Machine Learning para ayudar a los usuarios.

$contextData

INSTRUCCIONES IMPORTANTES:
1. Siempre usa los datos ML proporcionados para dar recomendaciones precisas
2. Cuando el usuario pregunte sobre actividades, usa las categorías y patrones disponibles
3. Para horarios, consulta los bloques de tiempo óptimos
4. Para productividad, usa las estadísticas y patrones del usuario
5. Sé específico y basado en datos, no genérico
6. Si no tienes datos específicos, dilo claramente
7. Siempre explica el razonamiento detrás de tus recomendaciones

Responde de manera útil y basada en los datos ML disponibles.''',
        ),
        Content.model([
          TextPart('Entendido. Soy TempoSage AI y utilizaré todos los datos de Machine Learning disponibles para proporcionar recomendaciones precisas y personalizadas. Estoy listo para ayudarte con productividad, horarios óptimos, recomendaciones de actividades y análisis basado en tus patrones de comportamiento.'),
        ]),
      ],
    );
  }

  /// Envía un mensaje con contexto ML dinámico
  Future<ChatResponse> sendMessageWithMLContext(
    String message, 
    String mlContextData
  ) async {
    try {
      if (apiKey == 'mock_key_for_development') {
        return ChatResponse.fromAI(
          '⚠️ Google AI Studio no está configurado. '
          'Por favor, configura tu API key en AIConfig.',
        );
      }

      // Crear un prompt enriquecido con contexto ML
      final enrichedMessage = '''
CONTEXTO ML ACTUAL:
$mlContextData

CONSULTA DEL USUARIO:
$message

Por favor, responde usando específicamente los datos ML proporcionados arriba. Si la consulta requiere análisis de patrones, recomendaciones de horarios, o sugerencias de actividades, usa los datos exactos del contexto ML.
''';

      final response = await _session.sendMessage(
        Content.text(enrichedMessage),
      );

      final aiResponse = response.text ?? 'No se pudo generar una respuesta.';
      return ChatResponse.fromAI(aiResponse);
    } on Exception catch (e) {
      if (e.toString().contains('API_KEY_INVALID')) {
        throw GoogleAIServiceException(
          'API Key inválida. Verifica tu configuración.',
        );
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        throw GoogleAIServiceException(
          'Cuota de API excedida. Intenta más tarde.',
        );
      } else if (e.toString().contains('SAFETY')) {
        throw GoogleAIServiceException(
          'El contenido fue bloqueado por filtros de seguridad.',
        );
      }
      
      throw GoogleAIServiceException('Error de API: $e');
    } catch (e) {
      if (e is GoogleAIServiceException) {
        rethrow;
      }
      throw GoogleAIServiceException('Error inesperado: $e');
    }
  }

  /// Obtiene el historial de la conversación
  List<Content> get conversationHistory => _session.history.toList();

  /// Libera recursos cuando el servicio ya no se necesita
  void dispose() {
    // No es necesario cerrar nada con la nueva implementación
  }
}
