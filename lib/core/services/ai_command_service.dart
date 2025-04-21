import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AICommandService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey;

  AICommandService({required String apiKey}) : _apiKey = apiKey;

  Future<Map<String, dynamic>> processCommand(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''Eres un asistente que ayuda a interpretar comandos de voz para una aplicación de gestión de tareas y tiempo.
              Tu trabajo es analizar el texto y extraer la intención y los parámetros relevantes.
              
              Los tipos de comandos posibles son:
              1. createActivity - Crear una nueva actividad
              2. createTimeBlock - Crear un nuevo bloque de tiempo
              3. markComplete - Marcar una actividad como completada
              4. delete - Eliminar una actividad o bloque
              5. navigate - Navegar a una sección de la app
              
              Las categorías disponibles son:
              - trabajo
              - personal
              - estudio
              - ejercicio
              - reunión
              - descanso
              
              Debes responder en formato JSON con la siguiente estructura:
              {
                "type": "tipo_de_comando",
                "parameters": {
                  "title": "título si aplica",
                  "category": "categoría si se menciona",
                  "time": "hora o fecha si se menciona",
                  "destination": "destino si es navigate"
                }
              }'''
            },
            {
              'role': 'user',
              'content': text,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        debugPrint('Error en la API: ${response.statusCode}');
        throw Exception('Error al procesar el comando');
      }
    } catch (e) {
      debugPrint('Error al procesar el comando: $e');
      return {
        'type': 'unknown',
        'parameters': {'error': e.toString()}
      };
    }
  }

  String getHelpText() {
    return '''
Puedes usar comandos como:
- "Crear una actividad reunión con el equipo para mañana en la categoría trabajo"
- "Necesito programar un bloque de ejercicio para las 7 de la mañana"
- "Marcar como completada la tarea reunión con el equipo"
- "Eliminar la actividad ejercicio de hoy"
- "Mostrar mi calendario"
- "Ir a la lista de actividades"

También puedes usar lenguaje natural, por ejemplo:
- "Tengo que estudiar para el examen mañana"
- "Quiero hacer ejercicio todos los días a las 6"
- "Ya terminé la reunión con el cliente"
- "Muéstrame mis tareas pendientes"
''';
  }
}
