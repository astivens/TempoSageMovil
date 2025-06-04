import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../services/tflite_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/recommendation_service.dart'
    as core_recommendation;

/// Clase para procesar y formatear datos de ML para usarlos como contexto en el chat
class MLDataProcessor {
  final TFLiteService? _tfliteService;
  final core_recommendation.RecommendationService _recommendationService;

  MLDataProcessor({
    TFLiteService? tfliteService,
    core_recommendation.RecommendationService? recommendationService,
  })  : _tfliteService = tfliteService,
        _recommendationService = recommendationService ??
            ServiceLocator.instance.recommendationService;

  /// Obtiene datos relevantes de los modelos ML como contexto para el chat
  Future<String> getMLContextData() async {
    final StringBuffer contextData = StringBuffer();
    contextData.writeln('Información de modelos de ML disponibles:');
    try {
      final String itemMappingJson = await rootBundle
          .loadString('assets/ml_models/tisasrec/item_mapping.json');
      final Map<String, dynamic> itemMapping = jsonDecode(itemMappingJson);
      contextData.writeln('\nCategorías de actividades disponibles:');
      final categories = itemMapping.keys.toList();
      contextData.writeln(categories.join(', '));
      final recommendations = await _recommendationService.getRecommendations();
      if (recommendations.isNotEmpty) {
        contextData.writeln('\nEjemplos de actividades recomendadas:');
        for (final recommendation in recommendations) {
          if (recommendation is Map) {
            final title = recommendation['title'] ?? 'Sin título';
            final category = recommendation['category'] ?? 'Sin categoría';
            contextData.writeln('- $title ($category)');
          } else {
            contextData.writeln('- $recommendation');
          }
        }
      }
    } catch (e) {
      contextData
          .writeln('No se pudo cargar información detallada del modelo ML: $e');
    }
    if (_tfliteService != null) {
      try {
        final labels = _tfliteService.labels;
        contextData.writeln('\nEtiquetas del modelo TFLite:');
        contextData.writeln(labels.join(', '));
        final sampleInference = await _tfliteService.runInference(
          taskDescription: 'Estudiar para examen',
          estimatedDuration: 2.0,
          startHour: 14.0,
          startWeekday: 1.0,
          oheValues: List.generate(5, (index) => index == 1 ? 1.0 : 0.0),
        );
        contextData.writeln('\nEjemplo de inferencia TFLite:');
        contextData
            .writeln('Categoría predicha: ${sampleInference['category']}');
        contextData
            .writeln('Duración predicha: ${sampleInference['duration']} horas');
      } catch (e) {
        contextData
            .writeln('No se pudo obtener información del modelo TFLite: $e');
      }
    } else {
      contextData.writeln('\nServicio TFLite no disponible.');
    }
    return contextData.toString();
  }
}
