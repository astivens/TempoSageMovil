# Problema: La Cobertura No Sube en SonarCloud

## 🔍 Diagnóstico

### Estado Actual
- **Cobertura en SonarCloud**: 37.9%
- **Tests pasando**: 1054
- **Tests fallando**: 27
- **Último análisis**: 23/11/2025, 01:01

### Problema Principal

**Los tests que fallan NO generan cobertura completa.**

Cuando un test falla:
1. El código que estaba probando puede no ejecutarse completamente
2. El reporte de cobertura (`lcov.info`) no incluye las líneas que debería haber cubierto ese test
3. SonarCloud recibe un reporte incompleto
4. La cobertura no aumenta aunque hayamos corregido muchos tests

### Tests que Fallan

Al ejecutar todos los tests juntos, hay **27 tests fallando** debido a **estado compartido**:

1. `test/integration/enhanced_integration_test.dart`: 1 test falla (26/27 pasan)
2. `test/acceptance/enhanced_acceptance_extended_test.dart`: 5 tests fallan
3. `test/system/enhanced_system_test.dart`: 3 tests fallan
4. Otros archivos con errores menores

**Nota importante**: Estos tests **pasan individualmente**, lo que confirma que el problema es de **estado compartido** entre tests.

## 🎯 Solución

### Paso 1: Corregir Tests que Fallan por Estado Compartido

Los tests fallan cuando se ejecutan todos juntos porque:
- Comparten cajas de Hive sin limpiar correctamente
- Usan las mismas fechas/IDs sin ser únicos
- No aíslan correctamente su estado

**Estrategia**:
1. Asegurar que cada test use datos únicos (fechas, emails, IDs)
2. Limpiar correctamente el estado entre tests (`setUp`/`tearDown`)
3. Usar `clear()` en lugar de `deleteBoxFromDisk()` para mantener cajas abiertas

### Paso 2: Verificar Workflow de GitHub Actions

El workflow actual tiene `|| true` y `continue-on-error: true`, lo que significa que continúa incluso si los tests fallan. Esto está bien para CI/CD, pero debemos asegurarnos de que:

1. Los tests se ejecuten completamente antes de generar cobertura
2. El reporte de cobertura se genere correctamente
3. SonarCloud reciba el reporte completo

### Paso 3: Verificar Configuración de SonarCloud

**Archivo**: `sonar-project.properties`

```properties
sonar.dart.lcov.reportPaths=coverage/lcov.info
```

✅ Esta configuración es correcta.

## 📊 Impacto Esperado

Al corregir los 27 tests que fallan:
- **Cobertura esperada**: +5-10%
- **Tests pasando**: 1081 (todos)
- **Tests fallando**: 0

## 🔧 Próximos Pasos

1. ✅ Corregir `enhanced_integration_test.dart` (1 test)
2. ✅ Corregir `enhanced_acceptance_extended_test.dart` (5 tests)
3. ✅ Corregir `enhanced_system_test.dart` (3 tests)
4. ✅ Verificar que todos los tests pasen cuando se ejecutan juntos
5. ✅ Generar nuevo reporte de cobertura
6. ✅ Verificar que SonarCloud reciba el reporte actualizado

## 📝 Notas

- Los tests que pasan individualmente pero fallan juntos indican problemas de **aislamiento de estado**
- La cobertura solo aumenta cuando **todos los tests pasan** y ejecutan completamente el código
- SonarCloud necesita un reporte de cobertura **completo y consistente** para calcular correctamente la cobertura

