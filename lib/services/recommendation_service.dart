import 'dart:math' as math; // Asegurar que math esté importado
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;
// Asumiendo que tflite_flutter es el plugin que usarás.
// Necesitarás añadir `tflite_flutter` a tu pubspec.yaml

import '../data/models/interaction_event.dart';
import './tisasrec_preprocessor.dart';

class RecommendationService {
  late tflite.Interpreter _interpreter;
  late TisasrecPreprocessor _preprocessor;
  bool _isInterpreterLoaded = false;

  final String modelPath;
  final String itemMapPath;
  final String reverseItemMapPath;
  final String modelConfigPath;

  // Mapeo de ID de ítem entero (salida del modelo) a ID original
  late Map<int, String> _reverseItemMapping;
  late Map<String, int> _itemMapping;

  // Configuración del modelo
  late int _maxlen;
  late int _timeSpan;
  late int _hiddenUnits;

  RecommendationService({
    this.modelPath = 'assets/ml_models/tisasrec/tisasrec_ml1m.tflite',
    this.itemMapPath = 'assets/ml_models/tisasrec/item_mapping_ml1m.json',
    this.reverseItemMapPath =
        'assets/ml_models/tisasrec/reverse_item_mapping_ml1m.json',
    this.modelConfigPath = 'assets/ml_models/tisasrec/model_config.json',
  });

  Future<void> loadModelAndPreprocessor() async {
    if (_isInterpreterLoaded) return;

    try {
      // 1. Cargar la configuración del modelo
      final String modelConfigJson =
          await rootBundle.loadString(modelConfigPath);
      final Map<String, dynamic> modelConfig = json.decode(modelConfigJson);

      _maxlen = modelConfig['maxlen'] ?? DEFAULT_MAX_LEN;
      _timeSpan = modelConfig['time_span'] ?? DEFAULT_TIME_SPAN;
      _hiddenUnits = modelConfig['hidden_units'] ?? 50;

      print(
          'RecommendationService: Configuración cargada: maxlen=$_maxlen, timeSpan=$_timeSpan, hiddenUnits=$_hiddenUnits');

      // 2. Cargar los mapeos de items
      final String itemMapJson = await rootBundle.loadString(itemMapPath);
      _itemMapping = Map<String, int>.from(json.decode(itemMapJson));

      final String reverseItemMapJson =
          await rootBundle.loadString(reverseItemMapPath);
      _reverseItemMapping =
          Map<String, dynamic>.from(json.decode(reverseItemMapJson))
              .map((key, value) => MapEntry(int.parse(key), value.toString()));

      print(
          'RecommendationService: Mapeos cargados. Items en vocabulario: ${_itemMapping.length}');

      // 3. Inicializar el preprocesador
      _preprocessor = TisasrecPreprocessor(
        itemMapping: _itemMapping,
        maxlen: _maxlen,
        timeSpan: _timeSpan,
      );

      // 4. Cargar el intérprete TFLite
      _interpreter = await tflite.Interpreter.fromAsset(modelPath);

      _isInterpreterLoaded = true;
      print(
          'RecommendationService: Modelo TFLite y preprocesador cargados correctamente.');
    } catch (e) {
      print('Error al cargar el modelo TFLite o el preprocesador: $e');
      _isInterpreterLoaded = false;
      rethrow;
    }
  }

  Future<List<String>> getRecommendations(
      List<InteractionEvent> userInteractionHistory,
      {int topK = 10,
      List<String>? candidateItemOriginalIds}) async {
    if (!_isInterpreterLoaded) {
      print('Error: El intérprete TFLite no está cargado.');
      await loadModelAndPreprocessor();
      if (!_isInterpreterLoaded) throw Exception("Fallo al cargar el modelo");
    }

    try {
      // 1. Preprocesar las entradas
      final List<Object> inputs =
          _preprocessor.preprocessInput(userInteractionHistory);

      // 2. Determinar cuántos ítems hay en el vocabulario
      int numOutputScores = _itemMapping.length;

      // 3. Preparar el buffer de salida
      var outputBuffer =
          List.generate(1, (_) => List<double>.filled(numOutputScores, 0.0));

      // 4. Ejecutar la inferencia
      Map<int, Object> outputsMap = {0: outputBuffer};

      _interpreter.runForMultipleInputs(inputs, outputsMap);
      List<double> logits = outputBuffer[0];

      // 5. Procesar los resultados
      List<MapEntry<int, double>> scoredItems = [];

      // Procesar las puntuaciones para cada ítem
      for (int i = 0; i < logits.length; i++) {
        // El índice corresponde al ID interno del ítem + 1
        int itemIdInt = i + 1;
        if (_reverseItemMapping.containsKey(itemIdInt)) {
          scoredItems.add(MapEntry(itemIdInt, logits[i]));
        }
      }

      // Ordenar por score descendente
      scoredItems.sort((a, b) => b.value.compareTo(a.value));

      // Filtrar ítems que el usuario ya ha visto, si es necesario
      Set<String> userInteractedItems =
          userInteractionHistory.map((e) => e.itemId).toSet();

      // Tomar topK y mapear de vuelta a IDs originales
      List<String> recommendedItemOriginalIds = [];
      for (int i = 0; i < math.min(topK, scoredItems.length); i++) {
        String? originalId = _reverseItemMapping[scoredItems[i].key];
        if (originalId != null && !userInteractedItems.contains(originalId)) {
          recommendedItemOriginalIds.add(originalId);
        }
      }

      // Si no tenemos suficientes recomendaciones después de filtrar
      if (recommendedItemOriginalIds.length < topK) {
        // Intentar agregar más ítems que no estén ya en la lista
        for (int i = topK;
            i < scoredItems.length && recommendedItemOriginalIds.length < topK;
            i++) {
          String? originalId = _reverseItemMapping[scoredItems[i].key];
          if (originalId != null && !userInteractedItems.contains(originalId)) {
            recommendedItemOriginalIds.add(originalId);
          }
        }
      }

      return recommendedItemOriginalIds;
    } catch (e) {
      print('Error durante la inferencia de recomendaciones: $e');
      return [];
    }
  }

  void dispose() {
    if (_isInterpreterLoaded) {
      _interpreter.close();
      _isInterpreterLoaded = false;
    }
  }
}
