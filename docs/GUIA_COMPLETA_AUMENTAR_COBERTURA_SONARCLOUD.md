# Guía Completa: Cómo Aumentar la Cobertura en SonarCloud

## 🔍 Cómo Funciona SonarCloud

### 1. **Flujo de Análisis de Cobertura**

```
┌─────────────────┐
│ 1. Ejecutar     │
│    Tests        │
│ flutter test    │
│ --coverage      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. Generar      │
│    Reporte LCOV │
│ coverage/       │
│ lcov.info       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. SonarCloud   │
│    Lee Reporte  │
│ sonar.dart.     │
│ lcov.reportPaths│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. Calcular     │
│    Cobertura    │
│ (Ejecutadas /   │
│  Total) × 100   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5. Mostrar en   │
│    Dashboard    │
│    SonarCloud   │
└─────────────────┘
```

### 2. **Fórmula de Cobertura**

```
Cobertura = (Líneas Ejecutadas / Líneas Totales) × 100
```

**Ejemplo:**
- Líneas totales en `lib/`: 22,215
- Líneas ejecutadas por tests: 7,910
- **Cobertura = (7,910 / 22,215) × 100 = 35.6%**

### 3. **Qué Cuenta SonarCloud**

✅ **SÍ cuenta:**
- Líneas ejecutadas por tests que pasan
- Código en `lib/` (según `sonar.sources=lib`)
- Tests en `test/` (según `sonar.tests=test`)

❌ **NO cuenta:**
- Líneas ejecutadas por tests que fallan
- Archivos excluidos (`*.g.dart`, `*.freezed.dart`, etc.)
- Código que no se ejecuta en ningún test

## 📊 Estado Actual de Tu Proyecto

### Configuración Actual

```properties
# sonar-project.properties
sonar.sources=lib                    # ✅ Analiza código en lib/
sonar.tests=test                     # ✅ Ejecuta tests en test/
sonar.dart.lcov.reportPaths=coverage/lcov.info  # ✅ Lee reporte LCOV
```

### Estado de Tests

- ✅ **Tests pasando**: 1,235
- ❌ **Tests fallando**: 2
- 📊 **Tasa de éxito**: 99.8%

### Archivos con Más Líneas Sin Cubrir

| Archivo | Líneas Sin Cubrir | Prioridad | Impacto Estimado |
|---------|-------------------|-----------|------------------|
| `dashboard_controller.dart` | 300 | 🔴 CRÍTICA | +2-3% |
| `habit_to_timeblock_service.dart` | 188 | 🔴 CRÍTICA | +1-2% |
| `recommendation_service.dart` | 168 | 🟡 ALTA | +1-2% |
| `ml_model_adapter.dart` | 162 | 🟡 ALTA | +1% |
| `notification_service.dart` | 154 | 🟡 ALTA | +1% |
| `activity_repository.dart` | 131 | 🔴 CRÍTICA | +1-2% |
| `habit_repository_impl.dart` | 112 | 🔴 CRÍTICA | +1% |
| `time_block_repository.dart` | 105 | 🔴 CRÍTICA | +1% |

**Total potencial**: +9-13% de cobertura adicional

## 🎯 Estrategia para Aumentar la Cobertura

### Fase 1: Corregir Tests Fallantes (PRIORIDAD MÁXIMA)

**Objetivo**: Reducir de 2 a 0 tests fallantes

**Por qué es importante**: Los tests que fallan NO generan cobertura

**Pasos**:

1. **Identificar tests fallantes**:
```bash
flutter test 2>&1 | grep -E "FAILED|ERROR"
```

2. **Corregir cada test fallante**:
   - Revisar el error
   - Corregir el código o el test
   - Verificar que pasa

3. **Regenerar cobertura**:
```bash
rm -rf coverage/
flutter test --coverage
```

**Impacto esperado**: +0.5-1% de cobertura

### Fase 2: Agregar Tests para Archivos Críticos (ALTA PRIORIDAD)

#### 2.1 DashboardController (300 líneas sin cubrir)

**Ubicación**: `lib/features/dashboard/domain/controllers/dashboard_controller.dart`

**Tests necesarios**:
- Tests para todos los métodos públicos
- Tests para casos edge (errores, valores nulos, etc.)
- Tests para estados del controlador

**Impacto estimado**: +2-3% cobertura

**Ejemplo de test**:
```dart
test('DashboardController debería inicializar correctamente', () {
  // Arrange
  final controller = DashboardController();
  
  // Act
  // Assert
  expect(controller, isNotNull);
});
```

#### 2.2 HabitToTimeBlockService (188 líneas sin cubrir)

**Ubicación**: `lib/features/habits/domain/services/habit_to_timeblock_service.dart`

**Tests necesarios**:
- Tests para conversión de hábitos a timeblocks
- Tests para validación de reglas
- Tests para casos edge

**Impacto estimado**: +1-2% cobertura

#### 2.3 ActivityRepository (131 líneas sin cubrir)

**Ubicación**: `lib/features/activities/data/repositories/activity_repository.dart`

**Tests necesarios**:
- Tests para CRUD completo
- Tests para sincronización
- Tests para casos edge (errores de red, base de datos, etc.)

**Impacto estimado**: +1-2% cobertura

### Fase 3: Ampliar Tests Existentes (MEDIA PRIORIDAD)

**Objetivo**: Cubrir casos edge y escenarios adicionales en tests existentes

**Estrategia**:
1. Identificar métodos sin cubrir en archivos con tests
2. Agregar tests para casos edge
3. Agregar tests para validaciones

**Impacto estimado**: +2-3% cobertura

## 🔧 Pasos Prácticos para Aumentar la Cobertura

### Paso 1: Verificar Cobertura Actual

```bash
# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte HTML (opcional)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Paso 2: Identificar Archivos Sin Cubrir

```bash
# Ver archivos con menos cobertura
lcov --list coverage/lcov.info | grep -E "^SF:|^LF:|^LH:" | \
  awk '/^SF:/{file=$0} /^LF:/{total=$2} /^LH:/{covered=$2; if(covered<total) print file " - " covered "/" total}'
```

### Paso 3: Crear Tests para Archivos Prioritarios

**Prioridad 1**: Archivos con 0% cobertura y alta importancia
**Prioridad 2**: Archivos con <50% cobertura
**Prioridad 3**: Archivos con <80% cobertura

### Paso 4: Verificar que los Tests Ejecutan Código

```bash
# Ejecutar un test específico con cobertura
flutter test --coverage test/unit/controllers/dashboard_controller_test.dart

# Verificar que el archivo aparece en lcov.info
grep "dashboard_controller.dart" coverage/lcov.info
```

### Paso 5: Regenerar y Subir a SonarCloud

```bash
# Limpiar cobertura anterior
rm -rf coverage/

# Ejecutar todos los tests
flutter test --coverage

# Verificar que se generó el reporte
ls -lh coverage/lcov.info

# Hacer commit y push (SonarCloud se ejecutará automáticamente)
git add coverage/lcov.info
git commit -m "test: Agregar tests para aumentar cobertura"
git push
```

## ⚠️ Problemas Comunes y Soluciones

### Problema 1: "Cobertura no aumenta después de agregar tests"

**Causas posibles**:
1. Los tests no ejecutan código nuevo
2. Los tests fallan
3. El reporte no se regeneró

**Solución**:
```bash
# 1. Verificar que los tests pasan
flutter test test/unit/controllers/dashboard_controller_test.dart

# 2. Verificar que ejecutan código
flutter test --coverage test/unit/controllers/dashboard_controller_test.dart
grep "dashboard_controller.dart" coverage/lcov.info

# 3. Regenerar cobertura completa
rm -rf coverage/
flutter test --coverage
```

### Problema 2: "SonarCloud muestra cobertura diferente a local"

**Causas posibles**:
1. SonarCloud está leyendo un reporte desactualizado
2. Las exclusiones son diferentes
3. El orden de ejecución en CI/CD es incorrecto

**Solución**:
1. Verificar que GitHub Actions ejecuta `flutter test --coverage` ANTES de SonarCloud
2. Verificar que `coverage/lcov.info` se sube correctamente
3. Revisar logs de GitHub Actions

### Problema 3: "Tests pasan localmente pero fallan en CI"

**Causas posibles**:
1. Diferencias de entorno
2. Dependencias faltantes
3. Problemas de timing

**Solución**:
1. Verificar que CI tiene las mismas dependencias
2. Revisar logs de CI para identificar diferencias
3. Agregar `--no-sound-null-safety` si es necesario

## 📈 Métricas de Seguimiento

### Cómo Medir el Progreso

1. **Cobertura total**: Ver en SonarCloud dashboard
2. **Líneas cubiertas**: `grep -c "^DA:" coverage/lcov.info`
3. **Archivos cubiertos**: `grep -c "^SF:" coverage/lcov.info`
4. **Tests pasando**: `flutter test 2>&1 | grep -oE "[0-9]+ passed"`

### Objetivos Recomendados

- **Corto plazo (1-2 semanas)**: 40% cobertura
- **Medio plazo (1 mes)**: 50% cobertura
- **Largo plazo (3 meses)**: 70% cobertura

## 🎯 Plan de Acción Inmediato

### Esta Semana

1. ✅ Corregir los 2 tests fallantes
2. ✅ Agregar tests para `DashboardController` (300 líneas)
3. ✅ Agregar tests para `HabitToTimeBlockService` (188 líneas)

**Impacto esperado**: +4-6% cobertura → **40-42% total**

### Próxima Semana

4. ✅ Agregar tests para `ActivityRepository` (131 líneas)
5. ✅ Agregar tests para `HabitRepository` (112 líneas)
6. ✅ Agregar tests para `TimeBlockRepository` (105 líneas)

**Impacto esperado**: +3-5% cobertura → **43-47% total**

### Siguiente Semana

7. ✅ Ampliar tests para `RecommendationService` (168 líneas)
8. ✅ Ampliar tests para `MLModelAdapter` (162 líneas)
9. ✅ Ampliar tests para `NotificationService` (154 líneas)

**Impacto esperado**: +3-4% cobertura → **46-51% total**

## 📚 Recursos Adicionales

- [Documentación de SonarCloud](https://docs.sonarcloud.io/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [LCOV Format Specification](https://github.com/linux-test-project/lcov)
- [SonarCloud Coverage Documentation](https://docs.sonarcloud.io/advanced-setup/code-coverage/)

## ✅ Checklist de Verificación

Antes de hacer push, verifica:

- [ ] Todos los tests pasan (`flutter test`)
- [ ] Cobertura se regeneró (`ls -lh coverage/lcov.info`)
- [ ] Reporte tiene contenido (`wc -l coverage/lcov.info`)
- [ ] Rutas en lcov.info son correctas (`grep "^SF:" coverage/lcov.info | head -5`)
- [ ] GitHub Actions workflow está correcto (`.github/workflows/build.yml`)
- [ ] SonarCloud está configurado (`sonar-project.properties`)

## 🎉 ¡Listo!

Con esta guía, deberías poder aumentar la cobertura de SonarCloud de manera sistemática y medible. Recuerda:

1. **Corregir tests fallantes primero** (no generan cobertura)
2. **Priorizar archivos críticos** (mayor impacto)
3. **Medir progreso regularmente** (verificar en SonarCloud)
4. **Mantener calidad** (tests deben pasar y ser útiles)

