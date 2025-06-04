import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

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
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final String _model = 'gemini-pro';
  final http.Client _client;
  final String apiKey;

  // Historial de conversación para mantener contexto
  final List<Map<String, dynamic>> _conversationHistory = [];

  GoogleAIService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Envía un mensaje al modelo de IA y recibe una respuesta
  Future<ChatResponse> sendMessage(String message) async {
    try {
      // Agregar mensaje del usuario al historial
      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ]
      });

      // Construir URL de la API
      final url =
          Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey');

      // Construir cuerpo de la solicitud
      final requestBody = {
        'contents': _conversationHistory,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        }
      };

      // Realizar la solicitud HTTP
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Verificar respuesta
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extraer texto de la respuesta
        final aiResponse =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        // Agregar respuesta al historial
        _conversationHistory.add({
          'role': 'model',
          'parts': [
            {'text': aiResponse}
          ]
        });

        return ChatResponse.fromAI(aiResponse);
      } else {
        throw GoogleAIServiceException(
          'Error al comunicarse con Google AI Studio',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is GoogleAIServiceException) {
        rethrow;
      }
      throw GoogleAIServiceException('Error inesperado: $e');
    }
  }

  /// Limpia el historial de la conversación
  void clearConversation() {
    _conversationHistory.clear();
  }

  /// Configura datos de contexto para mejorar las respuestas basadas en ML
  Future<void> setMLContext(String contextData) async {
    // Agregar contexto al inicio de la conversación
    if (_conversationHistory.isEmpty) {
      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {
            'text':
                'Por favor, utiliza estos datos como contexto para responder a mis preguntas futuras: $contextData'
          }
        ]
      });

      // Agregar respuesta ficticia de confirmación
      _conversationHistory.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Entendido, utilizaré esta información como contexto para nuestras conversaciones.'
          }
        ]
      });
    }
  }

  /// Libera recursos cuando el servicio ya no se necesita
  void dispose() {
    _client.close();
  }
}
