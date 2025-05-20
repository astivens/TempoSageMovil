import 'dart:convert';
import 'package:flutter/services.dart';
// Eliminamos la importación de tflite_flutter

import '../data/models/interaction_event.dart';
// Eliminamos la importación de tisasrec_preprocessor

class RecommendationService {
  bool _isInitialized = false;

  final String itemMapPath;

  // Mapeo de categorías
  Map<String, int> _itemMapping = {};

  RecommendationService({
    this.itemMapPath = 'assets/ml_models/tisasrec/item_mapping.json',
  });

  Future<void> loadModelAndPreprocessor() async {
    if (_isInitialized) return;

    try {
      // Cargar mapeo de categorías
      final String itemMapJson = await rootBundle.loadString(itemMapPath);
      _itemMapping = Map<String, int>.from(json.decode(itemMapJson));

      print(
          'RecommendationService: Mapeos cargados. Items en vocabulario: ${_itemMapping.length}');

      _isInitialized = true;
      print('RecommendationService: Servicio inicializado correctamente.');
    } catch (e) {
      print('Error al cargar el mapeo de categorías: $e');
      _isInitialized = false;
      _initializeDefaultMapping();
    }
  }

  void _initializeDefaultMapping() {
    _itemMapping = {
      'Trabajo': 1,
      'Estudio': 2,
      'Ejercicio': 3,
      'Ocio': 4,
      'Otro': 5,
    };
    _isInitialized = true;
    print('RecommendationService: Usando mapeo de categorías predeterminado.');
  }

  Future<List<String>> getRecommendations(
      List<InteractionEvent> userInteractionHistory,
      {int topK = 10,
      List<String>? candidateItemOriginalIds}) async {
    if (!_isInitialized) {
      await loadModelAndPreprocessor();
    }

    try {
      // Implementación basada en reglas
      return _getRuleBasedRecommendations(userInteractionHistory, topK);
    } catch (e) {
      print('Error durante la generación de recomendaciones: $e');
      // Devolver categorías predeterminadas en caso de error
      return ['Trabajo', 'Estudio', 'Ejercicio', 'Ocio', 'Otro']
          .take(topK)
          .toList();
    }
  }

  List<String> _getRuleBasedRecommendations(
      List<InteractionEvent> userHistory, int topK) {
    if (userHistory.isEmpty) {
      return ['Trabajo', 'Estudio', 'Ejercicio', 'Ocio', 'Otro']
          .take(topK)
          .toList();
    }

    // Contar frecuencia de categorías
    final Map<String, int> categoryCounts = {};
    for (var event in userHistory) {
      categoryCounts[event.itemId] = (categoryCounts[event.itemId] ?? 0) + 1;
    }

    // Ordenar por frecuencia
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Obtener las categorías más frecuentes
    final topCategories =
        sortedCategories.take(topK).map((e) => e.key).toList();

    // Si no hay suficientes categorías, agregar algunas predeterminadas
    final defaultCategories = ['Trabajo', 'Estudio', 'Ejercicio', 'Ocio'];
    while (topCategories.length < topK && defaultCategories.isNotEmpty) {
      final category = defaultCategories.removeAt(0);
      if (!topCategories.contains(category)) {
        topCategories.add(category);
      }
    }

    print(
        'RecommendationService: Recomendaciones basadas en reglas generadas: $topCategories');
    return topCategories;
  }

  void dispose() {
    _isInitialized = false;
  }
}
