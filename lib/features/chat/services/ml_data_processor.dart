import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../services/tflite_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/recommendation_service.dart'
    as core_recommendation;
import '../../../core/services/csv_service.dart';
import '../../../core/services/ml_model_adapter.dart';

/// Clase para procesar y formatear datos de ML para usarlos como contexto en el chat
class MLDataProcessor {
  final TFLiteService? _tfliteService;
  final core_recommendation.RecommendationService _recommendationService;
  final CSVService _csvService;
  final MlModelAdapter? _mlModelAdapter;

  MLDataProcessor({
    TFLiteService? tfliteService,
    core_recommendation.RecommendationService? recommendationService,
    CSVService? csvService,
    MlModelAdapter? mlModelAdapter,
  })  : _tfliteService = tfliteService,
        _recommendationService = recommendationService ??
            getIt<core_recommendation.RecommendationService>(),
        _csvService = csvService ?? CSVService(),
        _mlModelAdapter = mlModelAdapter;

  /// Obtiene datos relevantes de los modelos ML como contexto para el chat
  Future<String> getMLContextData() async {
    final StringBuffer contextData = StringBuffer();
    
    // Contexto principal del sistema
    contextData.writeln('=== TEMPOSAGE ML CONTEXT ===');
    contextData.writeln('Soy un asistente de productividad que utiliza modelos de Machine Learning para:');
    contextData.writeln('1. Recomendar actividades basadas en patrones del usuario');
    contextData.writeln('2. Predecir horarios óptimos para tareas');
    contextData.writeln('3. Analizar productividad y sugerir mejoras');
    contextData.writeln('4. Generar bloques de tiempo inteligentes');
    contextData.writeln('');

    try {
      // 1. Categorías y mapeos disponibles
      await _addCategoriesContext(contextData);
      
      // 2. Datos de productividad y patrones
      await _addProductivityContext(contextData);
      
      // 3. Bloques de tiempo óptimos
      await _addTimeBlocksContext(contextData);
      
      // 4. Recomendaciones actuales
      await _addRecommendationsContext(contextData);
      
      // 5. Estadísticas del usuario
      await _addUserStatsContext(contextData);
      
      // 6. Capacidades del modelo ML
      await _addMLCapabilitiesContext(contextData);
      
    } catch (e) {
      contextData.writeln('Error al cargar contexto ML: $e');
    }
    
    return contextData.toString();
  }

  /// Añade información sobre categorías disponibles
  Future<void> _addCategoriesContext(StringBuffer contextData) async {
    try {
      final String itemMappingJson = await rootBundle
          .loadString('assets/ml_models/tisasrec/item_mapping.json');
      final Map<String, dynamic> itemMapping = jsonDecode(itemMappingJson);
      
      final String categoryMappingJson = await rootBundle
          .loadString('assets/ml_models/metadata/category_mapping.json');
      final Map<String, dynamic> categoryMapping = jsonDecode(categoryMappingJson);
      
      contextData.writeln('=== CATEGORÍAS DISPONIBLES ===');
      contextData.writeln('Categorías principales: ${itemMapping.keys.join(', ')}');
      
      if (categoryMapping['categories'] != null) {
        contextData.writeln('Categorías detalladas:');
        final categories = categoryMapping['categories'] as Map<String, dynamic>;
        categories.forEach((key, value) {
          contextData.writeln('  $key: $value');
        });
      }
      contextData.writeln('');
    } catch (e) {
      contextData.writeln('No se pudieron cargar las categorías: $e');
    }
  }

  /// Añade contexto de productividad y patrones
  Future<void> _addProductivityContext(StringBuffer contextData) async {
    try {
      contextData.writeln('=== PATRONES DE PRODUCTIVIDAD ===');
      
      // Cargar estadísticas de bloques productivos
      final productiveBlocks = await _csvService.loadTop3Blocks();
      if (productiveBlocks.isNotEmpty) {
        contextData.writeln('Bloques de tiempo más productivos:');
        for (final block in productiveBlocks.take(5)) {
          final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
          final dayName = block.weekday < dayNames.length ? dayNames[block.weekday] : 'Día ${block.weekday}';
          contextData.writeln('  $dayName a las ${block.hour}:00 - ${block.category ?? "Sin categoría"} (${(block.completionRate * 100).toStringAsFixed(1)}% completado)');
        }
      }
      
      // Cargar estadísticas generales
      final stats = await _csvService.loadAllBlocksStats();
      if (stats.isNotEmpty) {
        contextData.writeln('\nEstadísticas de productividad por categoría:');
        final categoryStats = <String, List<double>>{};
        for (final stat in stats) {
          final category = stat.category ?? 'Sin categoría';
          final rate = stat.completionRate;
          categoryStats.putIfAbsent(category, () => []).add(rate);
        }
        
        categoryStats.forEach((category, rates) {
          final avgRate = rates.reduce((a, b) => a + b) / rates.length;
          contextData.writeln('  $category: ${(avgRate * 100).toStringAsFixed(1)}% promedio');
        });
      }
      contextData.writeln('');
    } catch (e) {
      contextData.writeln('No se pudieron cargar estadísticas de productividad: $e');
    }
  }

  /// Añade contexto de bloques de tiempo óptimos
  Future<void> _addTimeBlocksContext(StringBuffer contextData) async {
    try {
      final String categoryMappingJson = await rootBundle
          .loadString('assets/ml_models/metadata/category_mapping.json');
      final Map<String, dynamic> categoryMapping = jsonDecode(categoryMappingJson);
      
      if (categoryMapping['time_blocks'] != null) {
        contextData.writeln('=== BLOQUES DE TIEMPO DISPONIBLES ===');
        final timeBlocks = categoryMapping['time_blocks'] as Map<String, dynamic>;
        timeBlocks.forEach((key, value) {
          contextData.writeln('  $key: $value');
        });
        contextData.writeln('');
      }
    } catch (e) {
      contextData.writeln('No se pudieron cargar bloques de tiempo: $e');
    }
  }

  /// Añade contexto de recomendaciones actuales
  Future<void> _addRecommendationsContext(StringBuffer contextData) async {
    try {
      contextData.writeln('=== RECOMENDACIONES INTELIGENTES ===');
      final recommendations = await _recommendationService.getRecommendations();
      if (recommendations.isNotEmpty) {
        contextData.writeln('Actividades recomendadas actualmente:');
        for (final recommendation in recommendations.take(5)) {
          if (recommendation is Map) {
            final title = recommendation['title'] ?? 'Sin título';
            final category = recommendation['category'] ?? 'Sin categoría';
            final score = recommendation['score'] ?? 0.0;
            contextData.writeln('  - $title ($category) - Score: ${score.toStringAsFixed(2)}');
          } else {
            contextData.writeln('  - $recommendation');
          }
        }
      }
      contextData.writeln('');
    } catch (e) {
      contextData.writeln('No se pudieron cargar recomendaciones: $e');
    }
  }

  /// Añade estadísticas del usuario
  Future<void> _addUserStatsContext(StringBuffer contextData) async {
    try {
      contextData.writeln('=== ESTADÍSTICAS DEL USUARIO ===');
      
      // Aquí podrías agregar estadísticas reales del usuario
      // Por ahora, agregamos información general
      contextData.writeln('El usuario tiene acceso a:');
      contextData.writeln('- Modelo multitarea para predicciones de actividades');
      contextData.writeln('- Sistema TiSASRec para recomendaciones basadas en historial');
      contextData.writeln('- Análisis de patrones de productividad');
      contextData.writeln('- Predicción de horarios óptimos');
      contextData.writeln('');
    } catch (e) {
      contextData.writeln('No se pudieron cargar estadísticas del usuario: $e');
    }
  }

  /// Añade capacidades del modelo ML
  Future<void> _addMLCapabilitiesContext(StringBuffer contextData) async {
    try {
      contextData.writeln('=== CAPACIDADES DEL MODELO ML ===');
      
      if (_tfliteService != null) {
        final labels = _tfliteService.labels;
        contextData.writeln('Etiquetas del modelo TFLite: ${labels.join(', ')}');
        
        // Ejemplo de inferencia
        final sampleInference = await _tfliteService.runInference(
          taskDescription: 'Estudiar para examen',
          estimatedDuration: 2.0,
          startHour: 14.0,
          startWeekday: 1.0,
          oheValues: List.generate(5, (index) => index == 1 ? 1.0 : 0.0),
        );
        contextData.writeln('Ejemplo de predicción:');
        contextData.writeln('  Entrada: "Estudiar para examen"');
        contextData.writeln('  Categoría predicha: ${sampleInference['category']}');
        contextData.writeln('  Duración predicha: ${sampleInference['duration']} horas');
      }
      
      if (_mlModelAdapter != null) {
        contextData.writeln('Modelo adaptador disponible con capacidades multitarea');
      }
      
      contextData.writeln('');
    } catch (e) {
      contextData.writeln('No se pudieron cargar capacidades del modelo: $e');
    }
  }

  /// Obtiene contexto específico para una consulta del usuario
  Future<String> getContextualMLData(String userQuery) async {
    final StringBuffer contextData = StringBuffer();
    
    // Analizar la consulta del usuario para proporcionar contexto relevante
    if (userQuery.toLowerCase().contains('recomendar') || 
        userQuery.toLowerCase().contains('actividad')) {
      await _addRecommendationsContext(contextData);
    }
    
    if (userQuery.toLowerCase().contains('horario') || 
        userQuery.toLowerCase().contains('tiempo')) {
      await _addTimeBlocksContext(contextData);
    }
    
    if (userQuery.toLowerCase().contains('productividad') || 
        userQuery.toLowerCase().contains('estadística')) {
      await _addProductivityContext(contextData);
    }
    
    return contextData.toString();
  }
}
