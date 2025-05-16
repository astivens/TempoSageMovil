import 'dart:math' as math;
// import 'package:flutter/foundation.dart'; // No es estrictamente necesario para List.generate

import '../data/models/interaction_event.dart'; // Importar el modelo

// Asumimos que estos serían cargados desde JSON o configuración
const int DEFAULT_MAX_LEN = 50;
const int DEFAULT_TIME_SPAN = 256;
// Ejemplo de mapeo de item IDs (original a entero)
// Map<String, int> itemGlobalMapping = {"itemA": 1, "itemB": 2, ...};
// Ejemplo de configuración de preprocesamiento de tiempo (si es necesaria una normalización global)
// final int globalTimeMin = 1678886400; // Ejemplo de timestamp mínimo global

class TisasrecPreprocessor {
  final int maxlen;
  final int timeSpan;
  final Map<String, int> itemMapping; // Mapeo de itemId original a intId
  // Podrías añadir aquí más configuraciones si son necesarias para el preprocesamiento de tiempo,
  // ej. globalTimeMin, si la normalización de timestamps lo requiere.

  TisasrecPreprocessor({
    required this.itemMapping,
    this.maxlen = DEFAULT_MAX_LEN,
    this.timeSpan = DEFAULT_TIME_SPAN,
  });

  /// Prepara los datos de entrada para el modelo TFLite TiSASRec.
  /// Devuelve una lista de objetos que representan los tensores de entrada.
  /// El orden y la forma de estos objetos DEBEN coincidir con la firma del modelo TFLite.
  List<Object> preprocessInput(
    List<InteractionEvent> userInteractionHistory,
    // Opcional: si el modelo TFLite toma los IDs de los candidatos directamente.
    // List<String> candidateItemOriginalIds
  ) {
    if (userInteractionHistory.isEmpty) {
      // Decide cómo manejar esto: ¿error, o devolver tensores vacíos/padding?
      // Por ahora, lanzamos un error, ya que el modelo espera secuencias.
      throw ArgumentError(
          "La lista del historial de interacciones del usuario no puede estar vacía.");
    }

    // 1. Tomar las últimas `maxlen` interacciones.
    // La secuencia se construye de más antigua a más reciente, pero el padding va al principio.
    List<InteractionEvent> sequenceEvents = userInteractionHistory.length >
            maxlen
        ? userInteractionHistory.sublist(userInteractionHistory.length - maxlen)
        : userInteractionHistory;

    // 2. Crear input_seq (IDs de ítems enteros) y la base para processed_time_seq.
    List<int> inputSeq = List<int>.filled(maxlen, 0, growable: false);
    List<int> rawTimestampsForProcessing =
        List<int>.filled(maxlen, 0, growable: false);

    int startIdx = maxlen - sequenceEvents.length;
    for (int i = 0; i < sequenceEvents.length; i++) {
      InteractionEvent event = sequenceEvents[i];
      inputSeq[startIdx + i] =
          itemMapping[event.itemId] ?? 0; // 0 para ítems desconocidos/padding
      rawTimestampsForProcessing[startIdx + i] = event.timestamp;
    }

    // 3. Procesar los timestamps para obtener `processedTimeSeq`
    // Esta es la implementación de la normalización de timestamps por usuario como en `util.py`
    List<int> processedTimeSeq = _normalizeTimestampsForSequence(
        rawTimestampsForProcessing, sequenceEvents.length);

    // 4. Calcular `timeMatrix` usando `processedTimeSeq`
    List<List<int>> timeMatrix = _computeTimeMatrix(processedTimeSeq, timeSpan);

    // Formatear las entradas para el intérprete TFLite.
    // Usualmente se requiere una dimensión de batch (incluso si es 1).
    // input_seq: [1, maxlen]
    // time_matrix: [1, maxlen, maxlen]
    // La estructura exacta (ej. List<List<List<int>>> vs List<ByteBuffer>) dependerá del plugin TFLite.
    // Este es un formato común.
    final inputs = [
      [inputSeq], // Tensor para input_seq
      [timeMatrix], // Tensor para time_matrix
    ];

    // Si tu modelo TFLite fue exportado para tomar IDs de ítems candidatos directamente:
    // List<int> candidateIntIds = candidateItemOriginalIds
    //    .map((id) => itemMapping[id] ?? 0)
    //    .toList();
    // inputs.add([candidateIntIds]); // Añadir como otro tensor de entrada

    return inputs;
  }

  List<int> _normalizeTimestampsForSequence(
      List<int> rawTimestampsFilled, int numEffectiveEvents) {
    // Esta función DEBE replicar la lógica de `util.py` (parte de `cleanAndsort`)
    // para normalizar y escalar timestamps para la secuencia de entrada dada.
    // `rawTimestampsFilled` es de tamaño `maxlen` y puede tener padding (0s) al principio.
    // `numEffectiveEvents` es el número de eventos reales (no padding) en la secuencia.

    if (numEffectiveEvents == 0)
      return List<int>.filled(maxlen, 0, growable: false);

    // Extraer solo los timestamps efectivos (no padding)
    List<int> effectiveTimestamps =
        rawTimestampsFilled.sublist(maxlen - numEffectiveEvents);

    if (effectiveTimestamps.isEmpty ||
        effectiveTimestamps.every((t) => t == 0)) {
      return List<int>.filled(maxlen, 0, growable: false);
    }

    int timeMinUser = effectiveTimestamps.where((t) => t > 0).reduce(math.min);

    List<int> timeDiffs = [];
    List<int> sortedUserTimestamps =
        List<int>.from(effectiveTimestamps.where((t) => t > 0))..sort();

    for (int i = 0; i < sortedUserTimestamps.length - 1; i++) {
      int diff = sortedUserTimestamps[i + 1] - sortedUserTimestamps[i];
      if (diff != 0) {
        timeDiffs.add(diff
            .abs()); // Usar abs, aunque los timestamps deberían ser crecientes
      }
    }

    int timeScale = 1;
    if (timeDiffs.isNotEmpty) {
      timeScale = timeDiffs.reduce(math.min);
      if (timeScale == 0) timeScale = 1;
    }

    List<int> normalizedTimeSeq = List<int>.filled(maxlen, 0, growable: false);
    int writeIdx = maxlen - numEffectiveEvents;

    for (int i = 0; i < effectiveTimestamps.length; i++) {
      if (effectiveTimestamps[i] > 0) {
        // Solo procesar timestamps no acolchados
        normalizedTimeSeq[writeIdx + i] =
            ((effectiveTimestamps[i] - timeMinUser) / timeScale).round() + 1;
      } else {
        normalizedTimeSeq[writeIdx + i] = 0; // Mantener padding como 0
      }
    }
    return normalizedTimeSeq;
  }

  List<List<int>> _computeTimeMatrix(
      List<int> normalizedTimeSeq, int timeSpanLimit) {
    int size = normalizedTimeSeq.length; // Debería ser maxlen
    List<List<int>> timeMatrix = List.generate(
        size, (_) => List<int>.filled(size, 0, growable: false),
        growable: false);

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (normalizedTimeSeq[i] == 0 || normalizedTimeSeq[j] == 0) {
          // Si alguno de los timestamps es padding (0), la diferencia de tiempo es 0 (o un valor de padding específico)
          timeMatrix[i][j] = 0;
        } else {
          int span = (normalizedTimeSeq[i] - normalizedTimeSeq[j]).abs();
          if (span > timeSpanLimit) {
            timeMatrix[i][j] = timeSpanLimit;
          } else {
            timeMatrix[i][j] = span;
          }
        }
      }
    }
    return timeMatrix;
  }
}
