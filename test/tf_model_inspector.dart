import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:temposage/core/utils/logger.dart';

/// Utilidad para inspeccionar y diagnosticar modelos TFLite
///
/// Esta herramienta analiza la estructura interna de un modelo TFLite
/// e imprime información detallada sobre sus tensores, operaciones y
/// metadatos para ayudar a identificar problemas de integración.
///
/// Ejecutar con: flutter run test/tf_model_inspector.dart
void main() async {
  // Inicializar Flutter para poder cargar assets
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar logger
  final logger = Logger('TF_MODEL_INSPECTOR');
  Logger.instance.setMinLevel(LogLevel.debug);
  Logger.instance.setVerboseMode(true);

  logger.i('🔍 Iniciando inspección del modelo TFLite...');

  try {
    // 1. Cargar el modelo desde los assets
    final modelPath = await _getModelFile('multitask_model_fp16.tflite');
    logger.i('📂 Archivo del modelo: ${modelPath.path}');

    // 2. Cargar el intérprete de TFLite
    logger.i('⏳ Cargando modelo en el intérprete...');
    final interpreter = Interpreter.fromFile(modelPath);
    logger.i('✅ Intérprete inicializado correctamente');

    // 3. Obtener y mostrar información del modelo
    _inspectInterpreter(interpreter, logger);

    // 4. Probar una inferencia mínima
    logger.i('🧪 Realizando inferencia de prueba...');
    _testInference(interpreter, logger);
  } catch (e, stackTrace) {
    logger.e('❌ Error al inspeccionar el modelo',
        error: e, stackTrace: stackTrace);
  }

  logger.i('🏁 Inspección completada');
}

/// Obtiene el archivo del modelo desde assets o almacenamiento local
Future<File> _getModelFile(String modelFileName) async {
  const String modelBasePath = 'ml_models/TPS_Model';

  try {
    final appDir = await getApplicationDocumentsDirectory();
    final modelFile = File('${appDir.path}/$modelFileName');

    if (await modelFile.exists()) {
      return modelFile;
    }

    // Copiar desde assets si no existe
    final modelData =
        await rootBundle.load('assets/$modelBasePath/$modelFileName');
    final bytes = modelData.buffer.asUint8List();
    await modelFile.writeAsBytes(bytes);

    return modelFile;
  } catch (e) {
    throw Exception('Error al obtener archivo del modelo: $e');
  }
}

/// Inspecciona y muestra información detallada del intérprete TFLite
void _inspectInterpreter(Interpreter interpreter, Logger logger) {
  try {
    // 1. Información de versión
    logger.i('📊 Información del modelo TFLite:');

    // 2. Tensores de entrada
    final inputTensors = interpreter.getInputTensors();
    logger.i('📥 Tensores de entrada (${inputTensors.length}):');

    for (int i = 0; i < inputTensors.length; i++) {
      final tensor = inputTensors[i];
      final shape = tensor.shape;
      final type = tensor.type;
      final name = tensor.name;

      logger.i('   - Tensor $i ($name):');
      logger.i('     * Forma: $shape (${shape.length}D)');
      logger.i('     * Tipo: $type');
    }

    // 3. Tensores de salida
    final outputTensors = interpreter.getOutputTensors();
    logger.i('📤 Tensores de salida (${outputTensors.length}):');

    for (int i = 0; i < outputTensors.length; i++) {
      final tensor = outputTensors[i];
      final shape = tensor.shape;
      final type = tensor.type;
      final name = tensor.name;

      logger.i('   - Tensor $i ($name):');
      logger.i('     * Forma: $shape (${shape.length}D)');
      logger.i('     * Tipo: $type');
    }

    // 4. Información de delegados si están disponibles
    try {
      logger.i('🧠 Delegados:');
      logger.i('   - Soporta GPU: ${_checkGpuDelegateSupport()}');
      logger.i('   - Soporta NNAPI: ${_checkNnapiSupport()}');
    } catch (e) {
      logger.w('   No se pudo determinar soporte de delegados: $e');
    }
  } catch (e, stackTrace) {
    logger.e('Error al inspeccionar intérprete',
        error: e, stackTrace: stackTrace);
  }
}

/// Realiza una inferencia de prueba mínima para verificar el modelo
void _testInference(Interpreter interpreter, Logger logger) {
  try {
    // Obtener información sobre formas de entrada/salida
    final inputTensors = interpreter.getInputTensors();
    final outputTensors = interpreter.getOutputTensors();

    // Preparar entradas y salidas mínimas basadas en las formas
    final inputs = <Object>[];
    final outputs = <int, Object>{};

    // Crear tensores de entrada con valores de prueba
    for (int i = 0; i < inputTensors.length; i++) {
      final shape = inputTensors[i].shape;

      if (shape.length == 2) {
        // Para entradas 2D tipo [batch_size, features]
        if (i == 0) {
          // Primera entrada (posiblemente texto/embedding)
          inputs.add(List.generate(
              shape[0],
              (_) => List<int>.filled(
                  shape[1], 1))); // Usar 1 como ID token genérico
        } else {
          // Entradas numéricas
          inputs.add(List.generate(
              shape[0],
              (_) => List<double>.filled(
                  shape[1], 0.5))); // Valores de 0.5 como prueba
        }
      } else if (shape.length == 1) {
        // Para entradas 1D
        inputs.add(List<double>.filled(shape[0], 0.5));
      } else {
        // Para dimensiones más altas (poco común en estos modelos)
        logger.w('Tensor de entrada con forma inusual: $shape');
        continue;
      }
    }

    // Preparar buffers de salida
    for (int i = 0; i < outputTensors.length; i++) {
      final shape = outputTensors[i].shape;

      if (shape.length == 2) {
        outputs[i] =
            List.generate(shape[0], (_) => List<double>.filled(shape[1], 0.0));
      } else if (shape.length == 1) {
        outputs[i] = List<double>.filled(shape[0], 0.0);
      } else {
        logger.w('Tensor de salida con forma inusual: $shape');
        outputs[i] = [];
      }
    }

    // Log de información pre-inferencia
    logger.d('Realizando inferencia de prueba con:');
    logger.d('Entradas: ${inputs.length} tensores');
    for (var input in inputs) {
      logger.d('  - ${input.runtimeType}');
    }

    // Ejecutar inferencia
    interpreter.runForMultipleInputs(inputs, outputs);

    // Mostrar resultados
    logger.i('✅ Inferencia de prueba completada con éxito');
    logger.d('Resultados:');
    outputs.forEach((key, value) {
      logger.d('  - Salida $key: $value');
    });
  } catch (e, stackTrace) {
    logger.e('Error al realizar inferencia de prueba',
        error: e, stackTrace: stackTrace);
  }
}

/// Verifica si el dispositivo soporta delegación a GPU
bool _checkGpuDelegateSupport() {
  try {
    // Esta es una verificación simplificada
    return Platform.isAndroid || Platform.isIOS;
  } catch (e) {
    return false;
  }
}

/// Verifica si el dispositivo soporta NNAPI
bool _checkNnapiSupport() {
  try {
    return Platform.isAndroid;
  } catch (e) {
    return false;
  }
}
