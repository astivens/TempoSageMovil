import 'package:flutter/foundation.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/utils/logger.dart';

/// Servicio para generar datos ficticios en modo debug
class DebugDataService {
  static final Logger _logger = Logger('DebugDataService');
  
  /// Genera datos ficticios de bloques productivos para testing (simulando app usada)
  static List<ProductiveBlock> generateFakeProductiveBlocks() {
    _logger.i('Generando datos ficticios de bloques productivos (simulando app usada)');
    
    final List<ProductiveBlock> fakeBlocks = [];
    
    // Datos ficticios más extensos para simular una app que ya ha sido usada
    final List<Map<String, dynamic>> fakeData = [
      // Lunes - Semana 1
      {'weekday': 0, 'hour': 8, 'completionRate': 0.82, 'category': 'Trabajo'},
      {'weekday': 0, 'hour': 9, 'completionRate': 0.88, 'category': 'Trabajo'},
      {'weekday': 0, 'hour': 10, 'completionRate': 0.85, 'category': 'Trabajo'},
      {'weekday': 0, 'hour': 14, 'completionRate': 0.78, 'category': 'Estudio'},
      {'weekday': 0, 'hour': 15, 'completionRate': 0.75, 'category': 'Estudio'},
      {'weekday': 0, 'hour': 16, 'completionRate': 0.90, 'category': 'Ejercicio'},
      {'weekday': 0, 'hour': 17, 'completionRate': 0.87, 'category': 'Ejercicio'},
      
      // Martes - Semana 1
      {'weekday': 1, 'hour': 8, 'completionRate': 0.80, 'category': 'Trabajo'},
      {'weekday': 1, 'hour': 9, 'completionRate': 0.85, 'category': 'Trabajo'},
      {'weekday': 1, 'hour': 13, 'completionRate': 0.70, 'category': 'Estudio'},
      {'weekday': 1, 'hour': 14, 'completionRate': 0.72, 'category': 'Estudio'},
      {'weekday': 1, 'hour': 18, 'completionRate': 0.95, 'category': 'Ejercicio'},
      {'weekday': 1, 'hour': 19, 'completionRate': 0.88, 'category': 'Ejercicio'},
      
      // Miércoles - Semana 1
      {'weekday': 2, 'hour': 9, 'completionRate': 0.90, 'category': 'Trabajo'},
      {'weekday': 2, 'hour': 10, 'completionRate': 0.88, 'category': 'Trabajo'},
      {'weekday': 2, 'hour': 11, 'completionRate': 0.85, 'category': 'Trabajo'},
      {'weekday': 2, 'hour': 15, 'completionRate': 0.82, 'category': 'Estudio'},
      {'weekday': 2, 'hour': 16, 'completionRate': 0.80, 'category': 'Estudio'},
      {'weekday': 2, 'hour': 17, 'completionRate': 0.78, 'category': 'Ejercicio'},
      {'weekday': 2, 'hour': 18, 'completionRate': 0.75, 'category': 'Ejercicio'},
      
      // Jueves - Semana 1
      {'weekday': 3, 'hour': 8, 'completionRate': 0.88, 'category': 'Trabajo'},
      {'weekday': 3, 'hour': 9, 'completionRate': 0.92, 'category': 'Trabajo'},
      {'weekday': 3, 'hour': 10, 'completionRate': 0.90, 'category': 'Trabajo'},
      {'weekday': 3, 'hour': 14, 'completionRate': 0.85, 'category': 'Estudio'},
      {'weekday': 3, 'hour': 15, 'completionRate': 0.88, 'category': 'Estudio'},
      {'weekday': 3, 'hour': 19, 'completionRate': 0.88, 'category': 'Ejercicio'},
      {'weekday': 3, 'hour': 20, 'completionRate': 0.85, 'category': 'Ejercicio'},
      
      // Viernes - Semana 1
      {'weekday': 4, 'hour': 8, 'completionRate': 0.75, 'category': 'Trabajo'},
      {'weekday': 4, 'hour': 9, 'completionRate': 0.80, 'category': 'Trabajo'},
      {'weekday': 4, 'hour': 13, 'completionRate': 0.90, 'category': 'Estudio'},
      {'weekday': 4, 'hour': 14, 'completionRate': 0.88, 'category': 'Estudio'},
      {'weekday': 4, 'hour': 16, 'completionRate': 0.85, 'category': 'Ejercicio'},
      {'weekday': 4, 'hour': 17, 'completionRate': 0.82, 'category': 'Ejercicio'},
      
      // Sábado - Semana 1
      {'weekday': 5, 'hour': 10, 'completionRate': 0.70, 'category': 'Ocio'},
      {'weekday': 5, 'hour': 11, 'completionRate': 0.65, 'category': 'Ocio'},
      {'weekday': 5, 'hour': 15, 'completionRate': 0.80, 'category': 'Ejercicio'},
      {'weekday': 5, 'hour': 16, 'completionRate': 0.75, 'category': 'Ejercicio'},
      {'weekday': 5, 'hour': 18, 'completionRate': 0.65, 'category': 'Ocio'},
      {'weekday': 5, 'hour': 19, 'completionRate': 0.60, 'category': 'Ocio'},
      
      // Domingo - Semana 1
      {'weekday': 6, 'hour': 11, 'completionRate': 0.60, 'category': 'Ocio'},
      {'weekday': 6, 'hour': 12, 'completionRate': 0.55, 'category': 'Ocio'},
      {'weekday': 6, 'hour': 16, 'completionRate': 0.75, 'category': 'Ejercicio'},
      {'weekday': 6, 'hour': 17, 'completionRate': 0.70, 'category': 'Ejercicio'},
      {'weekday': 6, 'hour': 19, 'completionRate': 0.55, 'category': 'Ocio'},
      {'weekday': 6, 'hour': 20, 'completionRate': 0.50, 'category': 'Ocio'},
      
      // Datos adicionales para simular más uso
      // Lunes - Semana 2
      {'weekday': 0, 'hour': 7, 'completionRate': 0.75, 'category': 'Trabajo'},
      {'weekday': 0, 'hour': 11, 'completionRate': 0.82, 'category': 'Trabajo'},
      {'weekday': 0, 'hour': 13, 'completionRate': 0.70, 'category': 'Estudio'},
      {'weekday': 0, 'hour': 18, 'completionRate': 0.85, 'category': 'Ejercicio'},
      
      // Martes - Semana 2
      {'weekday': 1, 'hour': 7, 'completionRate': 0.78, 'category': 'Trabajo'},
      {'weekday': 1, 'hour': 10, 'completionRate': 0.83, 'category': 'Trabajo'},
      {'weekday': 1, 'hour': 15, 'completionRate': 0.75, 'category': 'Estudio'},
      {'weekday': 1, 'hour': 17, 'completionRate': 0.90, 'category': 'Ejercicio'},
      
      // Miércoles - Semana 2
      {'weekday': 2, 'hour': 8, 'completionRate': 0.85, 'category': 'Trabajo'},
      {'weekday': 2, 'hour': 12, 'completionRate': 0.80, 'category': 'Estudio'},
      {'weekday': 2, 'hour': 14, 'completionRate': 0.78, 'category': 'Estudio'},
      {'weekday': 2, 'hour': 19, 'completionRate': 0.82, 'category': 'Ejercicio'},
      
      // Jueves - Semana 2
      {'weekday': 3, 'hour': 7, 'completionRate': 0.80, 'category': 'Trabajo'},
      {'weekday': 3, 'hour': 11, 'completionRate': 0.87, 'category': 'Trabajo'},
      {'weekday': 3, 'hour': 13, 'completionRate': 0.82, 'category': 'Estudio'},
      {'weekday': 3, 'hour': 18, 'completionRate': 0.90, 'category': 'Ejercicio'},
      
      // Viernes - Semana 2
      {'weekday': 4, 'hour': 7, 'completionRate': 0.72, 'category': 'Trabajo'},
      {'weekday': 4, 'hour': 10, 'completionRate': 0.78, 'category': 'Trabajo'},
      {'weekday': 4, 'hour': 12, 'completionRate': 0.85, 'category': 'Estudio'},
      {'weekday': 4, 'hour': 15, 'completionRate': 0.88, 'category': 'Estudio'},
      {'weekday': 4, 'hour': 18, 'completionRate': 0.80, 'category': 'Ejercicio'},
    ];
    
    for (final data in fakeData) {
      fakeBlocks.add(ProductiveBlock(
        weekday: data['weekday'] as int,
        hour: data['hour'] as int,
        completionRate: data['completionRate'] as double,
        isProductiveBlock: true,
        category: data['category'] as String,
      ));
    }
    
    _logger.i('Generados ${fakeBlocks.length} bloques ficticios');
    return fakeBlocks;
  }
  
  /// Genera recomendaciones ficticias para testing (simulando app usada)
  static List<Map<String, dynamic>> generateFakeRecommendations() {
    _logger.i('Generando recomendaciones ficticias (simulando app usada)');
    
    return [
      {
        'title': 'Sesión de trabajo matutina',
        'category': 'Trabajo',
        'score': 0.92,
        'description': 'Basado en 15+ sesiones exitosas, tu mejor momento para trabajo es entre 9-11 AM',
        'confidence': 0.95,
        'frequency': 'Diario',
        'successRate': '92%',
      },
      {
        'title': 'Estudio después del almuerzo',
        'category': 'Estudio',
        'score': 0.88,
        'description': 'Tienes alta productividad para estudiar entre 2-4 PM (promedio 85% completado)',
        'confidence': 0.88,
        'frequency': 'Lunes a Viernes',
        'successRate': '85%',
      },
      {
        'title': 'Ejercicio vespertino',
        'category': 'Ejercicio',
        'score': 0.90,
        'description': 'Tu energía es óptima para ejercicio entre 5-7 PM (completado 90% de las veces)',
        'confidence': 0.90,
        'frequency': 'Lunes, Miércoles, Viernes',
        'successRate': '90%',
      },
      {
        'title': 'Tiempo de ocio',
        'category': 'Ocio',
        'score': 0.75,
        'description': 'Los fines de semana son ideales para actividades de ocio (65% completado)',
        'confidence': 0.75,
        'frequency': 'Fines de semana',
        'successRate': '65%',
      },
      {
        'title': 'Trabajo temprano',
        'category': 'Trabajo',
        'score': 0.85,
        'description': 'Las primeras horas (8-9 AM) son muy productivas para tareas complejas',
        'confidence': 0.82,
        'frequency': 'Lunes a Jueves',
        'successRate': '85%',
      },
      {
        'title': 'Estudio nocturno',
        'category': 'Estudio',
        'score': 0.70,
        'description': 'Algunas noches (7-9 PM) son buenas para repaso y lectura',
        'confidence': 0.70,
        'frequency': 'Martes y Jueves',
        'successRate': '70%',
      },
    ];
  }
  
  /// Genera estadísticas ficticias de productividad (simulando app usada)
  static Map<String, dynamic> generateFakeProductivityStats() {
    _logger.i('Generando estadísticas ficticias de productividad (simulando app usada)');
    
    return {
      'totalBlocks': 65,
      'averageCompletionRate': 0.82,
      'mostProductiveDay': 'Jueves',
      'mostProductiveHour': 9,
      'totalSessions': 65,
      'totalHours': 195,
      'streakDays': 14,
      'categoryStats': {
        'Trabajo': {'count': 25, 'avgRate': 0.85, 'totalHours': 75, 'bestHour': 9},
        'Estudio': {'count': 20, 'avgRate': 0.80, 'totalHours': 60, 'bestHour': 14},
        'Ejercicio': {'count': 15, 'avgRate': 0.88, 'totalHours': 45, 'bestHour': 18},
        'Ocio': {'count': 5, 'avgRate': 0.65, 'totalHours': 15, 'bestHour': 19},
      },
      'weeklyTrend': [0.82, 0.85, 0.88, 0.92, 0.85, 0.70, 0.65],
      'monthlyProgress': {
        'week1': 0.78,
        'week2': 0.82,
        'week3': 0.85,
        'week4': 0.88,
      },
      'insights': [
        'Tu productividad ha mejorado 12% en las últimas 2 semanas',
        'Los jueves son tu día más productivo (92% completado)',
        'Trabajas mejor en las mañanas (9-11 AM)',
        'El ejercicio vespertino tiene 90% de éxito',
      ],
    };
  }
  
  /// Verifica si estamos en modo debug y si necesitamos datos ficticios
  static bool shouldUseFakeData() {
    return kDebugMode;
  }
  
  /// Inicializa datos ficticios si es necesario
  static Future<void> initializeFakeDataIfNeeded() async {
    if (!shouldUseFakeData()) {
      _logger.i('No en modo debug, saltando inicialización de datos ficticios');
      return;
    }
    
    _logger.i('Inicializando datos ficticios para modo debug');
    
    try {
      // Aquí podrías guardar los datos ficticios en Hive o donde sea necesario
      // Por ahora solo los generamos y los logueamos
      final fakeBlocks = generateFakeProductiveBlocks();
      final fakeRecommendations = generateFakeRecommendations();
      final fakeStats = generateFakeProductivityStats();
      
      _logger.i('Datos ficticios generados:');
      _logger.i('- Bloques: ${fakeBlocks.length}');
      _logger.i('- Recomendaciones: ${fakeRecommendations.length}');
      _logger.i('- Estadísticas: ${fakeStats.keys.length} categorías');
      
    } catch (e) {
      _logger.e('Error al inicializar datos ficticios: $e');
    }
  }
}
