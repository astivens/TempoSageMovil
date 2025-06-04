# Chat con IA

Esta característica permite a los usuarios interactuar con un asistente basado en IA que puede proporcionar información y recomendaciones basadas en los datos del modelo de aprendizaje automático de la aplicación.

## Componentes principales

1. **GoogleAIService**: Servicio que se comunica con la API de Google AI Studio (Gemini).
2. **MLDataProcessor**: Procesa datos de los modelos de ML para proporcionar contexto al chat.
3. **ChatAIController**: Gestiona el estado y las operaciones del chat.
4. **ChatAIPage**: Interfaz de usuario para interactuar con el asistente de IA.

## Cómo funciona

1. El servicio de IA carga automáticamente datos de contexto del procesador ML.
2. El usuario puede hacer preguntas sobre sus actividades, hábitos y recomendaciones.
3. El asistente responde basándose en los datos proporcionados como contexto y en su conocimiento general.

## Configuración

Para utilizar esta característica, se necesita una clave API de Google AI Studio:

1. Obtén una clave API de Google AI Studio (Gemini API).
2. Ejecuta la aplicación con la clave API:
   ```
   ./run_with_api_key.sh TU_CLAVE_API
   ```

## Consideraciones futuras

- Implementar caché de respuestas para mejorar el rendimiento.
- Añadir capacidades de procesamiento de lenguaje natural más avanzadas.
- Integrar con más fuentes de datos para proporcionar recomendaciones más precisas. 