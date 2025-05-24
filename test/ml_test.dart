import 'package:flutter/material.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/core/utils/logger.dart';
import 'package:intl/intl.dart';

/// Script de prueba para verificar el funcionamiento del modelo ML
/// Ejecutar con: flutter run test/ml_test.dart
void main() async {
  // Asegurarnos de que Flutter esté inicializado para cargar assets
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar nivel de log para ver más detalles
  final logger = Logger('ML_TEST');
  Logger.instance.setMinLevel(LogLevel.debug);
  Logger.instance.setVerboseMode(true);

  logger.i('⚡ Iniciando prueba de integración ML...');

  // Inicializar el servicio que contiene la integración ML
  logger.i('⚙️ Inicializando servicio de recomendaciones...');

  final recommendationService = RecommendationService();

  try {
    // Inicializar el servicio
    await recommendationService.initialize();
    logger.i('✅ Servicio de recomendaciones inicializado correctamente');

    // Lista de tareas de prueba con diferentes características
    final testTasks = [
      "Preparar informe de ventas trimestral para la reunión del viernes",
      "Estudiar para el examen de matemáticas",
      "Hacer ejercicio en el gimnasio durante una hora",
      "Limpiar la casa antes de que lleguen los invitados",
      "Programar la aplicación móvil para el cliente nuevo"
    ];

    // Ejecutar predicciones para cada tarea de prueba
    for (final taskDescription in testTasks) {
      logger.i('🔍 Probando tarea: "$taskDescription"');

      try {
        // Obtener predicción
        final prediction = await recommendationService.predictTaskDetails(
          description: taskDescription,
          estimatedDuration: 60.0,
        );

        // Mostrar resultados
        logger.i('📊 Resultado:');
        logger.i('   - Categoría: ${prediction.category}');
        logger.i('   - Duración estimada: ${prediction.estimatedDuration} min');

        if (prediction.suggestedDateTime != null) {
          final formatter = DateFormat('E, HH:mm');
          logger.i(
              '   - Hora sugerida: ${formatter.format(prediction.suggestedDateTime!)}');
        } else {
          logger.i('   - No hay hora sugerida disponible');
        }

        // Verificar si se usó fallback
        if (prediction.category == 'Desconocida') {
          logger.w('⚠️ Parece que se utilizó la lógica de fallback');
        } else {
          logger.i('✅ Predicción generada por el modelo ML');

          // Información adicional sobre los bloques sugeridos
          if (prediction.suggestedBlocks.isNotEmpty) {
            logger.i('📋 Bloques productivos sugeridos:');
            for (final block in prediction.suggestedBlocks) {
              logger.i('   - ${block.toString()}');
            }
          } else {
            logger.w('⚠️ No se encontraron bloques productivos sugeridos');
          }
        }
      } catch (e, stackTrace) {
        logger.e('❌ Error al procesar tarea: "$taskDescription"',
            error: e, stackTrace: stackTrace);
      }
    }
  } catch (e, stackTrace) {
    logger.e('❌ Error en la prueba de integración ML',
        error: e, stackTrace: stackTrace);
  } finally {
    logger.i('🏁 Prueba completada');
    logger.i('🧹 Recursos liberados');
  }
}
