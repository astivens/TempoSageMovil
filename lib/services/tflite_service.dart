import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late final Interpreter _interpreter;
  late final List<String> _labels;

  /// Inicializa el intérprete y carga etiquetas.
  Future<void> init() async {
    // Cargar intérprete desde assets
    _interpreter = await Interpreter.fromAsset(
      'assets/ml_models/TPS_Model/multitask_model_fp16.tflite',
    );
    // Cargar etiquetas desde assets
    final rawLabels = await rootBundle.loadString(
      'assets/ml_models/TPS_Model/labels.txt',
    );
    _labels = rawLabels
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  List<String> get labels => _labels;

  /// Ejecuta inferencia multitarea.
  /// Retorna mapa con 'category', 'duration' y 'logits'.
  Future<Map<String, dynamic>> runInference({
    required String taskDescription,
    required double estimatedDuration,
    required double startHour,
    required double startWeekday,
    required List<double> oheValues,
  }) async {
    // 1) Buffer de texto (STRING)
    final textBytes = Uint8List.fromList(utf8.encode(taskDescription));
    // 2) Buffers numéricos (FLOAT32)
    final durationBuffer = Float32List.fromList([estimatedDuration]);
    final hourBuffer = Float32List.fromList([startHour]);
    final weekdayBuffer = Float32List.fromList([startWeekday]);
    // 3) Buffers OHE (uno por categoría)
    final oheBuffers = oheValues.map((v) => Float32List.fromList([v])).toList();
    // 4) Inputs en orden: texto, duración, hora, weekday, OHE...
    final inputs = <Object>[
      textBytes,
      durationBuffer.buffer,
      hourBuffer.buffer,
      weekdayBuffer.buffer,
      for (var buf in oheBuffers) buf.buffer,
    ];
    // 5) Preparar buffers de salida
    final numClasses = _labels.length;
    final logitsBuffer = Float32List(numClasses);
    final durationOutBuffer = Float32List(1);
    final outputs = <int, Object>{
      0: logitsBuffer,
      1: durationOutBuffer,
    };
    // 6) Ejecutar inferencia
    _interpreter.runForMultipleInputs(inputs, outputs);
    // 7) Interpretar resultados
    final logits = (outputs[0] as Float32List).toList();
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final index = logits.indexOf(maxLogit);
    final predictedCategory = _labels[index];
    final predictedDuration = (outputs[1] as Float32List)[0];
    return {
      'category': predictedCategory,
      'duration': predictedDuration,
      'logits': logits,
    };
  }

  /// Cierra el intérprete.
  void close() {
    _interpreter.close();
  }
}
