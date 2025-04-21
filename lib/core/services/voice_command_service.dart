import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

enum VoiceCommandType {
  createActivity,
  createTimeBlock,
  markComplete,
  delete,
  navigate,
  unknown
}

class VoiceCommand {
  final VoiceCommandType type;
  final Map<String, dynamic> parameters;

  VoiceCommand({
    required this.type,
    required this.parameters,
  });

  factory VoiceCommand.fromAIResponse(Map<String, dynamic> response) {
    final type = _parseCommandType(response['type']);
    return VoiceCommand(
      type: type,
      parameters: response['parameters'] ?? {},
    );
  }

  static VoiceCommandType _parseCommandType(String type) {
    switch (type.toLowerCase()) {
      case 'createactivity':
        return VoiceCommandType.createActivity;
      case 'createtimeblock':
        return VoiceCommandType.createTimeBlock;
      case 'markcomplete':
        return VoiceCommandType.markComplete;
      case 'delete':
        return VoiceCommandType.delete;
      case 'navigate':
        return VoiceCommandType.navigate;
      default:
        return VoiceCommandType.unknown;
    }
  }
}

class VoiceCommandService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Function(String)? onPartialResult;
  Function(VoiceCommand)? onCommandRecognized;
  Function(bool)? onListeningStateChanged;
  Function(String)? onError;

  Future<void> initialize() async {
    _isInitialized = await _speechToText.initialize(
      onError: (error) => onError?.call(error.errorMsg),
      onStatus: (status) {
        if (status == 'done') {
          onListeningStateChanged?.call(false);
        }
      },
    );
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      onError?.call('No se pudo inicializar el reconocimiento de voz');
      return;
    }

    onListeningStateChanged?.call(true);

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'es_ES',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    onListeningStateChanged?.call(false);
  }

  void _onSpeechResult(dynamic result) {
    if (result.finalResult) {
      final command = _parseCommand(result.recognizedWords);
      onCommandRecognized?.call(command);
    } else {
      onPartialResult?.call(result.recognizedWords);
    }
  }

  VoiceCommand _parseCommand(String text) {
    text = text.toLowerCase().trim();
    debugPrint('Procesando comando: $text');

    // Comandos para crear actividad
    if (text.contains('crea') ||
        text.contains('crear') ||
        text.contains('nueva') ||
        text.contains('agregar') ||
        text.contains('añadir')) {
      if (text.contains('actividad') ||
          text.contains('tarea') ||
          text.contains('evento') ||
          text.contains('reunión')) {
        final title = _extractTitle(text);
        final category = _extractCategory(text);
        debugPrint(
            'Comando reconocido: Crear actividad - Título: $title, Categoría: $category');
        return VoiceCommand(
          type: VoiceCommandType.createActivity,
          parameters: {
            'title': title,
            'category': category,
          },
        );
      }
    }

    // Comandos para crear bloque de tiempo
    if (text.contains('crea') ||
        text.contains('crear') ||
        text.contains('programar') ||
        text.contains('agendar') ||
        text.contains('planificar') ||
        text.contains('bloque') ||
        text.contains('tiempo') ||
        text.contains('hora') ||
        text.contains('evento')) {
      final title = _extractTitle(text);
      final category = _extractCategory(text);
      final time = _extractTime(text);
      debugPrint(
          'Comando reconocido: Crear bloque - Título: $title, Categoría: $category, Tiempo: $time');
      return VoiceCommand(
        type: VoiceCommandType.createTimeBlock,
        parameters: {
          'title': title,
          'category': category,
          'time': time,
        },
      );
    }

    // Comandos para marcar como completado
    if (text.contains('completar') ||
        text.contains('marcar') ||
        text.contains('terminar') ||
        text.contains('hecho') ||
        text.contains('listo')) {
      if (text.contains('complet') ||
          text.contains('listo') ||
          text.contains('terminado') ||
          text.contains('hecho')) {
        final title = _extractTitle(text);
        debugPrint(
            'Comando reconocido: Marcar como completado - Título: $title');
        return VoiceCommand(
          type: VoiceCommandType.markComplete,
          parameters: {
            'title': title,
          },
        );
      }
    }

    // Comandos para eliminar
    if (text.contains('eliminar') ||
        text.contains('borrar') ||
        text.contains('quitar') ||
        text.contains('remover') ||
        text.contains('cancelar')) {
      final title = _extractTitle(text);
      debugPrint('Comando reconocido: Eliminar - Título: $title');
      return VoiceCommand(
        type: VoiceCommandType.delete,
        parameters: {
          'title': title,
        },
      );
    }

    // Comandos de navegación
    if (text.contains('ir') ||
        text.contains('mostrar') ||
        text.contains('ver') ||
        text.contains('abrir') ||
        text.contains('navegar')) {
      final destination = _extractDestination(text);
      debugPrint('Comando reconocido: Navegar - Destino: $destination');
      return VoiceCommand(
        type: VoiceCommandType.navigate,
        parameters: {
          'destination': destination,
        },
      );
    }

    debugPrint('Comando no reconocido');
    return VoiceCommand(
      type: VoiceCommandType.unknown,
      parameters: {},
    );
  }

  String _extractTitle(String text) {
    // Extraer el título después de palabras clave
    final keywords = [
      'llamada',
      'llamado',
      'titulada',
      'titulado',
      'nombre',
      'con nombre',
      'para',
      'de',
      'sobre',
      'a',
      'desde'
    ];

    for (var keyword in keywords) {
      if (text.contains(keyword)) {
        final parts = text.split(keyword);
        if (parts.length > 1) {
          // Eliminar cualquier referencia a tiempo al final
          String title = parts[1].trim();
          if (title.contains('de') || title.contains('a')) {
            title = title.split(RegExp(r'(de|a)'))[0].trim();
          }
          return title;
        }
      }
    }

    // Si no encuentra palabras clave, intenta extraer después de "para"
    if (text.contains('para')) {
      final parts = text.split('para');
      if (parts.length > 1) {
        String title = parts[1].trim();
        if (title.contains('de') || title.contains('a')) {
          title = title.split(RegExp(r'(de|a)'))[0].trim();
        }
        return title;
      }
    }

    // Si no encuentra ninguna palabra clave, devuelve el texto completo
    return text;
  }

  String _extractCategory(String text) {
    final categories = {
      'trabajo': 'work',
      'personal': 'personal',
      'estudio': 'study',
      'reunión': 'meeting',
      'descanso': 'break',
      'comida': 'lunch',
      'ejercicio': 'exercise',
      'ocio': 'leisure',
      'familia': 'family'
    };

    for (var entry in categories.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'general';
  }

  String _extractTime(String text) {
    // Buscar patrones de tiempo como "de X a Y"
    final timePattern = RegExp(r'de\s+(\d+)\s+a\s+(\d+)');
    final match = timePattern.firstMatch(text);

    if (match != null) {
      final startHour = int.parse(match.group(1)!);
      final endHour = int.parse(match.group(2)!);
      return '$startHour-$endHour';
    }

    // Buscar referencias a partes del día
    if (text.contains('mañana')) return 'morning';
    if (text.contains('tarde')) return 'afternoon';
    if (text.contains('noche')) return 'evening';
    if (text.contains('ahora')) return 'now';

    return 'now';
  }

  String _extractDestination(String text) {
    if (text.contains('actividad') ||
        text.contains('tarea') ||
        text.contains('tareas')) {
      return 'activities';
    }
    if (text.contains('calendario') || text.contains('agenda')) {
      return 'calendar';
    }
    if (text.contains('bloque') ||
        text.contains('tiempo') ||
        text.contains('horario')) {
      return 'timeblocks';
    }
    if (text.contains('inicio') ||
        text.contains('principal') ||
        text.contains('dashboard')) {
      return 'dashboard';
    }
    return 'unknown';
  }

  String getHelpText() {
    return '''
Ejemplos de comandos:
- "Crear actividad llamada Reunión de equipo"
- "Crear bloque de tiempo para Estudiar de 2 a 4"
- "Marcar como completada la tarea X"
- "Eliminar la actividad Y"
- "Ir a actividades"
- "Mostrar calendario"
''';
  }
}
