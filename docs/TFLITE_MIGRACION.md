# Migración de API a TensorFlow Lite

## Resumen del cambio

La aplicación TempoSage ha migrado del uso de una API externa para las funcionalidades de recomendación y predicción a una implementación local utilizando TensorFlow Lite (TFLite). Este documento explica los cambios realizados y sus beneficios.

## Motivación

La migración de API externa a TensorFlow Lite se realizó por los siguientes motivos:

1. **Privacidad mejorada**: Los datos del usuario se procesan localmente en el dispositivo en lugar de enviarse a un servidor externo.
2. **Funcionamiento sin conexión**: La aplicación puede proporcionar recomendaciones y predicciones incluso cuando no hay conexión a internet.
3. **Mejora del rendimiento**: Se reduce la latencia al eliminar las solicitudes de red.
4. **Reducción de costos**: No se requiere infraestructura de servidor para el procesamiento de datos.
5. **Simplificación del mantenimiento**: Eliminación de la dependencia de un backend que necesita ser gestionado y actualizado.

## Cambios implementados

### 1. Archivos afectados

- **Deshabilitados (marcados como deprecated):**
  - `lib/core/services/tempo_sage_api_service.dart`
  
- **Actualizados:**
  - `lib/features/dashboard/controllers/dashboard_controller.dart`
  - `lib/services/recommendation_service.dart`
  - `lib/core/services/recommendation_service.dart`

### 2. Implementación local de funcionalidades

Las siguientes funcionalidades ahora se ejecutan localmente:

- **Predicción de logro de metas** (`predictGoalAchievement`)
  - Implementación basada en reglas que analiza patrones de actividades y hábitos completados.
  - Genera recomendaciones personalizadas basadas en palabras clave de la meta.

- **Predicción de energía y burnout** (`predictEnergyLevels`)
  - Análisis de actividades recientes para estimar niveles de energía.
  - Identificación de patrones de trabajo intenso y hábitos relacionados con bienestar.
  - Generación de recomendaciones específicas según el nivel de riesgo.

- **Recomendación de hábitos** (`recommendHabits`)
  - Base de conocimiento de hábitos predefinidos para distintas categorías.
  - Análisis del texto de las metas para seleccionar categorías relevantes.
  - Recomendaciones filtradas para evitar duplicados con hábitos existentes.

### 3. Modelos TensorFlow Lite

La aplicación ahora incluye modelos TFLite para:
- Recomendación de actividades (TiSASRec)
- Predicción de productividad
- Análisis de patrones temporales

Estos modelos están almacenados en `assets/ml_models/tisasrec/` y se cargan dinámicamente según se necesitan.

## Guía de mantenimiento

### Actualización de modelos TFLite

Para actualizar los modelos:

1. Reemplazar los archivos `.tflite` en `assets/ml_models/tisasrec/`
2. Actualizar los archivos de metadatos correspondientes
3. Asegurar que las rutas están correctamente configuradas en `pubspec.yaml`

### Ajuste de lógica de recomendación

Los algoritmos basados en reglas pueden ajustarse en:
- `lib/features/dashboard/controllers/dashboard_controller.dart` (predicciones generales)
- `lib/services/recommendation_service.dart` (lógica basada en reglas)

## Próximos pasos

1. **Completar la migración**: Eliminar completamente el código relacionado con la API.
2. **Mejorar modelos locales**: Entrenar modelos TFLite específicos para cada funcionalidad.
3. **Optimización**: Ajustar el rendimiento de la inferencia en dispositivos móviles.
4. **Actualización de UI**: Reflejar la naturaleza local de las recomendaciones en la interfaz.

## Consideraciones adicionales

La migración a TensorFlow Lite puede presentar algunas limitaciones en la capacidad de análisis comparada con una API potente. Sin embargo, los beneficios de privacidad, funcionamiento sin conexión y rendimiento superan estas limitaciones para la mayoría de los usuarios. 