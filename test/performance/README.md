# Pruebas de Rendimiento en TempoSage

Este directorio contiene pruebas específicas para medir y monitorizar el rendimiento de la aplicación TempoSage. El objetivo es detectar regresiones de rendimiento e identificar posibles cuellos de botella.

## Tipos de Pruebas de Rendimiento

### 1. Pruebas de Benchmark del Repositorio
Archivo: `repository_benchmark_test.dart`

Estas pruebas miden el rendimiento de las operaciones CRUD en el repositorio:
- Inserción de bloques de tiempo
- Consulta de bloques
- Filtrado por fecha

### 2. Pruebas de Uso de Memoria
Archivo: `memory_test.dart`

Estas pruebas verifican:
- Uso de memoria al cargar grandes cantidades de datos
- Liberación correcta de memoria al eliminar datos

### 3. Pruebas de Rendimiento de UI
Ubicación: `integration_test/performance/ui_performance_test.dart`

Estas pruebas miden:
- Rendimiento durante la navegación entre pantallas
- Fluidez durante el scroll en listas
- Rendimiento al abrir diálogos y menús

## Ejecutar las Pruebas de Rendimiento

Para ejecutar todas las pruebas de rendimiento, utiliza el siguiente comando:

```bash
./run_tests.sh --performance
```

Para ejecutar pruebas específicas:

```bash
# Solo pruebas de benchmark del repositorio
flutter test test/performance/repository_benchmark_test.dart

# Solo pruebas de memoria
flutter test test/performance/memory_test.dart

# Solo pruebas de UI
flutter test integration_test/performance/ui_performance_test.dart
```

## Interpretación de Resultados

Las pruebas de rendimiento imprimen métricas clave como:
- Tiempo de ejecución en milisegundos
- Número de operaciones por segundo
- Uso relativo de memoria

### Umbrales Recomendados

- **Inserción de bloques**: < 50 ms por bloque
- **Consulta de bloques**: < 1000 ms para 100 bloques
- **Filtrado**: < 500 ms para operaciones de filtrado
- **Navegación UI**: < 300 ms por transición
- **Scroll**: > 50 FPS durante el desplazamiento

## Añadir Nuevas Pruebas de Rendimiento

Para añadir nuevas pruebas:

1. Crea un nuevo archivo en el directorio correspondiente
2. Utiliza `Stopwatch` para medir tiempos
3. Para pruebas de UI, usa `binding.traceAction()`
4. Establece expectativas claras con `expect()`
5. Actualiza este README con la nueva prueba

## Consejos para Solucionar Problemas de Rendimiento

Si las pruebas fallan debido a un rendimiento deficiente:

1. Utiliza Flutter DevTools para analizar el uso de memoria y CPU
2. Identifica operaciones costosas con Timeline
3. Considera cachear resultados frecuentes
4. Optimiza consultas de base de datos
5. Revisa el uso de widgets para minimizar reconstrucciones 