import 'package:flutter/foundation.dart';
import '../../../services/google_ai_service.dart'
    show ChatResponse, GoogleAIService;
import '../services/ml_data_processor.dart';

/// Controlador para gestionar el estado y las operaciones del chat con IA
class ChatAIController with ChangeNotifier {
  final dynamic _aiService; // Puede ser GoogleAIService u OllamaAIService
  final MLDataProcessor _mlDataProcessor;

  /// Lista de mensajes en la conversación
  final List<ChatResponse> _messages = [];
  List<ChatResponse> get messages => List.unmodifiable(_messages);

  /// Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Estado de error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Indica si ya se ha cargado el contexto ML
  bool _mlContextLoaded = false;

  ChatAIController({
    required dynamic aiService,
    MLDataProcessor? mlDataProcessor,
  })  : _aiService = aiService,
        _mlDataProcessor = mlDataProcessor ?? MLDataProcessor();

  /// Envía un mensaje al servicio de IA y maneja la respuesta
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Cargar contexto ML si es el primer mensaje
    if (!_mlContextLoaded) {
      await _loadMLContext();
    }

    // Agregar mensaje del usuario a la lista
    final userMessage = ChatResponse.fromUser(message);
    _messages.add(userMessage);
    notifyListeners();

    // Actualizar estado de carga
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Obtener respuesta del servicio de IA
      final aiResponse = await _aiService.sendMessage(message);
      _messages.add(aiResponse);
    } catch (e) {
      _errorMessage = e.toString();
      _messages.add(ChatResponse.error(_errorMessage!));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga automáticamente el contexto ML al inicio (solo si el servicio lo soporta)
  Future<void> _loadMLContext() async {
    if (_aiService is GoogleAIService) {
      try {
        _isLoading = true;
        notifyListeners();
        final contextData = await _mlDataProcessor.getMLContextData();
        await _aiService.setMLContext(contextData);
        _mlContextLoaded = true;
      } catch (e) {
        _errorMessage =
            'Error al cargar el contexto ML: [31m${e.toString()}[0m';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // Si el servicio no soporta contexto, simplemente marca como cargado
      _mlContextLoaded = true;
    }
  }

  /// Fuerza la recarga del contexto ML
  Future<void> reloadMLContext() async {
    _mlContextLoaded = false;
    await _loadMLContext();
  }

  /// Limpia la conversación actual
  void clearConversation() {
    _messages.clear();
    _aiService.clearConversation();
    _mlContextLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
