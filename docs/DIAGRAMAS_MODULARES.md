# Diagramas Modulares - TempoSage

Este documento explica la estructura modular de los diagramas del proyecto TempoSage. Los diagramas grandes han sido divididos en módulos más pequeños y legibles para facilitar su comprensión.

## Estructura Modular

### Diagramas de Casos de Uso

El diagrama principal de casos de uso ha sido dividido en **4 módulos funcionales**:

#### 1. **Autenticación** (`use_case_diagram_authentication.puml`)
- **Enfoque:** Módulo de autenticación y gestión de usuarios
- **Casos de uso:**
  - Registrar Usuario
  - Iniciar Sesión
  - Cerrar Sesión
- **Actores:** Usuario, Base de Datos Local
- **Tamaño:** 1000×800

#### 2. **Gestión de Entidades** (`use_case_diagram_management.puml`)
- **Enfoque:** Módulo de gestión de actividades, hábitos y time blocks
- **Casos de uso:**
  - Gestión de Actividades (crear, editar, completar, cancelar, listar)
  - Gestión de Hábitos (crear, editar, eliminar, completar, ver estadísticas)
  - Gestión de Time Blocks (crear, editar, ver calendario)
- **Actores:** Usuario, Base de Datos Local
- **Tamaño:** 1400×1000

#### 3. **Dashboard y Análisis** (`use_case_diagram_dashboard.puml`)
- **Enfoque:** Módulo de visualización y análisis
- **Casos de uso:**
  - Ver Dashboard
  - Analizar Productividad
  - Ver Progreso de Metas
  - Exportar/Importar Datos
  - Sincronizar con Calendario
- **Actores:** Usuario, Base de Datos Local
- **Tamaño:** 1000×800

#### 4. **Inteligencia Artificial** (`use_case_diagram_ai.puml`)
- **Enfoque:** Módulo de recomendaciones y análisis con IA
- **Casos de uso:**
  - Obtener Recomendaciones
  - Sugerir Tiempo Óptimo
  - Predecir Productividad
  - Generar Bloques Automáticos
- **Actores:** Usuario, Sistema de IA
- **Tamaño:** 1000×800

### Diagramas de Clases

El diagrama principal de clases ha sido dividido en **3 módulos por capa**:

#### 1. **Core y Domain** (`class_diagram_core_domain.puml`)
- **Enfoque:** Capas Core y Domain de la arquitectura
- **Contenido:**
  - Core Layer: LocalStorage, ServiceLocator, Logger
  - Domain Layer: Entidades (Activity, Habit, TimeBlock)
  - Abstracciones de Repositorios
  - Use Cases principales
- **Tamaño:** 1200×1000

#### 2. **Data Layer** (`class_diagram_data_layer.puml`)
- **Enfoque:** Capa de datos e implementaciones
- **Contenido:**
  - Modelos de datos (HabitModel, ActivityModel, TimeBlockModel)
  - Implementaciones de Repositorios
  - Transformaciones entre modelos y entidades
  - Referencias a abstracciones del dominio
- **Tamaño:** 1200×1000

#### 3. **Presentation y Services** (`class_diagram_presentation_services.puml`)
- **Enfoque:** Capas de presentación y servicios
- **Contenido:**
  - Presentation Layer: HabitCubit, DashboardController, HabitState
  - Services Layer: RecommendationService, TempoSageApiService, NotificationService
  - Referencias a Domain y Core
- **Tamaño:** 1200×1000

### Diagramas Entidad-Relación

El diagrama principal ER ha sido dividido en **2 módulos**:

#### 1. **Entidades Principales** (`entity_relationship_diagram_core_entities.puml`)
- **Enfoque:** Entidades core del dominio
- **Contenido:**
  - User (entidad central)
  - Habit, Activity, Task (entidades del dominio)
  - TimeBlock, Subtask (entidades de datos)
  - Relaciones principales entre entidades core
- **Tamaño:** 1400×1000

#### 2. **Configuración y Análisis** (`entity_relationship_diagram_config_analytics.puml`)
- **Enfoque:** Entidades de configuración y analytics
- **Contenido:**
  - Settings, Notification, Category (configuración)
  - ProductivityMetric, UserInteraction (analytics)
  - Goal (metas)
  - Relaciones con User y otras entidades
- **Tamaño:** 1400×1000

## Diagramas Originales

Los diagramas originales completos se mantienen para referencia:

- `use_case_diagram.puml` - Diagrama completo de casos de uso
- `class_diagram.puml` - Diagrama completo de clases
- `entity_relationship_diagram.puml` - Diagrama ER completo

## Ventajas de la Modularización

✅ **Mayor Legibilidad:** Cada módulo es más pequeño y fácil de entender
✅ **Enfoque Específico:** Cada diagrama se centra en un aspecto particular
✅ **Mejor Mantenibilidad:** Cambios en un módulo no afectan otros
✅ **Fácil Navegación:** Los módulos pueden estudiarse independientemente
✅ **Documentación Clara:** Cada módulo tiene un propósito específico

## Recomendaciones de Uso

### Para Desarrollo
- Usar diagramas modulares para entender módulos específicos
- Consultar diagramas completos para visión general

### Para Documentación
- Incluir diagramas modulares en documentación específica
- Usar diagramas completos para visión arquitectónica general

### Para Presentaciones
- Usar módulos individuales en slides específicos
- Mostrar diagrama completo al inicio para contexto

## Exportación

Todos los diagramas se exportan automáticamente con:
- **Formato SVG** (vectorial, recomendado)
- **Formato PNG** (300 DPI, alta resolución)
- **Fuentes grandes** (13-14px para mejor legibilidad)
- **Canvas optimizado** (tamaños manejables)

## Estructura de Archivos

```
docs/diagrams/
├── use_case_diagram.puml (completo)
├── use_case_diagram_authentication.puml (módulo)
├── use_case_diagram_management.puml (módulo)
├── use_case_diagram_dashboard.puml (módulo)
├── use_case_diagram_ai.puml (módulo)
├── class_diagram.puml (completo)
├── class_diagram_core_domain.puml (módulo)
├── class_diagram_data_layer.puml (módulo)
├── class_diagram_presentation_services.puml (módulo)
├── entity_relationship_diagram.puml (completo)
├── entity_relationship_diagram_core_entities.puml (módulo)
└── entity_relationship_diagram_config_analytics.puml (módulo)
```

## Actualización de Diagramas

Para actualizar todos los diagramas (incluyendo módulos):

```bash
./scripts/export_diagrams_high_quality.sh
```

Este script:
- ✅ Limpia imágenes anteriores automáticamente
- ✅ Exporta todos los diagramas (completos y modulares)
- ✅ Genera formatos SVG, PNG y PDF
- ✅ Usa configuración de alta calidad (300 DPI)

