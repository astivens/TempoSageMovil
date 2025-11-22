# Pruebas de Rendimiento en TempoSage

Este directorio contiene pruebas de rendimiento que evalúan el desempeño de la aplicación TempoSage en diferentes contextos, desde pruebas unitarias locales hasta pruebas de integración en dispositivos reales.

## Tabla de Contenido

- [Pruebas de Rendimiento Locales](#pruebas-de-rendimiento-locales)
- [Pruebas Unitarias de Rendimiento](#pruebas-unitarias-de-rendimiento)
- [Pruebas de Integración de Rendimiento](#pruebas-de-integración-de-rendimiento)
- [Análisis de Métricas en Dispositivos](#análisis-de-métricas-en-dispositivos)
- [Visualización y Análisis de Resultados](#visualización-y-análisis-de-resultados)
- [Automatización y CI/CD](#automatización-y-cicd)
- [Optimizaciones Específicas de Flutter](#optimizaciones-específicas-de-flutter)
- [Herramientas Adicionales](#herramientas-adicionales)
- [Solución de Problemas](#solución-de-problemas)
- [Consejos para Añadir Nuevas Pruebas](#consejos-para-añadir-nuevas-pruebas)

## Pruebas de Rendimiento Locales

Estas pruebas evalúan componentes específicos sin necesidad de un dispositivo físico.

### Pruebas Unitarias Básicas

Verifican la eficiencia de la lógica de negocio:

```bash
# Ejecutar todas las pruebas unitarias
flutter test

# Ejecutar pruebas específicas
flutter test test/unit/
```

### Pruebas de Widgets

Evalúan el rendimiento de componentes de UI individuales:

```bash
# Ejecutar todas las pruebas de widgets
flutter test test/widget/

# Ejecutar una prueba específica
flutter test test/widget/my_widget_test.dart
```

### Benchmark de Métodos Específicos

Miden la eficiencia de funciones y utilidades clave:

```bash
# Benchmark para helpers de fecha/hora
flutter test test/benchmark/utils/date_time_helper_benchmark_test.dart

# Prueba de rendimiento de algoritmos de recomendación
flutter test test/benchmark/business/recommendation_engine_test.dart

# Prueba de operaciones de sincronización
flutter test test/benchmark/services/sync_service_test.dart
```

## Pruebas Unitarias de Rendimiento

Evalúan el rendimiento de componentes core sin necesidad de UI completa.

### Pruebas del Repositorio (`repository_benchmark_test.dart`)

Miden el rendimiento de operaciones CRUD:

```bash
flutter test test/performance/repository_benchmark_test.dart
```

Esta prueba evalúa:
- Velocidad de inserción (objetivo: <5ms por bloque)
- Rendimiento de consultas (objetivo: <2ms por consulta)
- Eficiencia del filtrado por fecha (objetivo: <10ms para 100 bloques)

### Pruebas de Uso de Memoria (`memory_test.dart`)

Verifican la gestión de memoria durante operaciones intensivas:

```bash
flutter test test/performance/memory_test.dart
```

Esta prueba mide:
- Consumo de memoria al cargar grandes conjuntos de datos
- Liberación de recursos tras eliminar datos
- Rendimiento con operaciones en lotes grandes

## Pruebas de Integración de Rendimiento

Estas pruebas evalúan el rendimiento real de la aplicación en dispositivos físicos.

### Prueba de Tiempos de Carga (`timeline_test.dart`)

Mide el tiempo de inicialización e interacción inicial:

```bash
flutter drive \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/performance/timeline_test.dart \
  --profile \
  --no-dds
```

### Prueba de Rendimiento de UI (`ui_performance_test.dart`)

Evalúa la respuesta de la interfaz en escenarios reales:

```bash
flutter drive \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/performance/app_performance_test.dart \
  --profile \
  --no-dds
```

Esta prueba mide:

1. **Navegación entre vistas**:
   - Tiempo de transición entre pantallas
   - Detección de caídas de frames durante navegación

2. **Scroll en listas**:
   - Fluidez durante el desplazamiento
   - Identificación de caídas de FPS en listas largas

3. **Apertura de diálogos y menús**:
   - Tiempo de apertura/cierre
   - Respuesta de UI ante interacciones

### Prueba de Inicio en Frío vs Caliente

Mide tiempos de inicio en diferentes escenarios:

```bash
# Reinicio en frío (cierra completamente la app primero)
adb shell am force-stop com.example.temposage
flutter drive --profile \
  --driver=test_driver/startup_driver.dart \
  --target=integration_test/performance/cold_start_test.dart
```

### Ejecución de Todas las Pruebas

```bash
# Todas las pruebas de rendimiento (incluye unitarias)
./run_tests.sh --performance

# Solo pruebas en dispositivo físico
./run_device_tests.sh
```

## Análisis de Métricas en Dispositivos

### Análisis Automático

Ejecuta análisis completo del rendimiento en el dispositivo:

```bash
./scripts/analizar_rendimiento.sh
```

Este script recopila:
- Estadísticas de memoria (PSS, Java Heap)
- Rendimiento gráfico (frames totales, lentos)
- Uso de CPU
- Impacto en batería

Los datos se guardan en `performance_reports/`.

### Métricas Específicas Manuales

```bash
# Análisis de memoria
adb shell dumpsys meminfo com.example.temposage

# Rendimiento gráfico (con reset previo)
adb shell dumpsys gfxinfo com.example.temposage reset
sleep 10  # Usar la app mientras tanto
adb shell dumpsys gfxinfo com.example.temposage

# Uso de CPU
adb shell dumpsys cpuinfo | grep com.example.temposage

# Estadísticas de batería
adb shell dumpsys batterystats com.example.temposage
```

## Visualización y Análisis de Resultados

### Generación de Gráficos

Para visualizar datos recopilados del dispositivo:

```bash
python scripts/visualizar_rendimiento.py
```

Este script genera gráficos en `performance_reports/graficos/`:
- Uso de memoria
- Uso de CPU
- Rendimiento de frames
- Porcentaje de frames lentos

### Visualización de Pruebas Locales

```bash
# Generar informe con métricas de rendimiento
flutter test --coverage --machine > test-reports/benchmark_results.json

# Convertir a formato legible (requiere jq)
jq . test-reports/benchmark_results.json > test-reports/benchmark_results_formatted.json
```

### Análisis Estadístico Avanzado

Para análisis estadístico de múltiples ejecuciones:

```bash
python scripts/analizar_estadisticas.py
```

Este script proporciona:
- Estadísticas descriptivas
- Análisis de percentiles (p90, p95, p99)
- Detección de valores atípicos

### Interpretación de Resultados

Las pruebas usan `traceAction()` del `IntegrationTestWidgetsFlutterBinding` para recopilar métricas. Los resultados pueden visualizarse como:

1. **Salida de consola**: Muestra tiempos y problemas
2. **Archivos de traza**: Analizables con Chrome DevTools
3. **Capturas de Timeline**: Datos detallados frame por frame

#### Umbrales Recomendados

- **Memoria**:
  - PSS Total: < 150MB para apps medianas
  - Java Heap: < 50MB para evitar presión en GC

- **Rendimiento Gráfico**:
  - FPS objetivo: 60 FPS (16.67ms/frame)
  - Frames lentos: < 5% del total
  - Tiempo UI Thread: < 8ms

- **CPU**:
  - Uso normal: < 15% en operaciones regulares
  - Picos: < 30% en operaciones intensivas

- **Benchmarks Locales**:
  - Métodos de utilidad: < 1ms por operación
  - Operaciones de BD: < 5ms por entidad
  - Procesamiento de datos: < 50ms para 100 elementos

## Automatización y CI/CD

### GitHub Actions para Pruebas de Rendimiento

```yaml
name: Performance Tests
on:
  pull_request:
    branches: [ main, develop ]
jobs:
  performance-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Run Performance Tests
        run: flutter test test/performance/
      - name: Upload Performance Reports
        uses: actions/upload-artifact@v3
        with:
          name: performance-reports
          path: test-reports/
```

### Comparación entre Versiones

```bash
# Comparar rendimiento entre versiones
./scripts/compare_performance.sh v1.0.0 v1.1.0
```

## Optimizaciones Específicas de Flutter

### Precalentamiento de Shaders

Para reducir jank de primera ejecución:

```dart
// En main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Precalentar shaders para animaciones críticas
  await precacheSkSL();
  
  runApp(MyApp());
}

Future<void> precacheSkSL() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await Future.wait([
      precacheImage(AssetImage('assets/images/logo.png'), null),
      // Otras imágenes críticas
    ]);
  }
}
```

### Pruebas A/B de Rendimiento

Para comparar implementaciones alternativas:

```dart
void main() {
  group('Implementación A vs B - Ordenamiento', () {
    final List<TimeBlockModel> blocks = generateTestBlocks(1000);
    
    benchmark('Implementación A: QuickSort', () {
      final result = TimeBlockSorterA.sort(blocks);
      expect(result.length, equals(1000));
    });
    
    benchmark('Implementación B: MergeSort', () {
      final result = TimeBlockSorterB.sort(blocks);
      expect(result.length, equals(1000));
    });
  });
}
```

### Simulación de Condiciones Adversas

```bash
# Simular red lenta en Android
adb shell "tc qdisc add dev eth0 root netem delay 300ms"

# Ejecutar prueba de sincronización
flutter drive --profile \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/performance/network_sync_test.dart

# Restaurar configuración normal
adb shell "tc qdisc del dev eth0 root"
```

## Herramientas Adicionales

Para análisis más profundo:

- **Flutter DevTools**: Análisis de widgets y rendimiento
- **Android Profiler**: Para dispositivos Android
- **Instruments**: Para dispositivos iOS
- **Firebase Performance**: Para monitoreo en producción

```dart
// Medir tiempo de operaciones críticas con Firebase Performance
final Trace trace = FirebasePerformance.instance.newTrace('data_sync');
await trace.start();
await syncData();
await trace.stop();
```

## Solución de Problemas

### Pruebas locales fallan
```bash
flutter clean
flutter pub get
flutter test --update-goldens
```

### La aplicación no se instala correctamente
```bash
flutter clean
flutter pub get
flutter run --profile
```

### Errores de conexión con el dispositivo
```bash
adb kill-server
adb start-server
adb devices
```

### Problemas con VM Service en pruebas
Usa la flag `--no-dds` al ejecutar pruebas de integración:
```bash
flutter drive --driver=... --target=... --profile --no-dds
```

### Datos de rendimiento no se recopilan
Verifica que la app esté en modo profile (no debug):
```bash
flutter run --profile
```

### Pruebas inconsistentes
- Aumenta tiempos de espera
- Ajusta umbrales para dispositivos específicos
- Usa `pumpAndSettle()` con precaución en animaciones continuas

## Consejos para Añadir Nuevas Pruebas

1. Usa `binding.traceAction()` para medir el rendimiento de acciones específicas
2. Establece valores esperados realistas basados en pruebas iniciales
3. Asegúrate de que las pruebas sean repetibles y no dependan de condiciones externas
4. Documenta los escenarios probados y los umbrales establecidos
5. Implementa pruebas paramétricas para evaluar diferentes escalas:

```dart
@parameterizedTest
void sortingPerformance(int dataSize) {
  final blocks = generateTestBlocks(dataSize);
  
  benchmark('Ordenar $dataSize bloques', () {
    TimeBlockSorter.sort(blocks);
  });
}

// Ejecutar con diferentes tamaños
[10, 100, 1000, 10000].forEach(sortingPerformance);
```

6. Para APIs de rendimiento específicas de Flutter, consulta:
   - [Flutter Performance Profiling](https://flutter.dev/docs/perf/rendering/ui-performance)
   - [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools/overview) 