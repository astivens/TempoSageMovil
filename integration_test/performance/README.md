# Pruebas de Rendimiento de Integración

Este directorio contiene pruebas de rendimiento que utilizan el framework `integration_test` de Flutter para medir el rendimiento de la aplicación en un entorno real.

## Pruebas Disponibles

### UI Performance Test (`ui_performance_test.dart`)

Esta prueba mide el rendimiento de la interfaz de usuario en diferentes escenarios:

1. **Navegación entre vistas**:
   - Mide el tiempo de transición entre diferentes pantallas
   - Detecta posibles caídas de frames durante la navegación

2. **Scroll en listas**:
   - Mide la fluidez durante el desplazamiento
   - Identifica posibles caídas de FPS en listas largas

3. **Apertura de diálogos y menús**:
   - Mide el tiempo de apertura y cierre de diálogos
   - Evalúa la respuesta de la UI ante interacciones del usuario

## Cómo ejecutar las pruebas

### Ejecutar todas las pruebas de rendimiento

```bash
./run_tests.sh --performance
```

### Ejecutar solo las pruebas de rendimiento de UI

```bash
flutter test integration_test/performance/ui_performance_test.dart
```

## Interpretación de resultados

Las pruebas utilizan el método `traceAction()` del `IntegrationTestWidgetsFlutterBinding` para recopilar métricas durante acciones específicas. Los resultados se pueden visualizar de varias formas:

1. **Salida de consola**: Muestra tiempos de ejecución y posibles problemas
2. **Archivos de traza**: Se pueden analizar con herramientas como Chrome DevTools
3. **Capturas de Timeline**: Muestran datos detallados frame por frame

## Herramientas adicionales para análisis

Para un análisis más profundo, puedes utilizar:

- **Flutter DevTools**: Para analizar el árbol de widgets y el rendimiento
- **Android Profiler**: Para dispositivos Android
- **Instruments**: Para dispositivos iOS

## Consejos para añadir nuevas pruebas

Al añadir nuevas pruebas de rendimiento:

1. Usa `binding.traceAction()` para medir el rendimiento de acciones específicas
2. Establece valores esperados realistas basados en pruebas iniciales
3. Asegúrate de que las pruebas sean repetibles y no dependan de condiciones externas
4. Documenta los escenarios probados y los umbrales establecidos

## Solución de problemas comunes

- Si las pruebas fallan de manera inconsistente, considera aumentar los tiempos de espera
- Para dispositivos de gama baja, ajusta los umbrales de rendimiento esperados
- Usa `tester.pumpAndSettle()` con precaución en animaciones continuas, ya que puede causar tiempos de espera 