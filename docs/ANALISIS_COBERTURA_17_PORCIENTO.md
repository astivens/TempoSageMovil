# Análisis de Cobertura - 17%

## 📊 Situación Actual

- **Cobertura total:** 17.0%
- **Líneas de código:** 22,215 (directorio `lib`)
- **Archivos Dart:** 170 archivos
- **Tests unitarios:** 23 archivos de test
- **Pruebas estimadas implementadas:** ~42 pruebas
- **Potencial de pruebas:** 352-447 pruebas

## 🎯 Análisis por Módulo

### ✅ **Áreas con Cobertura (Prioridad Media)**

#### 1. **Modelos de Datos** - Parcialmente cubierto
- ✅ `ProductiveBlock` - Cubierto (42 pruebas)
- ✅ `UserModel` - Cubierto
- ✅ `UserContext` - Cubierto
- ✅ `HabitModel` - Parcialmente cubierto
- ✅ `ActivityModel` - Parcialmente cubierto
- ❌ `TimeBlockModel` - **SIN COBERTURA**
- ❌ Otros modelos - **SIN COBERTURA**

#### 2. **Utilidades y Helpers** - Parcialmente cubierto
- ✅ `DateTimeHelper` - Cubierto
- ✅ `DateTimeUtils` - Cubierto
- ✅ `FormValidators` - Parcialmente cubierto
- ❌ `StringSimilarity` - **SIN COBERTURA**
- ❌ `ErrorHandler` - **SIN COBERTURA**
- ❌ `Logger` - **SIN COBERTURA**
- ❌ `DateFormatter` - **SIN COBERTURA**

#### 3. **Servicios Core** - Parcialmente cubierto
- ✅ `AuthService` - Cubierto
- ✅ `RecommendationService` - Cubierto
- ✅ `HabitRecommendationService` - Cubierto
- ✅ `ScheduleRuleService` - Cubierto
- ✅ `CSVService` - Cubierto
- ✅ `EventBus` - Cubierto
- ✅ `MigrationService` - Cubierto
- ✅ `MLModelAdapter` - Cubierto
- ❌ `NotificationService` - **SIN COBERTURA**
- ❌ `LocalStorage` - **SIN COBERTURA**
- ❌ `NavigationService` - **SIN COBERTURA**
- ❌ `AICmdService` - **SIN COBERTURA**
- ❌ `OllamaAIService` - **SIN COBERTURA**
- ❌ `MLAIIntegrationService` - **SIN COBERTURA**

### ❌ **Áreas SIN Cobertura (Alta Prioridad)**

#### 1. **Repositorios** - CRÍTICO
- ❌ `ActivityRepository` - **0% cobertura**
- ❌ `HabitRepository` - **0% cobertura**
- ❌ `TimeBlockRepository` - Parcialmente cubierto
- ❌ Otros repositorios - **0% cobertura**

**Impacto:** Los repositorios son críticos para la persistencia de datos. Sin tests, no hay garantía de que los datos se guarden/carguen correctamente.

#### 2. **Casos de Uso (Use Cases)** - CRÍTICO
- ❌ `SuggestOptimalTimeUseCase` - **0% cobertura**
- ❌ `GetActivitiesUseCase` - **0% cobertura**
- ❌ Otros casos de uso - **0% cobertura**

**Impacto:** Los casos de uso contienen la lógica de negocio principal. Sin tests, no hay validación de la funcionalidad core.

#### 3. **Servicios de Dominio** - ALTA PRIORIDAD
- ❌ `ActivityToTimeBlockService` - **0% cobertura**
- ❌ `ActivityNotificationService` - **0% cobertura**
- ❌ `HabitToTimeBlockService` - **0% cobertura**
- ❌ `HabitNotificationService` - **0% cobertura**

**Impacto:** Estos servicios orquestan la lógica entre diferentes módulos. Son críticos para la funcionalidad.

#### 4. **Controladores/Cubits** - MEDIA PRIORIDAD
- ❌ `HabitCubit` - **0% cobertura**
- ❌ `TaskCubit` - **0% cobertura**
- ✅ `DashboardController` - Parcialmente cubierto
- ✅ `ActivityRecommendationController` - Parcialmente cubierto

**Impacto:** Los controladores manejan el estado de la UI. Sin tests, es difícil garantizar que el estado se maneje correctamente.

#### 5. **Widgets y UI** - BAJA PRIORIDAD
- ✅ `AccessibleCard` - Parcialmente cubierto
- ❌ Resto de widgets - **0% cobertura**

**Impacto:** Los widgets son importantes para la UI, pero menos críticos que la lógica de negocio.

## 🎯 Plan de Acción Recomendado

### **Fase 1: Crítico (Aumentar cobertura a 30%)**

1. **Repositorios** (Prioridad: 🔴 CRÍTICA)
   - `ActivityRepository` - 20-25 pruebas
   - `HabitRepository` - 20-25 pruebas
   - `TimeBlockRepository` - Completar cobertura
   - **Impacto estimado:** +5-7% cobertura

2. **Casos de Uso** (Prioridad: 🔴 CRÍTICA)
   - `SuggestOptimalTimeUseCase` - 12-15 pruebas
   - `GetActivitiesUseCase` - 10-12 pruebas
   - **Impacto estimado:** +3-4% cobertura

3. **Servicios de Dominio** (Prioridad: 🟡 ALTA)
   - `ActivityToTimeBlockService` - 12-15 pruebas
   - `ActivityNotificationService` - 10-12 pruebas
   - **Impacto estimado:** +3-4% cobertura

**Total Fase 1:** +11-15% cobertura → **28-32% cobertura total**

### **Fase 2: Importante (Aumentar cobertura a 50%)**

4. **Servicios Core faltantes** (Prioridad: 🟡 MEDIA)
   - `NotificationService` - 15-20 pruebas
   - `LocalStorage` - 10-12 pruebas
   - `NavigationService` - 8-10 pruebas
   - **Impacto estimado:** +5-7% cobertura

5. **Modelos faltantes** (Prioridad: 🟡 MEDIA)
   - `TimeBlockModel` - 20-25 pruebas
   - Completar `ActivityModel` - 10-12 pruebas
   - Completar `HabitModel` - 10-12 pruebas
   - **Impacto estimado:** +6-8% cobertura

6. **Utilidades faltantes** (Prioridad: 🟢 BAJA)
   - `StringSimilarity` - 8-10 pruebas
   - `ErrorHandler` - 10-12 pruebas
   - `Logger` - 5-8 pruebas
   - **Impacto estimado:** +3-4% cobertura

**Total Fase 2:** +14-19% cobertura → **42-51% cobertura total**

### **Fase 3: Mejora Continua (Aumentar cobertura a 70%+)**

7. **Controladores/Cubits** (Prioridad: 🟢 BAJA)
   - `HabitCubit` - 15-20 pruebas
   - `TaskCubit` - 15-20 pruebas
   - **Impacto estimado:** +4-5% cobertura

8. **Widgets** (Prioridad: 🟢 BAJA)
   - Widgets críticos - 20-30 pruebas
   - **Impacto estimado:** +2-3% cobertura

**Total Fase 3:** +6-8% cobertura → **48-59% cobertura total**

## 📈 Métricas de Progreso

| Fase | Cobertura Objetivo | Pruebas Necesarias | Prioridad |
|------|-------------------|-------------------|-----------|
| Actual | 17% | 42 pruebas | - |
| Fase 1 | 30% | +80-100 pruebas | 🔴 Crítica |
| Fase 2 | 50% | +100-120 pruebas | 🟡 Alta |
| Fase 3 | 70% | +80-100 pruebas | 🟢 Media |

## 🎯 Recomendaciones Inmediatas

1. **Empezar con Repositorios** - Son la base de la persistencia de datos
2. **Luego Casos de Uso** - Contienen la lógica de negocio principal
3. **Después Servicios de Dominio** - Orquestan la funcionalidad entre módulos
4. **Finalmente Servicios Core** - Completar la cobertura de servicios

## 📝 Notas

- **17% es bajo pero normal** para un proyecto en desarrollo activo
- El objetivo de **70-80%** es razonable para un proyecto maduro
- Priorizar **lógica de negocio crítica** sobre widgets/UI
- Establecer un **Quality Gate en SonarCloud** con mínimo de 30% inicialmente



