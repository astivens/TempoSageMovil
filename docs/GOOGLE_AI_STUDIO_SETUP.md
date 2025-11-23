# Configuración de Google AI Studio para TempoSage

## Pasos para configurar Google AI Studio

### 1. Obtener API Key

1. Ve a [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Inicia sesión con tu cuenta de Google
3. Haz clic en "Create API Key"
4. Copia la API key generada

### 2. Configurar la API Key

#### Opción A: Variable de entorno (Recomendado para producción)

```bash
export GOOGLE_AI_API_KEY="tu_api_key_aqui"
```

#### Opción B: Modificar directamente el código

Edita el archivo `lib/core/config/ai_config.dart`:

```dart
static const String googleAIAPIKey = 'tu_api_key_real_aqui';
```

### 3. Verificar la configuración

La aplicación verificará automáticamente si la API key está configurada correctamente. Si no está configurada, mostrará un mensaje de advertencia.

### 4. Características disponibles

- **Chat con IA**: Conversación natural con Gemini Pro
- **Contexto ML**: Integración con datos de machine learning locales
- **Manejo de errores**: Gestión robusta de errores de API
- **Historial de conversación**: Mantiene el contexto durante la sesión

### 5. Modelos disponibles

- `gemini-pro`: Modelo principal recomendado
- `gemini-pro-vision`: Para contenido con imágenes (futuro)

### 6. Configuración avanzada

Puedes modificar los parámetros de generación en `AIConfig`:

```dart
static const double defaultTemperature = 0.7;  // Creatividad (0.0 - 1.0)
static const int defaultTopK = 40;             // Diversidad de respuestas
static const double defaultTopP = 0.95;        // Nucleus sampling
static const int defaultMaxOutputTokens = 1024; // Longitud máxima
```

### 7. Solución de problemas

#### Error: "API Key inválida"
- Verifica que la API key sea correcta
- Asegúrate de que la API key tenga permisos para Gemini API

#### Error: "Cuota excedida"
- Verifica tu cuota en Google AI Studio
- Considera actualizar tu plan si es necesario

#### Error: "Contenido bloqueado"
- El filtro de seguridad de Google bloqueó la respuesta
- Reformula tu pregunta de manera más apropiada

### 8. Desarrollo sin API Key

Si no tienes una API key configurada, la aplicación funcionará en modo de desarrollo con mensajes informativos.

### 9. Seguridad

- **Nunca** commits tu API key al repositorio
- Usa variables de entorno para producción
- Considera usar un servicio de gestión de secretos para aplicaciones grandes

### 10. Próximos pasos

1. Configura tu API key
2. Ejecuta `flutter pub get` para instalar las dependencias
3. Prueba la funcionalidad de chat en la aplicación
4. Personaliza los parámetros según tus necesidades
