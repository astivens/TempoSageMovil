import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

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

class RecommendationService {
  final Logger _logger = Logger.instance;
  static const String _modelFileName = 'activity_recommendation_model.tflite';
  static const String _metadataFileName = 'model_metadata.json';
  static const String _categoryMappingFileName = 'category_mapping.json';

  Interpreter? _interpreter;
  Map<String, dynamic>? _metadata;
  Map<String, dynamic>? _categoryMapping;
  bool _isInitialized = false;

  // Configuración
  static const int _numRecommendations = 5;
  static const int _maxHistoryLength = 50;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cargar el modelo TFLite
      final modelFile = await _getModelFile();
      _interpreter = await Interpreter.fromFile(modelFile);

      // Cargar metadatos y mapeo de categorías
      _metadata = await _loadJsonAsset(_metadataFileName);
      _categoryMapping = await _loadJsonAsset(_categoryMappingFileName);

      _isInitialized = true;
      _logger.i('Servicio de recomendaciones inicializado correctamente');
    } catch (e) {
      _logger.e('Error al inicializar el servicio de recomendaciones',
          error: e);
      rethrow;
    }
  }

  Future<File> _getModelFile() async {
    try {
      // Primero intentar cargar desde el almacenamiento interno
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${appDir.path}/$_modelFileName');

      if (await modelFile.exists()) {
        return modelFile;
      }

      // Si no existe, copiar desde los assets
      final modelData = await rootBundle.load('assets/models/$_modelFileName');
      final bytes = modelData.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);

      return modelFile;
    } catch (e) {
      _logger.e('Error al obtener el archivo del modelo', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _loadJsonAsset(String fileName) async {
    try {
      final jsonString = await rootBundle.loadString('assets/models/$fileName');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error al cargar el archivo JSON $fileName', error: e);
      rethrow;
    }
  }

  Future<List<dynamic>> getRecommendations({
    List<InteractionEvent>? interactionEvents,
    String? type,
  }) async {
    if (!_isInitialized || _interpreter == null) {
      throw StateError('El servicio de recomendaciones no está inicializado');
    }

    try {
      // Obtener el historial de actividades del usuario
      final prefs = await SharedPreferences.getInstance();
      final userHistory = prefs.getStringList('activity_history') ?? [];

      // Limitar el historial a los últimos _maxHistoryLength elementos
      final limitedHistory = userHistory.take(_maxHistoryLength).toList();

      // Preparar los datos de entrada para el modelo
      final inputData =
          _prepareInputData(limitedHistory, interactionEvents, type);

      // Ejecutar el modelo
      final outputData = await _runModel(inputData);

      // Procesar las recomendaciones según el tipo
      return _processRecommendations(outputData, type);
    } catch (e) {
      _logger.e('Error al obtener recomendaciones', error: e);
      rethrow;
    }
  }

  List<List<double>> _prepareInputData(
    List<String> userHistory,
    List<InteractionEvent>? interactionEvents,
    String? type,
  ) {
    // Implementar la lógica para preparar los datos de entrada
    // según el formato esperado por el modelo y el tipo de recomendación
    // Por ahora, retornamos datos de ejemplo
    return List.generate(
      10,
      (index) => List.generate(10, (i) => (i + index) / 10.0),
    );
  }

  Future<List<List<double>>> _runModel(List<List<double>> inputData) async {
    if (_interpreter == null) {
      throw StateError('El intérprete no está inicializado');
    }

    // Preparar tensores de entrada y salida
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;

    final inputBuffer = Float32List(inputShape.reduce((a, b) => a * b));
    final outputBuffer = Float32List(outputShape.reduce((a, b) => a * b));

    // Llenar el buffer de entrada
    var index = 0;
    for (var i = 0; i < inputData.length; i++) {
      for (var j = 0; j < inputData[i].length; j++) {
        inputBuffer[index++] = inputData[i][j];
      }
    }

    // Ejecutar el modelo
    _interpreter!.run(inputBuffer.buffer, outputBuffer.buffer);

    // Procesar la salida
    final output = List.generate(
      outputShape[0],
      (i) => List.generate(
        outputShape[1],
        (j) => outputBuffer[i * outputShape[1] + j],
      ),
    );

    return output;
  }

  List<dynamic> _processRecommendations(
      List<List<double>> modelOutput, String? type) {
    if (_metadata == null || _categoryMapping == null) {
      throw StateError('Metadatos o mapeo de categorías no disponibles');
    }

    // Procesar la salida del modelo según el tipo de recomendación
    final recommendations = type == 'habit'
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

    return recommendations.take(_numRecommendations).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
