import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/google_ai_service.dart'; // Para ChatResponse

class OllamaAIService {
  final String baseUrl; // Ejemplo: http://192.168.1.8:8000
  final String model;
  final http.Client _client;
  final List<Map<String, String>> _conversationHistory = [];

  OllamaAIService({
    this.baseUrl = 'http://192.168.1.8:8000',
    this.model = 'llama3',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<ChatResponse> sendMessage(String message) async {
    _conversationHistory.add({'role': 'user', 'content': message});

    final url = Uri.parse('$baseUrl/api/chat');
    final requestBody = {
      'model': model,
      'messages': _conversationHistory,
      'stream': false,
    };

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiResponse = data['message']['content'] ?? '';
      _conversationHistory.add({'role': 'assistant', 'content': aiResponse});
      return ChatResponse.fromAI(aiResponse);
    } else {
      throw Exception('Error: [31m${response.statusCode}[0m');
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
  }
}
