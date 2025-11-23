import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import 'recommendation_service.dart';
import 'csv_service.dart';
import 'ml_model_adapter.dart';
import '../../services/google_ai_service.dart';

/// Servicio que integra completamente los datos ML con Google AI
/// para proporcionar respuestas inteligentes basadas en datos reales
class MLAIIntegrationService {
  final Logger _logger = Logger('MLAIIntegrationService');
  
  final RecommendationService _recommendationService;
  final CSVService _csvService;
  final GoogleAIService _googleAIService;
  final MlModelAdapter? _mlModelAdapter;

  MLAIIntegrationService({
    required RecommendationService recommendationService,
    required CSVService csvService,
    required GoogleAIService googleAIService,
    MlModelAdapter? mlModelAdapter,
  })  : _recommendationService = recommendationService,
        _csvService = csvService,
        _googleAIService = googleAIService,
        _mlModelAdapter = mlModelAdapter;

  /// Procesa una consulta del usuario usando ML + IA
  Future<String> processQueryWithML(String userQuery) async {
    try {
      _logger.d('Procesando consulta con ML: $userQuery');

      // 1. Analizar el tipo de consulta
      final queryType = _analyzeQueryType(userQuery);
      _logger.d('Tipo de consulta detectado: $queryType');

      // 2. Obtener datos ML relevantes
      final mlData = await _getRelevantMLData(queryType, userQuery);
      
      // 3. Verificar si tenemos datos suficientes
      if (mlData.isEmpty) {
        _logger.w('No hay datos ML disponibles, usando respuesta genérica');
        return _getGenericResponse(userQuery, queryType);
      }
      
      // 4. Ejecutar predicciones ML si es necesario
      final mlPredictions = await _runMLPredictions(queryType, userQuery);
      
      // 5. Combinar datos ML con la consulta
      final enrichedQuery = _createEnrichedQuery(userQuery, mlData, mlPredictions);
      
      // 6. Enviar a Google AI con contexto completo
      final response = await _googleAIService.sendMessageWithMLContext(
        userQuery, 
        enrichedQuery
      );
      
      return response.text;
    } catch (e, stackTrace) {
      _logger.e('Error al procesar consulta con ML', error: e, stackTrace: stackTrace);
      return _getGenericResponse(userQuery, QueryType.general);
    }
  }

  /// Analiza el tipo de consulta del usuario
  QueryType _analyzeQueryType(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('recomendar') || lowerQuery.contains('actividad') || 
        lowerQuery.contains('sugerir') || lowerQuery.contains('qué hacer')) {
      return QueryType.recommendation;
    }
    
    if (lowerQuery.contains('horario') || lowerQuery.contains('tiempo') || 
        lowerQuery.contains('cuándo') || lowerQuery.contains('mejor momento')) {
      return QueryType.scheduling;
    }
    
    if (lowerQuery.contains('productividad') || lowerQuery.contains('estadística') || 
        lowerQuery.contains('análisis') || lowerQuery.contains('patrón')) {
      return QueryType.analytics;
    }
    
    if (lowerQuery.contains('categoría') || lowerQuery.contains('tipo') || 
        lowerQuery.contains('clasificar')) {
      return QueryType.classification;
    }
    
    return QueryType.general;
  }

  /// Obtiene datos ML relevantes según el tipo de consulta
  Future<String> _getRelevantMLData(QueryType queryType, String userQuery) async {
    final StringBuffer mlData = StringBuffer();
    
    switch (queryType) {
      case QueryType.recommendation:
        mlData.writeln('=== DATOS PARA RECOMENDACIONES ===');
        await _addRecommendationData(mlData, userQuery);
        break;
        
      case QueryType.scheduling:
        mlData.writeln('=== DATOS PARA HORARIOS ===');
        await _addSchedulingData(mlData, userQuery);
        break;
        
      case QueryType.analytics:
        mlData.writeln('=== DATOS PARA ANÁLISIS ===');
        await _addAnalyticsData(mlData, userQuery);
        break;
        
      case QueryType.classification:
        mlData.writeln('=== DATOS PARA CLASIFICACIÓN ===');
        await _addClassificationData(mlData, userQuery);
        break;
        
      case QueryType.general:
        mlData.writeln('=== DATOS GENERALES ===');
        await _addGeneralData(mlData);
        break;
    }
    
    return mlData.toString();
  }

  /// Añade datos específicos para recomendaciones
  Future<void> _addRecommendationData(StringBuffer mlData, String userQuery) async {
    try {
      // Obtener recomendaciones actuales
      final recommendations = await _recommendationService.getRecommendations();
      if (recommendations.isNotEmpty) {
        mlData.writeln('Recomendaciones actuales del modelo:');
        for (final rec in recommendations.take(5)) {
          if (rec is Map) {
            final title = rec['title'] ?? 'Sin título';
            final category = rec['category'] ?? 'Sin categoría';
            final score = rec['score'] ?? 0.0;
            mlData.writeln('- $title ($category) - Confianza: ${(score * 100).toStringAsFixed(1)}%');
          }
        }
      }
      
      // Obtener categorías disponibles
      final itemMapping = await _loadItemMapping();
      mlData.writeln('\nCategorías disponibles: ${itemMapping.keys.join(', ')}');
      
    } catch (e) {
      mlData.writeln('Error al cargar datos de recomendación: $e');
    }
  }

  /// Añade datos específicos para horarios
  Future<void> _addSchedulingData(StringBuffer mlData, String userQuery) async {
    try {
      // Obtener bloques de tiempo óptimos
      final productiveBlocks = await _csvService.loadTop3Blocks();
      if (productiveBlocks.isNotEmpty) {
        mlData.writeln('Bloques de tiempo más productivos:');
        for (final block in productiveBlocks.take(5)) {
          final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
          final dayName = block.weekday < dayNames.length ? dayNames[block.weekday] : 'Día ${block.weekday}';
          mlData.writeln('- $dayName a las ${block.hour}:00 - ${block.category ?? "Sin categoría"} (${(block.completionRate * 100).toStringAsFixed(1)}% éxito)');
        }
      }
      
      // Obtener estadísticas por hora
      final stats = await _csvService.loadAllBlocksStats();
      if (stats.isNotEmpty) {
        mlData.writeln('\nEstadísticas por hora del día:');
        final hourStats = <int, List<double>>{};
        for (final stat in stats) {
          final hour = stat.hour;
          final rate = stat.completionRate;
          hourStats.putIfAbsent(hour, () => []).add(rate);
        }
        
        hourStats.forEach((hour, rates) {
          final avgRate = rates.reduce((a, b) => a + b) / rates.length;
          mlData.writeln('- ${hour}:00 - ${(avgRate * 100).toStringAsFixed(1)}% productividad promedio');
        });
      }
      
    } catch (e) {
      mlData.writeln('Error al cargar datos de horarios: $e');
    }
  }

  /// Añade datos específicos para análisis
  Future<void> _addAnalyticsData(StringBuffer mlData, String userQuery) async {
    try {
      // Obtener estadísticas generales
      final stats = await _csvService.loadAllBlocksStats();
      if (stats.isNotEmpty) {
        mlData.writeln('Estadísticas de productividad:');
        
        // Estadísticas por categoría
        final categoryStats = <String, List<double>>{};
        for (final stat in stats) {
          final category = stat.category ?? 'Sin categoría';
          final rate = stat.completionRate;
          categoryStats.putIfAbsent(category, () => []).add(rate);
        }
        
        mlData.writeln('\nPor categoría:');
        categoryStats.forEach((category, rates) {
          final avgRate = rates.reduce((a, b) => a + b) / rates.length;
          final maxRate = rates.reduce((a, b) => a > b ? a : b);
          final minRate = rates.reduce((a, b) => a < b ? a : b);
          mlData.writeln('- $category: Promedio ${(avgRate * 100).toStringAsFixed(1)}%, Máximo ${(maxRate * 100).toStringAsFixed(1)}%, Mínimo ${(minRate * 100).toStringAsFixed(1)}%');
        });
        
        // Estadísticas por día de la semana
        final dayStats = <int, List<double>>{};
        for (final stat in stats) {
          final day = stat.weekday;
          final rate = stat.completionRate;
          dayStats.putIfAbsent(day, () => []).add(rate);
        }
        
        mlData.writeln('\nPor día de la semana:');
        final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
        dayStats.forEach((day, rates) {
          final avgRate = rates.reduce((a, b) => a + b) / rates.length;
          mlData.writeln('- ${dayNames[day - 1]}: ${(avgRate * 100).toStringAsFixed(1)}% productividad promedio');
        });
      }
      
    } catch (e) {
      mlData.writeln('Error al cargar datos de análisis: $e');
    }
  }

  /// Añade datos específicos para clasificación
  Future<void> _addClassificationData(StringBuffer mlData, String userQuery) async {
    try {
      // Obtener mapeo de categorías
      final itemMapping = await _loadItemMapping();
      final categoryMapping = await _loadCategoryMapping();
      
      mlData.writeln('Categorías principales: ${itemMapping.keys.join(', ')}');
      
      if (categoryMapping['categories'] != null) {
        mlData.writeln('\nCategorías detalladas:');
        final categories = categoryMapping['categories'] as Map<String, dynamic>;
        categories.forEach((key, value) {
          mlData.writeln('- $key: $value');
        });
      }
      
    } catch (e) {
      mlData.writeln('Error al cargar datos de clasificación: $e');
    }
  }

  /// Añade datos generales
  Future<void> _addGeneralData(StringBuffer mlData) async {
    try {
      mlData.writeln('Sistema TempoSage con capacidades ML:');
      mlData.writeln('- Modelo multitarea para predicciones');
      mlData.writeln('- Sistema TiSASRec para recomendaciones');
      mlData.writeln('- Análisis de patrones de productividad');
      mlData.writeln('- Predicción de horarios óptimos');
      
      // Obtener algunas estadísticas generales
      final stats = await _csvService.loadAllBlocksStats();
      if (stats.isNotEmpty) {
        final totalEntries = stats.length;
        final avgProductivity = stats.map((s) => s.completionRate).reduce((a, b) => a + b) / totalEntries;
        mlData.writeln('\nEstadísticas generales:');
        mlData.writeln('- Total de entradas: $totalEntries');
        mlData.writeln('- Productividad promedio: ${(avgProductivity * 100).toStringAsFixed(1)}%');
      }
      
    } catch (e) {
      mlData.writeln('Error al cargar datos generales: $e');
    }
  }

  /// Ejecuta predicciones ML según el tipo de consulta
  Future<Map<String, dynamic>> _runMLPredictions(QueryType queryType, String userQuery) async {
    final predictions = <String, dynamic>{};
    
    if (_mlModelAdapter == null) {
      return predictions;
    }
    
    try {
      switch (queryType) {
        case QueryType.recommendation:
        case QueryType.classification:
          // Ejecutar predicción de categoría
          final categoryPrediction = await _mlModelAdapter!.runInference(
            text: userQuery,
            estimatedDuration: 60.0, // Duración por defecto
          );
          predictions['category'] = categoryPrediction['categoryIndex'];
          predictions['confidence'] = categoryPrediction['confidence'] ?? 0.0;
          break;
          
        case QueryType.scheduling:
          // Ejecutar predicción de horario óptimo
          final timePrediction = await _mlModelAdapter!.runInference(
            text: userQuery,
            estimatedDuration: 60.0,
            timeOfDay: DateTime.now().hour.toDouble(),
            dayOfWeek: DateTime.now().weekday.toDouble() - 1,
          );
          predictions['optimalTime'] = timePrediction['optimalTime'];
          predictions['optimalDay'] = timePrediction['optimalDay'];
          break;
          
        default:
          // Para consultas generales, ejecutar predicción básica
          final generalPrediction = await _mlModelAdapter!.runInference(
            text: userQuery,
            estimatedDuration: 60.0,
          );
          predictions.addAll(generalPrediction);
          break;
      }
    } catch (e) {
      _logger.w('Error al ejecutar predicciones ML: $e');
    }
    
    return predictions;
  }

  /// Crea una consulta enriquecida con datos ML
  String _createEnrichedQuery(String userQuery, String mlData, Map<String, dynamic> mlPredictions) {
    final StringBuffer enrichedQuery = StringBuffer();
    
    enrichedQuery.writeln('=== CONTEXTO ML COMPLETO ===');
    enrichedQuery.writeln(mlData);
    
    if (mlPredictions.isNotEmpty) {
      enrichedQuery.writeln('\n=== PREDICCIONES ML EN TIEMPO REAL ===');
      mlPredictions.forEach((key, value) {
        enrichedQuery.writeln('$key: $value');
      });
    }
    
    enrichedQuery.writeln('\n=== INSTRUCCIONES ===');
    enrichedQuery.writeln('Usa TODOS los datos ML proporcionados arriba para responder la consulta del usuario.');
    enrichedQuery.writeln('Sé específico y cita los datos exactos cuando sea relevante.');
    enrichedQuery.writeln('Si hay predicciones ML, úsalas para dar recomendaciones precisas.');
    
    return enrichedQuery.toString();
  }

  /// Carga el mapeo de items
  Future<Map<String, dynamic>> _loadItemMapping() async {
    try {
      final String itemMappingJson = await rootBundle
          .loadString('assets/ml_models/tisasrec/item_mapping.json');
      return jsonDecode(itemMappingJson);
    } catch (e) {
      _logger.w('Error al cargar item mapping: $e');
      return {};
    }
  }

  /// Carga el mapeo de categorías
  Future<Map<String, dynamic>> _loadCategoryMapping() async {
    try {
      final String categoryMappingJson = await rootBundle
          .loadString('assets/ml_models/metadata/category_mapping.json');
      return jsonDecode(categoryMappingJson);
    } catch (e) {
      _logger.w('Error al cargar category mapping: $e');
      return {};
    }
  }

  /// Proporciona una respuesta genérica cuando no hay datos ML disponibles
  String _getGenericResponse(String userQuery, QueryType queryType) {
    _logger.i('Proporcionando respuesta genérica para: $queryType');
    
    switch (queryType) {
      case QueryType.recommendation:
        return '''¡Hola! Soy TempoSage AI, tu asistente de productividad. 

Aunque aún no tengo datos específicos de tus patrones de productividad, puedo ayudarte con recomendaciones generales:

📚 **Para estudiar**: Las horas de 9-11 AM y 2-4 PM suelen ser muy productivas
💪 **Para ejercicio**: Las tardes (5-7 PM) son ideales para actividad física
🎯 **Para trabajo**: Las mañanas (8-11 AM) suelen ser las más productivas
🧘 **Para relajación**: Las noches (8-10 PM) son perfectas para actividades tranquilas

¿Te gustaría que te ayude con algo específico? Una vez que uses la app más, podré darte recomendaciones más personalizadas basadas en tus patrones reales.''';

      case QueryType.scheduling:
        return '''¡Hola! Para ayudarte con horarios, te sugiero estos patrones generales:

⏰ **Horarios recomendados**:
- **Mañana (8-11 AM)**: Ideal para tareas que requieren concentración
- **Mediodía (12-2 PM)**: Bueno para tareas administrativas
- **Tarde (2-5 PM)**: Perfecto para reuniones y colaboración
- **Noche (6-8 PM)**: Ideal para ejercicio y actividades físicas

💡 **Tip**: Una vez que uses la app y registres tus actividades, podré darte horarios más específicos basados en tu productividad real.

¿Hay alguna actividad específica para la que necesitas sugerencias de horario?''';

      case QueryType.analytics:
        return '''¡Hola! Para analizar tu productividad, necesito que uses la app por un tiempo para recopilar datos.

📊 **Mientras tanto, puedes**:
- Registrar tus actividades diarias
- Marcar cuando completas tareas
- Anotar tus niveles de energía
- Identificar tus horarios más productivos

🎯 **Una vez que tengas datos**, podré ayudarte con:
- Análisis de patrones de productividad
- Identificación de horarios óptimos
- Recomendaciones personalizadas
- Estadísticas detalladas

¿Te gustaría que te explique cómo usar la app para recopilar estos datos?''';

      case QueryType.classification:
        return '''¡Hola! Para clasificar actividades, puedo ayudarte con estas categorías generales:

📚 **Estudio**: Lectura, investigación, cursos, tareas académicas
💼 **Trabajo**: Reuniones, proyectos, tareas laborales
💪 **Ejercicio**: Deportes, gimnasio, caminar, yoga
🧘 **Bienestar**: Meditación, relajación, cuidado personal
🎨 **Creatividad**: Arte, música, escritura, diseño
🏠 **Hogar**: Limpieza, cocina, organización
🎮 **Ocio**: Entretenimiento, juegos, tiempo libre

¿Qué actividad quieres clasificar? Una vez que uses la app más, podré hacer clasificaciones más precisas basadas en tus patrones.''';

      case QueryType.general:
      default:
        return '''¡Hola! Soy TempoSage AI, tu asistente de productividad inteligente. 

🤖 **Puedo ayudarte con**:
- Recomendaciones de actividades
- Sugerencias de horarios óptimos
- Análisis de productividad
- Clasificación de tareas
- Consejos de organización

📱 **Para obtener recomendaciones personalizadas**:
1. Usa la app regularmente
2. Registra tus actividades
3. Marca cuando completas tareas
4. Anota tus niveles de energía

Una vez que recopile datos de tus patrones, podré darte sugerencias mucho más específicas y útiles.

¿En qué puedo ayudarte hoy?''';
    }
  }
}

/// Tipos de consulta que puede procesar el sistema
enum QueryType {
  recommendation,
  scheduling,
  analytics,
  classification,
  general,
}
