 # Guía para la Extensión de la API de TempoSage (Nuevas Funcionalidades de ML)

Esta guía describe nuevas funcionalidades y endpoints que podrían añadirse a la API de Machine Learning de TempoSage para expandir sus capacidades de asistencia inteligente. Estas propuestas se basan en las funcionalidades existentes y buscan ofrecer un mayor valor al usuario.

## Información General (Extensión)

- **URL Base**: (Se mantendría la misma, ej. `http://localhost:5000` para desarrollo local, o la URL de producción)
- **Formato de datos**: JSON (Consistente con la API actual)
- **Autenticación**: (Se mantendría el esquema de autenticación existente o se implementaría si aún no existe)

## Nuevos Endpoints Disponibles

A continuación, se detallan las nuevas propuestas de endpoints:

### 1. Predicción y Optimización de Metas a Largo Plazo

Permite a los usuarios definir metas a largo plazo. La API analiza la viabilidad, sugiere un plan de trabajo y predice la probabilidad de éxito.

```
POST /predict/goal_achievement
```

**Cuerpo de la solicitud:**
```json
{
  "goal_description": "Completar curso de Flutter avanzado",
  "target_deadline": "2024-12-31T23:59:59Z",
  "current_activities": [
    {
      "startTime": "2023-11-20T09:00:00Z",
      "endTime": "2023-11-20T11:00:00Z",
      "category": "Estudio",
      "isCompleted": true
    }
    // ... más actividades recientes ...
  ],
  "current_habits": [
    {
      "category": "Lectura Técnica",
      "date": "2023-11-20",
      "completed": true
    }
    // ... más hábitos recientes ...
  ]
}
```

**Respuesta:**
```json
{
  "goal_viability_score": 0.75,
  "suggested_plan": [
    {"task": "Módulo 1: Widgets Avanzados", "estimated_weeks": 2, "priority": "alta"},
    {"task": "Módulo 2: Gestión de Estado Avanzada", "estimated_weeks": 3, "priority": "alta"},
    {"task": "Proyecto Final", "estimated_weeks": 4, "priority": "media"}
  ],
  "milestones": [
    {"milestone": "Completar Módulo 1", "suggested_date": "2024-09-15T23:59:59Z"},
    {"milestone": "Completar Módulo 2", "suggested_date": "2024-10-30T23:59:59Z"}
  ],
  "success_probability": 0.68,
  "recommendations": [
    "Dedicar al menos 5 horas semanales a 'Estudio'.",
    "Establecer un hábito de 'Revisión Semanal del Progreso'."
  ]
}
```

### 2. Detección de Niveles de Energía y Riesgo de Agotamiento (Burnout)

Predice los niveles de energía del usuario y detecta posibles riesgos de agotamiento basándose en su actividad y hábitos.

```
POST /predict/energy_levels
```

**Cuerpo de la solicitud:**
```json
{
  "activities_history": [
    {"startTime": "2023-11-19T08:00:00Z", "endTime": "2023-11-19T18:00:00Z", "category": "Trabajo", "isCompleted": true},
    {"startTime": "2023-11-20T09:00:00Z", "endTime": "2023-11-20T19:30:00Z", "category": "Trabajo", "isCompleted": true}
    // ... historial de actividades de los últimos N días ...
  ],
  "habits_history": [
    {"category": "Sueño", "date": "2023-11-19", "completed": true, "duration_hours": 6.5},
    {"category": "Ejercicio", "date": "2023-11-20", "completed": false}
    // ... historial de hábitos de los últimos N días ...
  ],
  "self_assessment": {
    "stress_level": 4, // Escala 1-5 (opcional)
    "sleep_quality": "regular" // ej. buena, regular, mala (opcional)
  }
}
```

**Respuesta:**
```json
{
  "predicted_energy_today": "bajo",
  "predicted_energy_tomorrow": "bajo",
  "burnout_risk_level": "moderado",
  "explanation": "Patrones de trabajo intensos recientes con disminución en el completado de hábitos de 'Descanso' y horas de sueño reducidas.",
  "recommendations": [
    "Considerar tomar un descanso de 30 minutos esta tarde.",
    "Priorizar el hábito de 'Sueño' esta noche, apuntando a 7-8 horas.",
    "Evaluar posponer tareas no críticas para mañana."
  ]
}
```

### 3. Sugerencias de Hábitos Personalizados y Contextuales

Sugiere nuevos hábitos que se alineen con los objetivos del usuario o que podrían mejorar su productividad y bienestar general.

```
POST /recommend/habits
```

**Cuerpo de la solicitud:**
```json
{
  "user_goals": [
    "Mejorar concentración durante el estudio",
    "Reducir estrés laboral"
  ],
  "current_activities_pattern": [
    { "category": "Estudio", "avg_hours_day": 4, "peak_time": "mañana" },
    { "category": "Trabajo", "avg_hours_day": 5, "peak_time": "tarde" }
  ],
  "existing_habits": [
    {"name": "Ejercicio Matutino", "category": "Salud", "frequency": "3 veces/semana"},
    {"name": "Leer antes de dormir", "category": "Personal", "frequency": "Diario"}
  ]
}
```

**Respuesta:**
```json
{
  "suggested_habits": [
    {
      "habit_name": "Técnica Pomodoro para Estudio",
      "category": "Productividad",
      "justification": "Ayuda a mantener la concentración durante bloques de estudio. Alineado con tu objetivo de 'Mejorar concentración'.",
      "suggested_frequency": "Durante sesiones de estudio",
      "details": "Trabajar 25 min, descanso 5 min."
    },
    {
      "habit_name": "Meditación Corta (10 min) post-trabajo",
      "category": "Bienestar",
      "justification": "Contribuye a la reducción del estrés laboral y facilita la desconexión.",
      "suggested_frequency": "Diario (días laborales)",
      "details": "Meditación guiada o de atención plena."
    }
  ]
}
```

### 4. Análisis del Impacto de Hábitos en la Productividad

Analiza la correlación entre la realización de ciertos hábitos y los niveles de productividad o la tasa de finalización de tareas del usuario.

```
POST /analyze/habit_impact
```

**Cuerpo de la solicitud:**
```json
{
  "habits_completion_data": [
    { "habit_name": "Ejercicio Matutino", "date": "2023-11-15", "completed": true },
    { "habit_name": "Meditación Corta", "date": "2023-11-15", "completed": false }
    // ... más datos históricos (últimos 30-90 días recomendados) ...
  ],
  "activities_completion_data": [
    { "category": "Trabajo", "date": "2023-11-15", "tasks_completed": 5, "tasks_total": 7, "subjective_productivity_score": 8}, // Score 1-10
    { "category": "Estudio", "date": "2023-11-15", "tasks_completed": 1, "tasks_total": 2, "subjective_productivity_score": 7}
    // ... más datos históricos ...
  ],
  "time_period_days": 30
}
```

**Respuesta:**
```json
{
  "impact_analysis": [
    {
      "habit_name": "Ejercicio Matutino",
      "correlation_description": "Positiva Fuerte",
      "finding": "Los días que realizaste 'Ejercicio Matutino', tu productividad subjetiva en 'Trabajo' fue en promedio un 20% más alta y completaste un 15% más de tareas.",
      "confidence_level": 0.85,
      "data_points_analyzed": 22
    },
    {
      "habit_name": "Meditación Corta",
      "correlation_description": "Positiva Débil",
      "finding": "Se observa una ligera tendencia a mayor finalización de tareas de 'Estudio' los días con 'Meditación Corta', pero se requieren más datos.",
      "confidence_level": 0.60,
      "data_points_analyzed": 10
    }
  ],
  "overall_summary": "El 'Ejercicio Matutino' parece ser un hábito clave para tu rendimiento laboral. Considera mantenerlo consistentemente."
}
```

### 5. Generación Automática de Resúmenes y Reflexiones Semanales/Mensuales

Genera un resumen de los logros, patrones de trabajo, áreas de mejora y preguntas de reflexión personalizadas.

```
GET /generate/summary_reflection?period={period_value}&user_id={user_id_value}
```
*(Parámetros de Query: `period` puede ser `last_week` o `last_month`)*

**Respuesta:**
```json
{
  "period_start_date": "2023-11-01",
  "period_end_date": "2023-11-30",
  "summary": {
    "total_activities_completed": 120,
    "most_productive_category": "Trabajo",
    "time_spent_by_category": [
        {"category": "Trabajo", "hours": 80},
        {"category": "Estudio", "hours": 40},
        {"category": "Personal", "hours": 20}
    ],
    "habit_consistency": [
      { "habit_name": "Ejercicio Matutino", "completion_rate": 0.85 },
      { "habit_name": "Lectura Diaria", "completion_rate": 0.95 }
    ],
    "achievements": [
      "Finalización del reporte trimestral.",
      "Avance del 50% en el curso de Python."
    ]
  },
  "reflection_prompts": [
    "¿Cuál fue tu mayor logro este mes y cómo te hizo sentir?",
    "¿Qué hábito tuvo el mayor impacto positivo en tu bienestar o productividad?",
    "¿Identificas algún ladrón de tiempo o distracción recurrente? ¿Cómo podrías mitigarlo?",
    "De cara al próximo mes, ¿cuál es tu principal prioridad o enfoque?"
  ],
  "suggestions_for_next_period": [
    "Considera bloquear tiempo para 'Descanso Activo' después de sesiones largas de 'Trabajo'.",
    "Intenta definir objetivos más pequeños y medibles para tu meta de 'Estudio'."
  ]
}
```

### 6. Estimación Inteligente de Duración de Tareas

Ofrece una estimación de cuánto tiempo podría llevar completar una nueva tarea, basándose en el historial del usuario o datos agregados.

```
POST /estimate/task_duration
```

**Cuerpo de la solicitud:**
```json
{
  "task_title": "Investigar y redactar borrador para artículo de blog sobre IA",
  "category": "Trabajo Creativo",
  "description": "Longitud aproximada 1500 palabras. Incluir 3-4 fuentes académicas. Tono divulgativo.",
  "user_id": "user123", // Para personalización
  "data_preference": "hybrid" // 'personal', 'global_anonymous', 'hybrid'
}
```

**Respuesta:**
```json
{
  "estimated_duration_min_hours": 3.0,
  "estimated_duration_max_hours": 5.5,
  "confidence_level": 0.78,
  "explanation": "Estimación basada en tareas previas de 'Trabajo Creativo' con descripciones similares y datos anónimos de tareas de redacción. La investigación de fuentes puede variar el tiempo.",
  "breakdown_suggestion": [ // Opcional
      {"sub_task": "Investigación de fuentes", "estimated_hours": 1.5},
      {"sub_task": "Esquema y estructura", "estimated_hours": 0.5},
      {"sub_task": "Redacción del borrador", "estimated_hours": 2.5},
      {"sub_task": "Revisión inicial", "estimated_hours": 0.5}
  ]
}
```

---

Esta guía es una propuesta y los detalles exactos (como los campos específicos en JSON o la lógica interna) requerirían un diseño más profundo y consideración de los datos disponibles y los modelos de ML a desarrollar.
