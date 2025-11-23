import 'package:flutter/foundation.dart';
import '../../../services/google_ai_service.dart'
    show ChatResponse, GoogleAIService;
import '../services/ml_data_processor.dart';
import '../../../core/services/ml_ai_integration_service.dart';
import '../../../core/di/service_locator.dart' as sl;

/// Controlador para gestionar el estado y las operaciones del chat con IA
class ChatAIController with ChangeNotifier {
  final dynamic _aiService; // Puede ser GoogleAIService u OllamaAIService
  final MLDataProcessor _mlDataProcessor;
  final MLAIIntegrationService _mlAIIntegrationService;

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

  /// Indica si está usando la integración ML-IA avanzada
  bool _useMLIntegration = true;

  ChatAIController({
    required dynamic aiService,
    MLDataProcessor? mlDataProcessor,
    MLAIIntegrationService? mlAIIntegrationService,
  })  : _aiService = aiService,
        _mlDataProcessor = mlDataProcessor ?? MLDataProcessor(),
        _mlAIIntegrationService = mlAIIntegrationService ?? sl.getIt<MLAIIntegrationService>();

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
      ChatResponse aiResponse;
      
      // Usar integración ML-IA avanzada si está disponible
      if (_useMLIntegration && _aiService is GoogleAIService) {
        try {
          // Usar el servicio de integración ML-IA
          final mlResponse = await _mlAIIntegrationService.processQueryWithML(message);
          aiResponse = ChatResponse.fromAI(mlResponse);
        } catch (e) {
          // Fallback al método mejorado si hay error
          debugPrint('Error en integración ML-IA, usando fallback: $e');
          final contextualMLData = await _mlDataProcessor.getContextualMLData(message);
          
          if (contextualMLData.isNotEmpty) {
            aiResponse = await _aiService.sendMessageWithMLContext(message, contextualMLData);
          } else {
            aiResponse = await _aiService.sendMessage(message);
          }
        }
      } else {
        // Método tradicional con contexto ML básico
        final contextualMLData = await _mlDataProcessor.getContextualMLData(message);
        
        if (_aiService is GoogleAIService && contextualMLData.isNotEmpty) {
          aiResponse = await _aiService.sendMessageWithMLContext(message, contextualMLData);
        } else {
          // Fallback al método normal
          aiResponse = await _aiService.sendMessage(message);
        }
      }
      
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

  /// Habilita o deshabilita la integración ML-IA avanzada
  void toggleMLIntegration(bool enabled) {
    _useMLIntegration = enabled;
    notifyListeners();
  }

  /// Obtiene el estado de la integración ML-IA
  bool get isMLIntegrationEnabled => _useMLIntegration;

  /// Fuerza la recarga del contexto ML y reinicia la integración
  Future<void> refreshMLIntegration() async {
    _mlContextLoaded = false;
    await _loadMLContext();
    notifyListeners();
  }

  /// Obtiene información sobre el estado de la integración ML-IA
  Map<String, dynamic> getMLIntegrationStatus() {
    return {
      'mlIntegrationEnabled': _useMLIntegration,
      'mlContextLoaded': _mlContextLoaded,
      'aiServiceType': _aiService.runtimeType.toString(),
      'hasMLDataProcessor': _mlDataProcessor != null,
      'hasMLAIIntegrationService': _mlAIIntegrationService != null,
    };
  }
}
