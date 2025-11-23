# Por Qué No Sube la Cobertura en SonarCloud

## 🔍 Problemas Identificados

### 1. **Tests Fallando (71 tests)**

**Problema**: Si los tests fallan, **NO se genera cobertura** para esas líneas.

**Estado actual**:
- ✅ Tests pasando: 980
- ❌ Tests fallando: 71
- ⚠️ Test no compila: `enhanced_acceptance_extended_test.dart`

**Impacto**: Los 71 tests que fallan **NO están generando cobertura**, lo que reduce el porcentaje total.

### 2. **Test que No Compila**

**Archivo**: `test/acceptance/enhanced_acceptance_extended_test.dart`

**Error**: 
```
The method 'createTimeBlock' isn't defined for the class 'TimeBlockRepository'
```

**Impacto**: Este test no se ejecuta, por lo que **NO genera cobertura**.

**Solución**: Corregir el método (probablemente debería ser `addTimeBlock` o similar).

### 3. **Rutas en el Reporte de Cobertura**

**Verificación necesaria**: Las rutas en `coverage/lcov.info` deben coincidir con `sonar.sources=lib`.

**Formato correcto en lcov.info**:
```
SF:lib/features/activities/domain/services/activity_notification_service.dart
```

**Si las rutas NO coinciden**, SonarCloud no puede mapear la cobertura al código fuente.

### 4. **Orden de Ejecución en CI/CD**

**Problema común**: Si SonarCloud se ejecuta **ANTES** de generar el reporte de cobertura, no encontrará el archivo.

**Orden correcto**:
1. ✅ Ejecutar tests: `flutter test --coverage`
2. ✅ Generar reporte: `coverage/lcov.info`
3. ✅ Ejecutar SonarCloud: Lee `coverage/lcov.info`

### 5. **Exclusiones en SonarCloud**

**Configuración actual**:
```properties
sonar.coverage.exclusions=**/*.g.dart,**/*.freezed.dart,**/*.mocks.dart,**/generated/**
```

**Verificar**: Si hay archivos importantes excluidos que deberían estar incluidos.

## 🎯 Soluciones Paso a Paso

### Solución 1: Corregir Tests Fallantes (PRIORIDAD ALTA)

**Objetivo**: Reducir de 71 a <20 tests fallantes.

**Pasos**:
1. Corregir `enhanced_acceptance_extended_test.dart` (no compila)
2. Corregir los otros 70 tests que fallan

**Impacto esperado**: +5-10% de cobertura al corregir tests.

### Solución 2: Verificar Rutas en lcov.info

**Comando de verificación**:
```bash
# Verificar que las rutas empiezan con 'lib/'
grep "^SF:" coverage/lcov.info | head -10

# Debe mostrar:
# SF:lib/features/...
# SF:lib/core/...
```

**Si las rutas NO empiezan con 'lib/'**:
- SonarCloud no puede mapear la cobertura
- Necesitas ajustar la configuración de Flutter o SonarCloud

### Solución 3: Verificar Workflow de GitHub Actions

**Verificar que el workflow**:
1. Ejecuta `flutter test --coverage` **ANTES** de SonarCloud
2. Sube el archivo `coverage/lcov.info` a SonarCloud
3. Configura correctamente `sonar.dart.lcov.reportPaths`

**Ejemplo de workflow correcto**:
```yaml
- name: Run tests with coverage
  run: flutter test --coverage

- name: SonarCloud Scan
  uses: SonarSource/sonarcloud-github-action@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Solución 4: Verificar Configuración de SonarCloud

**Archivo**: `sonar-project.properties`

**Verificar**:
```properties
sonar.sources=lib                    # ✅ Correcto
sonar.tests=test                     # ✅ Correcto
sonar.dart.lcov.reportPaths=coverage/lcov.info  # ✅ Correcto
```

**Si el reporte está en otra ubicación**, ajustar `sonar.dart.lcov.reportPaths`.

## 📊 Análisis de Cobertura Actual

### Estado del Reporte
- ✅ Archivo existe: `coverage/lcov.info`
- ✅ Tamaño: 6,048 líneas
- ✅ Archivos cubiertos: 106 archivos
- ✅ Rutas correctas: Empiezan con `lib/`

### Tests Ejecutados
- ✅ Tests pasando: 980
- ❌ Tests fallando: 71
- ❌ Tests no compilando: 1

### Cálculo de Cobertura

**Fórmula**:
```
Cobertura = (Líneas ejecutadas / Líneas totales) * 100
```

**Factores que afectan**:
1. **Tests que fallan**: NO ejecutan código → NO generan cobertura
2. **Tests que no compilan**: NO se ejecutan → NO generan cobertura
3. **Código no testeado**: NO tiene tests → NO tiene cobertura
4. **Exclusiones**: Archivos excluidos NO se cuentan

## 🔧 Comandos de Diagnóstico

### 1. Verificar Reporte de Cobertura
```bash
# Verificar que existe
test -f coverage/lcov.info && echo "✅ Existe" || echo "❌ No existe"

# Ver número de archivos cubiertos
grep -c "^SF:" coverage/lcov.info

# Ver rutas
grep "^SF:" coverage/lcov.info | head -10
```

### 2. Regenerar Cobertura
```bash
# Limpiar cobertura anterior
rm -rf coverage/

# Ejecutar tests con cobertura
flutter test --coverage

# Verificar que se generó
ls -lh coverage/lcov.info
```

### 3. Verificar Tests Fallantes
```bash
# Ejecutar tests y ver cuántos fallan
flutter test 2>&1 | grep -E "(passed|failed|error)"

# Ver tests que no compilan
flutter test 2>&1 | grep -E "Error:|Compilation failed"
```

### 4. Verificar Configuración de SonarCloud
```bash
# Ver configuración actual
cat sonar-project.properties | grep -E "sonar\.(sources|tests|dart\.lcov)"

# Verificar exclusiones
cat sonar-project.properties | grep "sonar.coverage.exclusions"
```

## 🎯 Plan de Acción Inmediato

### Paso 1: Corregir Test que No Compila (5 min)
```bash
# Corregir enhanced_acceptance_extended_test.dart
# Cambiar createTimeBlock por el método correcto
```

### Paso 2: Regenerar Cobertura (2 min)
```bash
flutter test --coverage
```

### Paso 3: Verificar Reporte (1 min)
```bash
# Verificar que las rutas son correctas
grep "^SF:" coverage/lcov.info | head -5
```

### Paso 4: Ejecutar SonarCloud (5 min)
```bash
# Si tienes SonarScanner local
./scripts/run_sonarqube.sh

# O esperar a que GitHub Actions lo ejecute
```

### Paso 5: Verificar Resultados en SonarCloud
1. Ir a: https://sonarcloud.io/project/overview?id=astivens_TempoSageMovil
2. Verificar que la cobertura aumentó
3. Si no aumentó, revisar los logs del análisis

## 📈 Expectativas Realistas

### Cobertura Actual: 35.6%

### Si Corregimos los 71 Tests Fallantes:
- **Cobertura esperada**: 38-42%
- **Mejora**: +2.4-6.4%

### Si Corregimos los 71 Tests + Agregamos Tests para Código Sin Cobertura:
- **Cobertura esperada**: 45-50%
- **Mejora**: +9.4-14.4%

## ⚠️ Problemas Comunes y Soluciones

### Problema 1: "No se encuentra coverage/lcov.info"
**Causa**: Tests no se ejecutaron o fallaron antes de generar cobertura.
**Solución**: Ejecutar `flutter test --coverage` antes de SonarCloud.

### Problema 2: "Rutas no coinciden"
**Causa**: Rutas en lcov.info no empiezan con `lib/`.
**Solución**: Verificar configuración de Flutter o ajustar `sonar.sources`.

### Problema 3: "Cobertura no cambia"
**Causa**: Los nuevos tests no ejecutan código nuevo.
**Solución**: Verificar que los tests realmente ejecutan código fuente.

### Problema 4: "Tests fallan en CI pero no localmente"
**Causa**: Diferencias de entorno o dependencias faltantes.
**Solución**: Verificar que CI tiene las mismas dependencias que local.

## 📚 Referencias

- [SonarCloud Coverage Documentation](https://docs.sonarcloud.io/advanced-setup/code-coverage/)
- [Flutter Test Coverage](https://docs.flutter.dev/testing)
- [LCOV Format Specification](https://github.com/linux-test-project/lcov)

