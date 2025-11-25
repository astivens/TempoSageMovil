import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/logger.dart';

/// Clase que adapta diferentes modelos de TensorFlow Lite para el uso en la aplicación
///
/// Esta clase proporciona una capa de abstracción que se adapta dinámicamente
/// a diferentes estructuras y configuraciones de modelos TFLite, facilitando
/// su integración independientemente de sus especificaciones exactas.
class MlModelAdapter {
  final Logger _logger = Logger('MlModelAdapter');

  // Nuevo: path personalizado para modelos
  final String? modelDirectoryPath;

  // Intérprete TFLite
  Interpreter? _interpreter;

  // Metadatos del modelo
  Map<String, dynamic> _modelInfo = {};
  List<Map<String, dynamic>> _inputInfo = [];
  List<Map<String, dynamic>> _outputInfo = [];

  MlModelAdapter({this.modelDirectoryPath});

  /// Inicializa el adaptador cargando el modelo especificado
  Future<bool> initialize(String modelFileName, {String? modelBasePath}) async {
    modelBasePath ??= 'ml_models/TPS_Model';
    try {
      // 1. Cargar el modelo
      final modelFile = await _getModelFile(modelFileName, modelBasePath);
      _logger.d('Cargando modelo desde: ${modelFile.path}');

      // 2. Inicializar el intérprete
      _interpreter = await Interpreter.fromFile(modelFile);

      // 3. Analizar la estructura del modelo
      _analyzeModelStructure();

      _logger.i('Adaptador de modelo inicializado correctamente');
      return true;
    } catch (e, stackTrace) {
      // En tests o cuando TensorFlow Lite no está disponible, esto es esperado
      // Usar WARNING en lugar de ERROR para no confundir en logs de tests
      final isExpectedFailure = e.toString().contains('cannot open shared object file') ||
          e.toString().contains('MissingPluginException') ||
          kDebugMode;
      
      if (isExpectedFailure) {
        _logger.w('No se pudo inicializar TensorFlow Lite (modo fallback activado): $e');
      } else {
      _logger.e('Error al inicializar el adaptador del modelo',
          error: e, stackTrace: stackTrace);
      }
      return false;
    }
  }

  /// Obtiene el archivo del modelo desde assets o almacenamiento local
  Future<File> _getModelFile(String modelFileName, String modelBasePath) async {
    try {
      // Usar path personalizado si está presente
      String dirPath;
      if (modelDirectoryPath != null) {
        dirPath = modelDirectoryPath!;
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        dirPath = appDir.path;
      }
      final modelFile = File('${dirPath}/$modelFileName');

      if (await modelFile.exists()) {
        return modelFile;
      }

      // Si no existe, copiar desde assets
      final modelData =
          await rootBundle.load('assets/$modelBasePath/$modelFileName');
      final bytes = modelData.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);

      return modelFile;
    } catch (e) {
      throw Exception('Error al obtener archivo del modelo: $e');
    }
  }

  /// Analiza la estructura interna del modelo y guarda información sobre sus tensores
  void _analyzeModelStructure() {
    if (_interpreter == null) {
      throw Exception('El intérprete no está inicializado');
    }

    try {
      // 1. Analizar tensores de entrada
      final inputTensors = _interpreter!.getInputTensors();
      _inputInfo = [];

      for (int i = 0; i < inputTensors.length; i++) {
        final tensor = inputTensors[i];
        _inputInfo.add({
          'index': i,
          'shape': tensor.shape,
          'dims': tensor.shape.length,
          'type': tensor.type,
          'name': tensor.name,
        });
      }

      // 2. Analizar tensores de salida
      final outputTensors = _interpreter!.getOutputTensors();
      _outputInfo = [];

      for (int i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        _outputInfo.add({
          'index': i,
          'shape': tensor.shape,
          'dims': tensor.shape.length,
          'type': tensor.type,
          'name': tensor.name,
        });
      }

      // 3. Resumir información del modelo
      _modelInfo = {
        'inputs': _inputInfo.length,
        'outputs': _outputInfo.length,
        'modelType': _determineModelType(),
      };

      _logger.d('Estructura del modelo analizada: $_modelInfo');
    } catch (e, stackTrace) {
      _logger.e('Error al analizar estructura del modelo',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Determina el tipo de modelo basado en su estructura
  String _determineModelType() {
    // Heurísticas simples para determinar el tipo de modelo
    if (_inputInfo.length >= 2 && _outputInfo.length >= 2) {
      return 'multitask';
    } else if (_inputInfo.length == 1 && _outputInfo.length >= 2) {
      return 'multitask_single_input';
    } else {
      return 'simple';
    }
  }

  /// Ejecuta el modelo con datos de entrada específicos, adaptándose automáticamente
  /// a la estructura del modelo
  Future<Map<String, dynamic>> runInference(
      {required String text,
      required double estimatedDuration,
      double? timeOfDay,
      double? dayOfWeek,
      Map<String, double>? additionalFeatures}) async {
    if (_interpreter == null) {
      throw Exception('Intérprete no inicializado');
    }

    try {
      final inputs = <Object>[];
      final outputs = <int, Object>{};

      // Preparar datos de entrada procesando texto y creando tensores
      final textTokens = _preprocessText(text);
      timeOfDay ??= DateTime.now().hour.toDouble();
      dayOfWeek ??= DateTime.now().weekday.toDouble() - 1;

      // Detectar automáticamente el patrón de entradas basado en la estructura del modelo
      if (_modelInfo['modelType'] == 'multitask') {
        // Modelo multitarea con múltiples entradas
        _prepareMultitaskInputs(inputs, textTokens, estimatedDuration,
            timeOfDay, dayOfWeek, additionalFeatures);
      } else if (_modelInfo['modelType'] == 'multitask_single_input') {
        // Modelo multitarea con una sola entrada combinada
        _prepareSingleInputs(inputs, textTokens, estimatedDuration, timeOfDay,
            dayOfWeek, additionalFeatures);
      } else {
        // Modelo simple
        _prepareSimpleInputs(inputs, textTokens, estimatedDuration);
      }

      // Preparar tensores de salida
      _prepareOutputs(outputs);

      // Ejecutar la inferencia
      _logger
          .d('Ejecutando inferencia con ${inputs.length} tensores de entrada');
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // Procesar los resultados
      final results = _processResults(outputs);
      _logger.d('Inferencia completada: $results');

      return results;
    } catch (e, stackTrace) {
      _logger.e('Error durante la inferencia del modelo',
          error: e, stackTrace: stackTrace);
      throw Exception('Error en la inferencia del modelo: $e');
    }
  }

  /// Procesa el texto de entrada en tokens
  List<String> _preprocessText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((token) => token.isNotEmpty)
        .take(20)
        .toList();
  }

  /// Prepara las entradas para un modelo multitarea con múltiples entradas
  void _prepareMultitaskInputs(
      List<Object> inputs,
      List<String> tokens,
      double duration,
      double timeOfDay,
      double dayOfWeek,
      Map<String, double>? additionalFeatures) {
    for (int i = 0; i < _inputInfo.length; i++) {
      final info = _inputInfo[i];
      final shape = info['shape'] as List<int>;

      if (i == 0) {
        // Primera entrada suele ser para texto/embeddings
        final maxLength = shape.length > 1 ? shape[1] : 20;
        final textInput =
            List.generate(1, (_) => List<int>.filled(maxLength, 0));

        // Llenar con IDs de tokens
        for (int j = 0; j < tokens.length && j < maxLength; j++) {
          textInput[0][j] = tokens[j].hashCode.abs() % 2000 + 1;
        }

        inputs.add(textInput);
      } else {
        // Entradas numéricas
        final numFeatures = shape.length > 1 ? shape[1] : 1;
        final numericInput = List.generate(
            shape[0], (_) => List<double>.filled(numFeatures, 0.0));

        // Llenar con características disponibles
        if (numFeatures > 0) numericInput[0][0] = duration;
        if (numFeatures > 1) numericInput[0][1] = timeOfDay;
        if (numFeatures > 2) numericInput[0][2] = dayOfWeek;

        // Agregar características adicionales si hay espacio
        if (additionalFeatures != null && numFeatures > 3) {
          var idx = 3;
          additionalFeatures.forEach((_, value) {
            if (idx < numFeatures) {
              numericInput[0][idx++] = value;
            }
          });
        }

        inputs.add(numericInput);
      }
    }
  }

  /// Prepara entradas para modelo con una sola entrada combinada
  void _prepareSingleInputs(
      List<Object> inputs,
      List<String> tokens,
      double duration,
      double timeOfDay,
      double dayOfWeek,
      Map<String, double>? additionalFeatures) {
    final info = _inputInfo[0];
    final shape = info['shape'] as List<int>;

    // Para este tipo de modelo, la entrada suele ser un vector de características
    final numFeatures = shape.length > 1 ? shape[1] : 5;
    final input =
        List.generate(shape[0], (_) => List<double>.filled(numFeatures, 0.0));

    // Representación numérica simplificada del texto (bag of words simplificado)
    if (numFeatures > 3) {
      for (int i = 0; i < tokens.length && i < numFeatures - 3; i++) {
        input[0][i] = tokens[i].hashCode.abs() / 2000;
      }
    }

    // Agregar características numéricas al final
    int offset = numFeatures - 3;
    if (offset >= 0 && offset < numFeatures) input[0][offset] = duration;
    if (offset + 1 < numFeatures) input[0][offset + 1] = timeOfDay;
    if (offset + 2 < numFeatures) input[0][offset + 2] = dayOfWeek;

    inputs.add(input);
  }

  /// Prepara entradas para un modelo simple
  void _prepareSimpleInputs(
      List<Object> inputs, List<String> tokens, double duration) {
    final info = _inputInfo[0];
    final shape = info['shape'] as List<int>;

    if (shape.length == 2) {
      // Entrada 2D [batch_size, features]
      final input =
          List.generate(shape[0], (_) => List<double>.filled(shape[1], 0.0));

      // Llenar con algunas características simples
      if (shape[1] > 0) input[0][0] = duration;

      inputs.add(input);
    } else {
      // Entrada más simple
      final input = List<double>.filled(shape[0], 0.0);
      if (shape[0] > 0) input[0] = duration;

      inputs.add(input);
    }
  }

  /// Prepara los buffers de salida para recibir los resultados
  void _prepareOutputs(Map<int, Object> outputs) {
    for (int i = 0; i < _outputInfo.length; i++) {
      final info = _outputInfo[i];
      final shape = info['shape'] as List<int>;

      if (shape.length >= 2) {
        outputs[i] =
            List.generate(shape[0], (_) => List<double>.filled(shape[1], 0.0));
      } else if (shape.length == 1) {
        outputs[i] = List<double>.filled(shape[0], 0.0);
      } else {
        _logger.w('Forma de salida inusual: $shape');
        outputs[i] = [];
      }
    }
  }

  /// Procesa los resultados de la inferencia en un formato más amigable
  Map<String, dynamic> _processResults(Map<int, Object> outputs) {
    final results = <String, dynamic>{};

    // Para modelo multitarea, generalmente espera:
    // - Salida 0: Logits de categoría
    // - Salida 1: Predicción de duración

    // Categoria (clasificación)
    if (outputs.containsKey(0)) {
      dynamic categoryOutput = outputs[0];
      List<double> categoryScores = [];

      if (categoryOutput is List<List<double>> && categoryOutput.isNotEmpty) {
        categoryScores = categoryOutput[0];
      } else if (categoryOutput is List<double>) {
        categoryScores = categoryOutput;
      }

      if (categoryScores.isNotEmpty) {
        // Obtener el índice de la categoría con mayor puntuación
        int bestCategoryIdx = 0;
        double bestScore = categoryScores[0];

        for (int i = 1; i < categoryScores.length; i++) {
          if (categoryScores[i] > bestScore) {
            bestScore = categoryScores[i];
            bestCategoryIdx = i;
          }
        }

        results['categoryIndex'] = bestCategoryIdx;
        results['categoryScores'] = categoryScores;
        results['topScore'] = bestScore;
      }
    }

    // Duración estimada (regresión)
    if (outputs.containsKey(1)) {
      dynamic durationOutput = outputs[1];
      double durationValue = 0.0;

      if (durationOutput is List<List<double>> && durationOutput.isNotEmpty) {
        durationValue = durationOutput[0][0];
      } else if (durationOutput is List<double> && durationOutput.isNotEmpty) {
        durationValue = durationOutput[0];
      }

      results['duration'] = durationValue;
    }

    return results;
  }

  /// Libera recursos del adaptador
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _inputInfo.clear();
    _outputInfo.clear();
    _modelInfo.clear();
  }

  /// Devuelve información sobre el modelo
  Map<String, dynamic> get modelInfo => Map.from(_modelInfo);
}
