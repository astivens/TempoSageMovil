# Guía para consumir la API de TempoSage

Esta guía explica cómo interactuar con la API de Machine Learning de TempoSage para obtener predicciones de productividad, sugerencias de horarios y análisis de patrones.

## Información general

- **URL Base**: http://localhost:5000 (desarrollo local)
- **Formato de datos**: JSON
- **Autenticación**: No implementada en esta versión

## Endpoints disponibles

### 1. Verificación de estado

Verifica si la API está funcionando correctamente.

```
GET /health
```

**Respuesta:**
```json
{
  "status": "ok",
  "message": "API is running"
}
```

### 2. Predicción de productividad

#### Modelo estándar

```
POST /predict/productivity
```

#### Modelo mejorado (recomendado)

```
POST /predict/productivity/enhanced
```

**Cuerpo de la solicitud:**
```json
{
  "activities": [
    {
      "startTime": "2023-05-10T10:00:00Z",
      "endTime": "2023-05-10T12:00:00Z",
      "category": "Programación",
      "isCompleted": true
    },
    {
      "startTime": "2023-05-10T14:00:00Z",
      "endTime": "2023-05-10T15:00:00Z",
      "category": "Reuniones",
      "isCompleted": false
    }
  ],
  "habits": [
    {
      "category": "Sueño",
      "date": "2023-05-10",
      "completed": true
    },
    {
      "category": "Ejercicio",
      "date": "2023-05-10",
      "completed": false
    }
  ],
  "target_date": "2023-05-10T16:00:00Z"
}
```

**Respuesta:**
```json
{
  "prediction": 7.5,
  "explanation": "productividad alta basada en tasa de completado de actividades recientes, hora de tarde",
  "model_type": "enhanced"
}
```

### 3. Sugerencia de horarios óptimos

```
POST /predict/optimal_time
```

**Cuerpo de la solicitud:**
```json
{
  "activity_category": "Programación",
  "past_activities": [
    {
      "startTime": "2023-05-01T09:00:00Z",
      "endTime": "2023-05-01T11:00:00Z",
      "category": "Programación",
      "isCompleted": true
    },
    {
      "startTime": "2023-05-02T10:00:00Z",
      "endTime": "2023-05-02T12:00:00Z",
      "category": "Programación",
      "isCompleted": true
    }
  ],
  "target_date": "2023-05-10T00:00:00Z"
}
```

**Respuesta:**
```json
{
  "suggestions": [
    {
      "start_time": "2023-05-10T10:00:00Z",
      "end_time": "2023-05-10T12:00:00Z",
      "confidence": 0.85
    },
    {
      "start_time": "2023-05-10T15:00:00Z",
      "end_time": "2023-05-10T17:00:00Z",
      "confidence": 0.72
    }
  ],
  "explanation": "Sugerencias basadas en patrones históricos de productividad para actividades de Programación"
}
```

### 4. Análisis de patrones

```
POST /analyze/patterns
```

**Cuerpo de la solicitud:**
```json
{
  "activities": [
    {
      "startTime": "2023-05-01T09:00:00Z",
      "endTime": "2023-05-01T11:00:00Z",
      "category": "Programación",
      "isCompleted": true
    },
    {
      "startTime": "2023-05-02T14:00:00Z",
      "endTime": "2023-05-02T16:00:00Z",
      "category": "Reuniones",
      "isCompleted": false
    }
  ],
  "time_period": 30
}
```

**Respuesta:**
```json
{
  "patterns": [
    {
      "category": "Programación",
      "completion_rate": 0.8,
      "preferred_time": "morning",
      "days_of_week": ["Monday", "Wednesday"]
    },
    {
      "category": "Reuniones",
      "completion_rate": 0.6,
      "preferred_time": "afternoon",
      "days_of_week": ["Tuesday", "Thursday"]
    }
  ],
  "explanation": "Análisis basado en 30 días de actividades"
}
```

## Ejemplos de uso

### Python

```python
import requests
import json

# URL base
base_url = "http://localhost:5000"

# Datos de ejemplo
data = {
  "activities": [
    {
      "startTime": "2023-05-10T10:00:00Z",
      "endTime": "2023-05-10T12:00:00Z",
      "category": "Programación",
      "isCompleted": True
    },
    {
      "startTime": "2023-05-10T14:00:00Z",
      "endTime": "2023-05-10T15:00:00Z",
      "category": "Reuniones",
      "isCompleted": False
    }
  ],
  "habits": [
    {
      "category": "Sueño",
      "date": "2023-05-10",
      "completed": True
    },
    {
      "category": "Ejercicio",
      "date": "2023-05-10",
      "completed": False
    }
  ],
  "target_date": "2023-05-10T16:00:00Z"
}

# Hacer la solicitud
response = requests.post(
    f"{base_url}/predict/productivity/enhanced",
    json=data
)

# Verificar y procesar la respuesta
if response.status_code == 200:
    result = response.json()
    print(f"Predicción: {result['prediction']}")
    print(f"Explicación: {result['explanation']}")
else:
    print(f"Error: {response.text}")
```

### JavaScript

```javascript
async function getPrediction() {
  const baseUrl = "http://localhost:5000";
  
  const data = {
    activities: [
      {
        startTime: "2023-05-10T10:00:00Z",
        endTime: "2023-05-10T12:00:00Z",
        category: "Programación",
        isCompleted: true
      },
      {
        startTime: "2023-05-10T14:00:00Z",
        endTime: "2023-05-10T15:00:00Z",
        category: "Reuniones",
        isCompleted: false
      }
    ],
    habits: [
      {
        category: "Sueño",
        date: "2023-05-10",
        completed: true
      },
      {
        category: "Ejercicio",
        date: "2023-05-10",
        completed: false
      }
    ],
    target_date: "2023-05-10T16:00:00Z"
  };
  
  try {
    const response = await fetch(`${baseUrl}/predict/productivity/enhanced`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });
    
    if (response.ok) {
      const result = await response.json();
      console.log(`Predicción: ${result.prediction}`);
      console.log(`Explicación: ${result.explanation}`);
    } else {
      console.error(`Error: ${await response.text()}`);
    }
  } catch (error) {
    console.error("Error en la solicitud:", error);
  }
}
```

### cURL

```bash
curl -X POST http://localhost:5000/predict/productivity/enhanced \
  -H "Content-Type: application/json" \
  -d '{
    "activities": [
      {"startTime": "2023-05-10T10:00:00Z", "endTime": "2023-05-10T12:00:00Z", "category": "Programación", "isCompleted": true},
      {"startTime": "2023-05-10T14:00:00Z", "endTime": "2023-05-10T15:00:00Z", "category": "Reuniones", "isCompleted": false}
    ],
    "habits": [
      {"category": "Sueño", "date": "2023-05-10", "completed": true},
      {"category": "Ejercicio", "date": "2023-05-10", "completed": false}
    ],
    "target_date": "2023-05-10T16:00:00Z"
  }'
```

## Consideraciones importantes

1. **Formato de fechas**: Todas las fechas deben estar en formato ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)
2. **Categorías recomendadas** para actividades:
   - Trabajo, Estudio, Ejercicio, Lectura, Meditación, Programación, Reuniones, Correo electrónico, Planificación, Tareas domésticas, Ocio, Social, Creatividad, Descanso
3. **Categorías recomendadas** para hábitos:
   - Sueño, Alimentación, Ejercicio, Agua, Meditación, Lectura, Aprendizaje, Descansos, Socialización
4. **Manejo de errores**: La API retorna códigos HTTP 400 para datos faltantes o incorrectos y 500 para errores internos

Para más detalles sobre la implementación del modelo y su entrenamiento, consulte README.md. 