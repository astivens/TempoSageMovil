import 'package:flutter/material.dart';
import 'package:temposage/core/utils/logger.dart';
import 'package:temposage/core/services/ml_model_adapter.dart';

/// Script de prueba mejorado para verificar la integración de modelos ML
/// usando el nuevo adaptador de modelo que se ajusta dinámicamente.
///
/// Ejecutar con: flutter run test/ml_test_adapter.dart
void main() async {
  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar logger
  final logger = Logger('ML_TEST_AVANZADO');
  Logger.instance.setMinLevel(LogLevel.debug);
  Logger.instance.setVerboseMode(true);

  logger.i('⚡ Iniciando pruebas avanzadas de integración ML...');

  // Crear y configurar el adaptador
  final adapter = MlModelAdapter();

  try {
    // Inicializar el adaptador con el modelo
    logger.i('⚙️ Inicializando adaptador de modelos ML...');
    bool success = await adapter.initialize('multitask_model_fp16.tflite');

    if (!success) {
      logger.e('❌ Error al inicializar el adaptador de modelos');
      return;
    }

    logger.i('✅ Adaptador de modelos inicializado correctamente');
    logger.i('📊 Información del modelo: ${adapter.modelInfo}');

    // Lista de tareas de prueba con diferentes características
    final testTasks = [
      {
        'descripcion': 'Preparar informe de ventas trimestral',
        'duracion': 90.0,
        'categoria_esperada': 'Trabajo'
      },
      {
        'descripcion': 'Estudiar para el examen de matemáticas',
        'duracion': 120.0,
        'categoria_esperada': 'Estudio'
      },
      {
        'descripcion': 'Hacer ejercicio en el gimnasio',
        'duracion': 60.0,
        'categoria_esperada': 'Salud'
      },
      {
        'descripcion': 'Limpiar la casa y organizar el garaje',
        'duracion': 180.0,
        'categoria_esperada': 'Hogar'
      },
      {
        'descripcion': 'Programar la aplicación móvil para el cliente',
        'duracion': 240.0,
        'categoria_esperada': 'Trabajo'
      }
    ];

    // Ejecutar pruebas para cada tarea
    for (final task in testTasks) {
      final description = task['descripcion'] as String;
      final expectedDuration = task['duracion'] as double;

      logger.i('🔍 Analizando tarea: "$description"');

      try {
        // Ejecutar inferencia con el adaptador
        final results = await adapter.runInference(
          text: description,
          estimatedDuration: expectedDuration,
          // Opcional: timeOfDay y dayOfWeek se tomarán de DateTime.now()
        );

        // Mostrar resultados
        final categoryIndex = results['categoryIndex'] as int?;
        final duration = results['duration'] as double?;

        logger.i('📈 Resultados de inferencia:');
        logger
            .i('   - Índice de categoría detectado: ${categoryIndex ?? "N/A"}');
        logger.i(
            '   - Duración estimada: ${duration?.toStringAsFixed(1) ?? "N/A"} min');

        // Verificar si los resultados son razonables
        if (categoryIndex != null) {
          logger.i('✅ Se obtuvo un índice de categoría válido');
        } else {
          logger.w('⚠️ No se pudo determinar la categoría');
        }

        if (duration != null) {
          final duracionRazonable = duration > 0 && duration < 1000;
          final mensaje = duracionRazonable
              ? '✅ Duración estimada razonable'
              : '⚠️ Duración estimada fuera de rango normal';
          logger.i(mensaje);
        } else {
          logger.w('⚠️ No se pudo estimar la duración');
        }
      } catch (e, stackTrace) {
        logger.e('❌ Error al procesar tarea: "$description"',
            error: e, stackTrace: stackTrace);
      }

      logger.i('-----------------------------------');
    }
  } catch (e, stackTrace) {
    logger.e('❌ Error general en las pruebas',
        error: e, stackTrace: stackTrace);
  } finally {
    // Liberar recursos
    adapter.dispose();
    logger.i('🏁 Pruebas completadas');
  }
}
