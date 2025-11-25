import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../models/productive_block.dart';
import './csv_service.dart';
import './schedule_rule_service.dart';
import './ml_model_adapter.dart';
import './debug_data_service.dart';

class InteractionEvent {
  final String itemId;
  final int timestamp;
  final String eventType;
  final String? type;

  InteractionEvent({
    required this.itemId,
    required this.timestamp,
    required this.eventType,
    this.type,
  });
}

class TaskPrediction {
  final String category;
  final double estimatedDuration;
  final DateTime? suggestedDateTime;
  final List<ProductiveBlock> suggestedBlocks;

  TaskPrediction({
    required this.category,
    required this.estimatedDuration,
    this.suggestedDateTime,
    this.suggestedBlocks = const [],
  });

  @override
  String toString() {
    final suggestedTime = suggestedDateTime != null
        ? '\nBloque sugerido: ${_formatDateTime(suggestedDateTime!)}'
        : '\nNo hay bloque sugerido disponible.';

    String blockInfo = '';
    if (suggestedBlocks.isNotEmpty) {
      blockInfo = '\n\nBloques óptimos:';
      for (int i = 0; i < suggestedBlocks.length && i < 3; i++) {
        blockInfo += '\n- ${suggestedBlocks[i].toString()}';
      }
    }

    return 'Categoría: $category\nDuración estimada: ${estimatedDuration.toStringAsFixed(0)} min$suggestedTime$blockInfo';
  }

  String _formatDateTime(DateTime dateTime) {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final day = days[dateTime.weekday - 1];
    final hour =
        dateTime.hour < 10 ? '0${dateTime.hour}:00' : '${dateTime.hour}:00';

    return '$day a las $hour';
  }
}

class RecommendationService {
  final Logger _logger = Logger('RecommendationService');
  static const String _modelFileName = 'multitask_model_fp16.tflite';
  static const String _labelsFileName = 'labels.txt';
  static const String _tpsModelBasePath = 'ml_models/TPS_Model';

  // Servicios adicionales
  final CSVService _csvService = CSVService();
  final ScheduleRuleService _scheduleRuleService = ScheduleRuleService();

  // Adaptador ML que reemplaza el uso directo del intérprete
  MlModelAdapter? _modelAdapter;
  List<String>? _labels;
  bool _isInitialized = false;
  bool _isUsingFallback = false;

  // Datos cacheados
  Map<String, List<ProductiveBlock>>? _blocksByCategory;

  // Contadores para análisis de uso
  int _predictionCount = 0;
  Map<String, int> _categoryPredictions = {};
  bool _hasShownAiImprovedMessage = false;

  // Configuración
  static const int _maxHistoryLength = 50;

  // Mensaje de mejora para mostrar al usuario
  String? _aiImprovementMessage;
  String? get aiImprovementMessage => _aiImprovementMessage;

  Future<void> initialize() async {
    try {
      _logger.i("Inicializando servicio de recomendaciones");

      // Inicializar el adaptador ML en lugar del modelo directamente
      _modelAdapter = MlModelAdapter();
      bool modelInitialized = await _modelAdapter!
          .initialize(_modelFileName, modelBasePath: _tpsModelBasePath);

      if (!modelInitialized) {
        // En tests o cuando TensorFlow Lite no está disponible, esto es esperado
        // No lanzar excepción, simplemente activar modo fallback
        throw Exception("No se pudo inicializar el adaptador del modelo ML");
      }

      _logger.i(
          "Adaptador ML inicializado con información: ${_modelAdapter!.modelInfo}");
      await _loadLabels();

      // Cargar datos auxiliares
      try {
        _blocksByCategory = await _csvService.loadBlocksByCategory();
        _logger.i(
            'Bloques productivos por categoría cargados: ${_blocksByCategory?.length ?? 0} categorías');
      } catch (e) {
        _logger.w('Error al precargar bloques productivos por categoría: $e');
        _blocksByCategory = {};
      }

      _isInitialized = true;
      _logger.i("Servicio de recomendaciones inicializado correctamente");
    } catch (e, stackTrace) {
      // En tests o cuando TensorFlow Lite no está disponible, esto es esperado
      final isExpectedFailure = e.toString().contains('No se pudo inicializar el adaptador') ||
          e.toString().contains('cannot open shared object file') ||
          e.toString().contains('MissingPluginException');
      
      if (isExpectedFailure) {
        _logger.w("TensorFlow Lite no disponible, usando modo fallback para recomendaciones");
      } else {
        _logger.e("Error al inicializar el servicio de recomendaciones",
            error: e, stackTrace: stackTrace);
      }

      // Marcar como inicializado pero usando fallback
      _isInitialized = true;
      _isUsingFallback = true;
    }
  }

  Future<List<String>> _loadLabels() async {
    try {
      final labelsString = await rootBundle
          .loadString('assets/$_tpsModelBasePath/$_labelsFileName');
      _labels = labelsString
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      _logger.d("Categorías cargadas: ${_labels!.join(', ')}");
      return _labels!;
    } catch (e) {
      _logger.w("Error al cargar etiquetas de categorías: $e");
      // Definir categorías por defecto si no se pueden cargar
      _labels = [
        'Estudio',
        'Finanzas',
        'Formación',
        'Hogar',
        'Ocio',
        'Personal',
        'Salud',
        'Social',
        'Trabajo'
      ];
      return _labels!;
    }
  }

  Future<TaskPrediction> predictTaskDetails({
    required String description,
    required double estimatedDuration,
    int priority = 3,
    double energyLevel = 0.5,
    double moodLevel = 0.5,
  }) async {
    if (!_isInitialized) {
      _logger.w('El servicio de recomendaciones no está inicializado.');
      return TaskPrediction(
        category: 'Desconocida',
        estimatedDuration: estimatedDuration,
        suggestedDateTime: null,
      );
    }

    try {
      // 1. Obtener hora y día actual
      final now = DateTime.now();
      final startHour = now.hour.toDouble();
      final startWeekday = (now.weekday - 1).toDouble(); // 0-6 (lunes-domingo)

      Map<String, dynamic> predictions;
      String predictedCategory;
      double predictedDuration;

      // 2. Ejecutar el modelo adaptado o usar fallback si es necesario
      if (_isUsingFallback || _modelAdapter == null) {
        _logger.w("Usando modo fallback para predicción de tareas");
        final outputs = await _runFallbackLogic(
          description: description,
          estimatedDuration: estimatedDuration,
          complexity: priority.toDouble() / 5.0, // Normalizado a [0,1]
          energy: energyLevel,
          currentTime: TimeOfDay.fromDateTime(now),
        );

        // Procesar resultados del fallback
        final categoryIndex = _getCategoryIndex(outputs[0]);
        predictedCategory = categoryIndex < (_labels?.length ?? 0)
            ? _labels![categoryIndex]
            : 'Desconocida';

        predictedDuration = outputs[1][0];
      } else {
        // Usar el adaptador ML para manejar la inferencia
        try {
          _logger
              .d("Ejecutando inferencia con adaptador ML para: '$description'");
          predictions = await _modelAdapter!.runInference(
              text: description,
              estimatedDuration: estimatedDuration,
              timeOfDay: startHour,
              dayOfWeek: startWeekday);

          // Obtener categoría y duración de las predicciones
          final categoryIndex = predictions['categoryIndex'] as int?;
          if (categoryIndex != null && categoryIndex < (_labels?.length ?? 0)) {
            predictedCategory = _labels![categoryIndex];
          } else {
            predictedCategory = _determineDefaultCategory(description);
          }

          // Obtener duración estimada
          predictedDuration =
              predictions['duration'] as double? ?? estimatedDuration;

          _logger.d(
              "Predicción exitosa - Categoría: $predictedCategory, Duración: $predictedDuration min");
        } catch (e, stackTrace) {
          _logger.e("Error en inferencia con adaptador ML",
              error: e, stackTrace: stackTrace);

          // Usar categoría determinada por heurísticas
          predictedCategory = _determineDefaultCategory(description);
          predictedDuration = estimatedDuration;
        }
      }

      // Actualizar contadores de uso y categorías
      _predictionCount++;
      _categoryPredictions[predictedCategory] =
          (_categoryPredictions[predictedCategory] ?? 0) + 1;

      // Verificar si debemos mostrar un mensaje de mejora del AI
      _checkAndUpdateAiImprovement();

      // 3. Obtener bloques productivos específicos por categoría
      List<ProductiveBlock> categoryBlocks = [];

      if (_blocksByCategory != null &&
          _blocksByCategory!.containsKey(predictedCategory)) {
        // Usar bloques específicos para la categoría
        categoryBlocks = _blocksByCategory![predictedCategory]!;
        _logger.d(
            'Encontrados ${categoryBlocks.length} bloques específicos para $predictedCategory');
      } else {
        // Si no hay bloques específicos, usar los generales
        final productiveBlocks = await _csvService.loadTop3Blocks();
        categoryBlocks = productiveBlocks;
        _logger.d(
            'Usando ${categoryBlocks.length} bloques generales (no hay específicos para $predictedCategory)');
      }

      // 4. Sugerir bloque según reglas híbridas
      final userContext = UserContext(
        priority: priority,
        energyLevel: energyLevel,
        moodLevel: moodLevel,
        predictedCategory: predictedCategory,
      );

      final suggestedBlock = await _scheduleRuleService.suggestBlock(
        productiveBlocks: categoryBlocks,
        referenceDate: now,
        userContext: userContext,
      );

      return TaskPrediction(
        category: predictedCategory,
        estimatedDuration: predictedDuration,
        suggestedDateTime: suggestedBlock?.dateTime,
        suggestedBlocks:
            categoryBlocks.take(3).toList(), // Tomar los 3 mejores bloques
      );
    } catch (e, stackTrace) {
      _logger.e('Error al predecir detalles de la tarea',
          error: e, stackTrace: stackTrace);
      return TaskPrediction(
        category: _determineDefaultCategory(description),
        estimatedDuration: estimatedDuration,
        suggestedDateTime: null,
      );
    }
  }

  /// Verifica si se cumplen las condiciones para mostrar un mensaje de mejora del AI
  void _checkAndUpdateAiImprovement() {
    // Si ya mostramos el mensaje o no hay suficientes predicciones, salir
    if (_hasShownAiImprovedMessage || _predictionCount < 5) return;

    // Encontrar la categoría más frecuente
    String? topCategory;
    int maxCount = 0;

    _categoryPredictions.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        topCategory = category;
      }
    });

    // Si hay al menos tres predicciones de la misma categoría
    if (maxCount >= 3 && topCategory != null) {
      _hasShownAiImprovedMessage = true;

      // Generar un mensaje personalizado basado en la categoría más frecuente
      _aiImprovementMessage =
          '¡Tu asistente IA está mejorando! He aprendido que '
          'te interesan actividades de "$topCategory". Las próximas recomendaciones '
          'serán más precisas basadas en tus patrones.';

      _logger.i('Mensaje de mejora de IA generado: $_aiImprovementMessage');
    }
  }

  /// Obtiene el mensaje de mejora y lo marca como leído
  String? getAndClearAiImprovementMessage() {
    final message = _aiImprovementMessage;
    _aiImprovementMessage = null;
    return message;
  }

  // Lógica de fallback si no se puede usar el modelo TFLite
  Future<List<List<double>>> _runFallbackLogic({
    required String description,
    required double estimatedDuration,
    required double complexity,
    required double energy,
    required TimeOfDay currentTime,
  }) async {
    _logger.i("Ejecutando lógica de fallback para predicción");

    // Simplificación: Clasificación basada en palabras clave
    final numCategories = _labels?.length ?? 9; // Por defecto 9 categorías
    final categoryLogits = List<double>.filled(numCategories, 0.0);

    // Palabras clave para cada categoría
    final keywordMap = {
      'estudio': 0, // Estudio
      'estudiar': 0,
      'universidad': 0,
      'escuela': 0,
      'examen': 0,
      'tarea': 0,
      'deberes': 0,
      'finanzas': 1, // Finanzas
      'pagar': 1,
      'banco': 1,
      'dinero': 1,
      'pago': 1,
      'factura': 1,
      'inversión': 1,
      'formación': 2, // Formación
      'curso': 2,
      'aprender': 2,
      'clase': 2,
      'capacitación': 2,
      'tutorial': 2,
      'webinar': 2,
      'hogar': 3, // Hogar
      'casa': 3,
      'limpiar': 3,
      'cocinar': 3,
      'limpieza': 3,
      'compras': 3,
      'reparación': 3,
      'ocio': 4, // Ocio
      'descansar': 4,
      'jugar': 4,
      'divertirse': 4,
      'película': 4,
      'serie': 4,
      'música': 4,
      'personal': 5, // Personal
      'cita': 5,
      'trámite': 5,
      'documentos': 5,
      'gestión': 5,
      'organizar': 5,
      'planificar': 5,
      'salud': 6, // Salud
      'médico': 6,
      'ejercicio': 6,
      'entrenar': 6,
      'nutrición': 6,
      'bienestar': 6,
      'yoga': 6,
      'social': 7, // Social
      'amigos': 7,
      'familia': 7,
      'reunión': 7,
      'evento': 7,
      'fiesta': 7,
      'visita': 7,
      'trabajo': 8, // Trabajo
      'proyecto': 8,
      'informe': 8,
      'email': 8,
      'reunión_trabajo': 8,
      'presentación': 8,
      'cliente': 8,
    };

    // Buscar palabras clave en la descripción
    final words = description.toLowerCase().split(' ');
    int bestCategoryIndex = -1;
    double maxScore = 0.0;

    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w\s]+'), '');
      if (keywordMap.containsKey(cleanWord)) {
        final categoryIndex = keywordMap[cleanWord]!;
        categoryLogits[categoryIndex] += 1.0;

        if (categoryLogits[categoryIndex] > maxScore) {
          maxScore = categoryLogits[categoryIndex];
          bestCategoryIndex = categoryIndex;
        }
      }
    }

    // Si no se encontró ninguna palabra clave, intentar análisis semántico simple
    if (bestCategoryIndex == -1) {
      bestCategoryIndex = 8; // Default a Trabajo
      categoryLogits[bestCategoryIndex] = 1.0;
    }

    // Ajustar duración
    double adjustedDuration = estimatedDuration * (0.9 + complexity * 0.4);

    _logger.d(
        'Predicción fallback: Categoría $bestCategoryIndex, Duración: $adjustedDuration min');

    return [
      categoryLogits,
      [adjustedDuration],
    ];
  }

  int _getCategoryIndex(List<double> logits) {
    // Obtener el índice de la categoría con mayor probabilidad (argmax)
    double maxValue = logits[0];
    int maxIndex = 0;

    for (int i = 1; i < logits.length; i++) {
      if (logits[i] > maxValue) {
        maxValue = logits[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  // Método auxiliar para determinar una categoría predeterminada basada en palabras clave
  String _determineDefaultCategory(String description) {
    final desc = description.toLowerCase();

    final Map<String, String> keywordMap = {
      'trabajo': 'Trabajo',
      'estudiar': 'Estudio',
      'estudios': 'Estudio',
      'leer': 'Estudio',
      'libro': 'Estudio',
      'proyecto': 'Trabajo',
      'reunión': 'Trabajo',
      'ejercicio': 'Salud',
      'entrenar': 'Salud',
      'correr': 'Salud',
      'gimnasio': 'Salud',
      'cocinar': 'Hogar',
      'limpiar': 'Hogar',
      'compras': 'Hogar',
      'amigos': 'Social',
      'familia': 'Social',
      'fiesta': 'Social',
      'cine': 'Ocio',
      'jugar': 'Ocio',
      'descansar': 'Descanso',
      'dormir': 'Descanso',
      'médico': 'Salud',
      'doctor': 'Salud',
      'hospital': 'Salud',
      'programar': 'Trabajo',
      'código': 'Trabajo',
    };

    for (final entry in keywordMap.entries) {
      if (desc.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Otros'; // Categoría predeterminada
  }

  // Compatibilidad con la API anterior
  Future<List<dynamic>> getRecommendations({
    List<InteractionEvent>? interactionEvents,
    String? type,
  }) async {
    if (!_isInitialized) {
      _logger.w(
          'El servicio de recomendaciones no está inicializado. Retornando recomendaciones predeterminadas.');
      return _getDefaultRecommendations(type);
    }

    try {
      // Limitar eventos de interacción al máximo permitido
      if (interactionEvents != null &&
          interactionEvents.length > _maxHistoryLength) {
        interactionEvents = interactionEvents
            .sublist(interactionEvents.length - _maxHistoryLength);
        _logger.d(
            'Eventos de interacción limitados a los $_maxHistoryLength más recientes');
      }

      // Generar recomendaciones ficticias para mantener compatibilidad
      // En una implementación real, aquí se usaría el modelo multitarea
      return _getDefaultRecommendations(type);
    } catch (e) {
      _logger.e('Error al obtener recomendaciones', error: e);
      return _getDefaultRecommendations(type);
    }
  }

  List<dynamic> _getDefaultRecommendations(String? type) {
    // En modo debug, usar datos ficticios más realistas
    if (kDebugMode) {
      _logger.i('Usando recomendaciones ficticias para modo debug');
      return DebugDataService.generateFakeRecommendations();
    }
    
    return type == 'habit'
        ? [
            {
              'title': 'Ejercicio diario',
              'description': '30 minutos de ejercicio cardiovascular',
              'category': 'Salud',
              'daysOfWeek': ['Lunes', 'Miércoles', 'Viernes'],
              'reminder': '15 minutos antes',
              'time': '07:00',
            },
            {
              'title': 'Lectura técnica',
              'description': 'Leer documentación de Flutter',
              'category': 'Desarrollo',
              'daysOfWeek': ['Martes', 'Jueves'],
              'reminder': '30 minutos antes',
              'time': '09:00',
            },
            {
              'title': 'Meditación',
              'description': '15 minutos de meditación guiada',
              'category': 'Bienestar',
              'daysOfWeek': ['Lunes', 'Miércoles', 'Viernes'],
              'reminder': '5 minutos antes',
              'time': '20:00',
            },
          ]
        : [
            {
              'title': 'Ejercicio matutino',
              'description': '30 minutos de ejercicio cardiovascular',
              'category': 'Salud',
              'startHour': 7,
              'startMinute': 0,
              'duration': 1,
            },
            {
              'title': 'Lectura técnica',
              'description': 'Leer documentación de Flutter',
              'category': 'Desarrollo',
              'startHour': 9,
              'startMinute': 0,
              'duration': 2,
            },
            {
              'title': 'Almuerzo',
              'description': 'Preparar y disfrutar una comida saludable',
              'category': 'Alimentación',
              'startHour': 13,
              'startMinute': 0,
              'duration': 1,
            },
          ];
  }

  void dispose() {
    _modelAdapter?.dispose();
    _modelAdapter = null;
    _isInitialized = false;
    _isUsingFallback = false;
  }
}
