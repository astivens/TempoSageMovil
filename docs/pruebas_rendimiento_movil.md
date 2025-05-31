# Guía de Pruebas de Rendimiento en TempoSage

Este documento proporciona instrucciones detalladas para ejecutar y analizar pruebas de rendimiento tanto en entorno local como en dispositivos móviles físicos con la aplicación TempoSage.

## Tabla de Contenidos
- [Preparación del Entorno](#preparación-del-entorno)
- [Pruebas en Entorno Local](#pruebas-en-entorno-local)
  - [Pruebas Unitarias](#pruebas-unitarias)
  - [Pruebas de Widgets](#pruebas-de-widgets)
  - [Benchmark de Métodos](#benchmark-de-métodos)
- [Pruebas Unitarias de Rendimiento](#pruebas-unitarias-de-rendimiento)
- [Pruebas de Integración y Rendimiento de UI](#pruebas-de-integración-y-rendimiento-de-ui)
- [Recopilación de Métricas del Dispositivo](#recopilación-de-métricas-del-dispositivo)
- [Visualización y Análisis de Resultados](#visualización-y-análisis-de-resultados)
- [Modo DevTools Interactivo](#modo-devtools-interactivo)
- [Solución de Problemas](#solución-de-problemas)

## Preparación del Entorno

### Requisitos Previos
- Flutter SDK instalado (versión 3.16 o superior)
- Android SDK con herramientas de plataforma instaladas
- Dispositivo Android físico con depuración USB habilitada (para pruebas en dispositivo)
- Python 3.6+ con pandas y matplotlib (para visualización)

### Verificación de Configuración

1. Verifica la instalación de Flutter:
   ```bash
   flutter doctor
   ```
   Asegúrate de que no hay errores o advertencias críticas.

2. Para pruebas en dispositivo, verifica que esté correctamente conectado:
   ```bash
   adb devices
   ```
   Deberías ver tu dispositivo listado como "device".

3. Instala las dependencias de Python necesarias:
   ```bash
   pip install pandas matplotlib
   ```

4. Actualiza las dependencias del proyecto:
   ```bash
   flutter pub get
   ```

## Pruebas en Entorno Local

Estas pruebas se ejecutan en tu entorno de desarrollo local sin necesidad de un dispositivo físico.

### Pruebas Unitarias

Pruebas básicas para verificar la lógica de negocio y componentes individuales:

```bash
# Ejecutar todas las pruebas unitarias
flutter test

# Ejecutar pruebas específicas
flutter test test/unit/
```

### Pruebas de Widgets

Verifican el comportamiento y renderizado de los widgets:

```bash
# Ejecutar todas las pruebas de widgets
flutter test test/widget/

# Ejecutar una prueba específica
flutter test test/widget/my_widget_test.dart
```

### Benchmark de Métodos

Pruebas para medir la eficiencia de métodos específicos:

```bash
# Ejecutar pruebas de benchmark para utils
flutter test test/benchmark/utils/date_time_helper_benchmark_test.dart
```

Esta prueba evalúa:
- Velocidad de procesamiento de fechas
- Eficiencia de métodos de formateo
- Rendimiento de cálculos temporales

### Pruebas de Lógica de Negocio

Evalúan el rendimiento de la lógica central de la aplicación:

```bash
# Prueba de rendimiento de algoritmos de recomendación
flutter test test/benchmark/business/recommendation_engine_test.dart

# Prueba de rendimiento de operaciones de sincronización
flutter test test/benchmark/services/sync_service_test.dart
```

## Pruebas Unitarias de Rendimiento

Estas pruebas evalúan el rendimiento de componentes específicos sin necesidad de UI.

### Pruebas del Repositorio

Miden el rendimiento de operaciones CRUD en el repositorio:

```bash
flutter test test/performance/repository_benchmark_test.dart
```

Esta prueba evalúa:
- Velocidad de inserción de bloques de tiempo
- Rendimiento de consultas
- Eficiencia del filtrado por fecha

### Pruebas de Uso de Memoria

Verifican la gestión de memoria durante operaciones con grandes conjuntos de datos:

```bash
flutter test test/performance/memory_test.dart
```

Esta prueba mide:
- Consumo de memoria al cargar datos
- Liberación de recursos al eliminar datos
- Rendimiento con lotes grandes de operaciones

## Pruebas de Integración y Rendimiento de UI

Estas pruebas se ejecutan en un dispositivo físico y evalúan el rendimiento real de la aplicación.

### Prueba de Tiempos de Carga

Mide el tiempo que tarda la aplicación en inicializarse e interactuar:

```bash
flutter drive \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/performance/timeline_test.dart \
  --profile \
  --no-dds
```

### Prueba de Rendimiento de UI General

Evalúa el rendimiento general de la interfaz de usuario:

```bash
flutter drive \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/performance/app_performance_test.dart \
  --profile \
  --no-dds
```

### Ejecución de Todas las Pruebas

Para ejecutar todas las pruebas de rendimiento en un solo comando:

```bash
./run_tests.sh --performance
```

Para ejecutar todas las pruebas específicas de dispositivo:

```bash
./run_device_tests.sh
```

## Recopilación de Métricas del Dispositivo

### Análisis Automático

Ejecuta un análisis completo del rendimiento en tu dispositivo:

```bash
./scripts/analizar_rendimiento.sh
```

Este script recopila y analiza:
- Estadísticas de memoria (PSS, Java Heap)
- Rendimiento gráfico (frames totales, frames lentos)
- Uso de CPU
- Impacto en batería

Todos los datos se guardan en archivos dentro de `performance_reports/`.

### Métricas Específicas Manuales

#### Memoria
```bash
adb shell dumpsys meminfo com.example.temposage
```

#### Rendimiento Gráfico
```bash
# Resetear estadísticas
adb shell dumpsys gfxinfo com.example.temposage reset

# Esperar mientras usas la app
sleep 10

# Capturar estadísticas
adb shell dumpsys gfxinfo com.example.temposage
```

#### CPU
```bash
adb shell dumpsys cpuinfo | grep com.example.temposage
```

#### Batería
```bash
adb shell dumpsys batterystats com.example.temposage
```

## Visualización y Análisis de Resultados

### Generación de Gráficos

Para visualizar los datos recopilados:

```bash
python scripts/visualizar_rendimiento.py
```

Este script genera gráficos en `performance_reports/graficos/`:
- Uso de memoria a lo largo del tiempo
- Uso de CPU
- Rendimiento de frames
- Porcentaje de frames lentos

### Visualización de Pruebas Locales

Para pruebas que se ejecutan localmente, puedes generar informes detallados:

```bash
# Generar informe de prueba con métricas de rendimiento
flutter test --coverage --machine > test-reports/benchmark_results.json

# Convertir a formato legible (requiere jq)
jq . test-reports/benchmark_results.json > test-reports/benchmark_results_formatted.json
```

### Interpretación de Resultados

#### Memoria
- **PSS Total**: < 150MB es óptimo para aplicaciones medianas
- **Java Heap**: < 50MB para evitar presión en el recolector de basura

#### Rendimiento Gráfico
- **FPS objetivo**: 60 FPS (16.67ms por frame)
- **Frames lentos**: Menos del 5% del total para una experiencia fluida
- **Tiempo de UI Thread**: < 8ms es ideal

#### CPU
- **Uso normal**: < 15% en operaciones regulares
- **Picos**: < 30% en operaciones intensivas

#### Benchmarks Locales
- **Métodos de utilidad**: < 1ms por operación
- **Operaciones de base de datos**: < 5ms por entidad
- **Procesamiento de datos**: < 50ms para lotes de 100 elementos

## Modo DevTools Interactivo

Para análisis en tiempo real con DevTools:

1. Inicia la aplicación en modo perfil:
   ```bash
   flutter run --profile
   ```

2. Abre DevTools usando la URL proporcionada en la consola (normalmente `http://127.0.0.1:xxxx`)

3. Explora las herramientas disponibles:
   - **Performance**: Análisis de frames y eventos de UI
   - **Memory**: Monitoreo de memoria y detección de fugas
   - **CPU Profiler**: Identificación de cuellos de botella
   - **Network**: Análisis de peticiones de red

### Captura de Timeline

Para capturar un timeline detallado:

1. En DevTools, ve a la pestaña "Performance"
2. Haz clic en "Record"
3. Realiza las acciones que quieres analizar
4. Haz clic en "Stop"
5. Analiza el timeline resultante

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

### Problemas con el VM Service en pruebas de integración
Asegúrate de usar la flag `--no-dds` al ejecutar pruebas de integración:
```bash
flutter drive --driver=... --target=... --profile --no-dds
```

### Datos de rendimiento no se recopilan
Verifica que la aplicación esté en modo profile:
```bash
# Incorrecto (modo debug - no válido para pruebas de rendimiento)
flutter run

# Correcto (modo profile - para pruebas de rendimiento)
flutter run --profile
```

### Error al visualizar gráficos
Instala las dependencias de Python necesarias:
```bash
pip install pandas matplotlib
```

## Consejos para Optimización

Basado en los resultados de las pruebas, considera estas optimizaciones:

1. **Uso excesivo de memoria**:
   - Reutiliza widgets en lugar de recrearlos
   - Implementa paginación para listas largas
   - Libera recursos cuando no se necesiten

2. **Frames lentos**:
   - Evita cálculos complejos en el hilo de UI
   - Usa `compute()` para operaciones intensivas
   - Optimiza las animaciones y transiciones

3. **Alto uso de CPU**:
   - Mueve operaciones costosas a hilos en segundo plano
   - Implementa caché para resultados frecuentes
   - Reduce la complejidad de algoritmos

4. **Problemas de inicialización lenta**:
   - Implementa carga diferida de recursos
   - Usa `FutureBuilder` para mostrar UI mientras se cargan datos
   - Prioriza la inicialización de componentes críticos

5. **Optimización de pruebas locales**:
   - Utiliza mocks para dependencias externas
   - Aísla las pruebas para que sean independientes
   - Automatiza la comparación de rendimiento entre versiones 