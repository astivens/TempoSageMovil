# Plan de Mejora de Cobertura - 21% → 30%+

## 📊 Análisis de Líneas Sin Cubrir

### Top 10 Archivos con Más Líneas Sin Cubrir

| Archivo | Líneas Sin Cubrir | Prioridad | Tipo |
|---------|-------------------|-----------|------|
| `dashboard_controller.dart` | 300 | 🔴 CRÍTICA | Controlador |
| `habit_to_timeblock_service.dart` | 188 | 🔴 CRÍTICA | Servicio Dominio |
| `recommendation_service.dart` | 168 | 🟡 ALTA | Servicio Core |
| `ml_model_adapter.dart` | 162 | 🟡 ALTA | Servicio Core |
| `notification_service.dart` | 154 | 🟡 ALTA | Servicio Core |
| `activity_repository.dart` | 131 | 🔴 CRÍTICA | Repositorio |
| `habit_repository_impl.dart` | 112 | 🔴 CRÍTICA | Repositorio |
| `activity_recommendation_controller.dart` | 110 | 🟡 MEDIA | Controlador |
| `csv_service.dart` | 105 | 🟡 MEDIA | Servicio Core |
| `time_block_repository.dart` | 105 | 🔴 CRÍTICA | Repositorio |

**Total de líneas sin cubrir en top 10: 1,535 líneas**

## 🎯 Estrategia de Mejora

### Fase 1: Archivos Críticos (Objetivo: +5-7% cobertura)

#### 1. DashboardController (300 líneas)
- **Estado actual**: Tests básicos existentes
- **Acción**: Ampliar tests para cubrir todos los métodos
- **Tests necesarios**: 25-30 pruebas adicionales
- **Impacto estimado**: +2-3% cobertura

#### 2. HabitToTimeBlockService (188 líneas)
- **Estado actual**: Sin tests
- **Acción**: Crear suite completa de tests
- **Tests necesarios**: 20-25 pruebas
- **Impacto estimado**: +1-2% cobertura

#### 3. ActivityRepository (131 líneas)
- **Estado actual**: Tests básicos existentes
- **Acción**: Ampliar tests para casos edge y sincronización
- **Tests necesarios**: 15-20 pruebas adicionales
- **Impacto estimado**: +1-2% cobertura

#### 4. HabitRepository (112 líneas)
- **Estado actual**: Tests básicos existentes
- **Acción**: Ampliar tests para casos edge
- **Tests necesarios**: 15-20 pruebas adicionales
- **Impacto estimado**: +1% cobertura

#### 5. TimeBlockRepository (105 líneas)
- **Estado actual**: Tests básicos existentes
- **Acción**: Ampliar tests para métodos faltantes
- **Tests necesarios**: 10-15 pruebas adicionales
- **Impacto estimado**: +1% cobertura

**Total Fase 1**: +6-9% cobertura → **27-30% cobertura total**

### Fase 2: Servicios Core (Objetivo: +3-4% cobertura)

#### 6. RecommendationService (168 líneas)
- **Estado actual**: Tests básicos existentes
- **Acción**: Ampliar tests para algoritmos de recomendación
- **Tests necesarios**: 15-20 pruebas adicionales

#### 7. MLModelAdapter (162 líneas)
- **Estado actual**: Tests básicos existentes
- **Acción**: Ampliar tests para adaptación de modelos
- **Tests necesarios**: 15-20 pruebas adicionales

#### 8. NotificationService (154 líneas)
- **Estado actual**: Sin tests unitarios (solo integración)
- **Acción**: Crear suite completa de tests unitarios
- **Tests necesarios**: 20-25 pruebas

**Total Fase 2**: +3-4% cobertura → **30-34% cobertura total**

## 📝 Plan de Implementación

### Prioridad 1 (Esta semana)
1. ✅ HabitToTimeBlockService - Crear tests completos
2. ✅ DashboardController - Ampliar tests existentes
3. ✅ ActivityRepository - Ampliar tests existentes

### Prioridad 2 (Próxima semana)
4. HabitRepository - Ampliar tests existentes
5. TimeBlockRepository - Ampliar tests existentes
6. NotificationService - Crear tests unitarios

### Prioridad 3 (Siguiente semana)
7. RecommendationService - Ampliar tests existentes
8. MLModelAdapter - Ampliar tests existentes
9. ActivityRecommendationController - Crear tests

## 🎯 Objetivo Final

- **Cobertura actual**: 21%
- **Objetivo Fase 1**: 27-30%
- **Objetivo Fase 2**: 30-34%
- **Objetivo Final**: 50%+ (a largo plazo)

## 📈 Métricas de Seguimiento

- Líneas cubiertas por archivo
- Porcentaje de cobertura por módulo
- Tests creados por sprint
- Tiempo de ejecución de tests

