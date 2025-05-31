# Estrategia de Pruebas para TempoSage Movil

Este documento describe la estrategia completa de pruebas para el proyecto TempoSage Movil, estableciendo las mejores prácticas y procedimientos para asegurar la calidad del software.

## Objetivos

- Identificar y corregir errores en etapas tempranas del desarrollo
- Asegurar que la aplicación cumpla con los requisitos funcionales y no funcionales
- Garantizar una experiencia de usuario óptima
- Facilitar la integración continua y entrega continua (CI/CD)
- Mejorar la cobertura de código progresivamente

## Niveles de Pruebas

### 1. Pruebas Unitarias

Las pruebas unitarias verifican el correcto funcionamiento de componentes individuales del código, como clases y funciones.

**Herramientas:**
- `flutter_test` para pruebas básicas
- `mocktail` para simular dependencias (mocks)
- `bloc_test` para probar los controladores de estado (BLoC)

**Ubicación:** `/test/unit/`

**Ejemplo implementado:**
- Pruebas de controladores: `test/unit/controllers/dashboard_controller_test.dart`
- Pruebas de modelos: `test/unit/models/user_model_test.dart`
- Pruebas de servicios: `test/unit/services/csv_service_test.dart`

### 2. Pruebas de Widgets

Las pruebas de widgets verifican la correcta renderización y comportamiento de los componentes de UI.

**Herramientas:**
- `flutter_test` con WidgetTester
- `network_image_mock` para simular imágenes de red
- `golden_toolkit` para pruebas de comparación visual

**Ubicación:** `/test/widget/`

**Ejemplo implementado:**
- Pruebas de componentes: `test/widget/accessible_card_test.dart`

### 3. Pruebas de Integración

Las pruebas de integración verifican la correcta interacción entre diferentes componentes de la aplicación.

**Herramientas:**
- `integration_test` de Flutter
- `flutter_driver` para pruebas que requieren interacción con el sistema

**Ubicación:** `/test/integration/`

**Ejemplo implementado:**
- Integración de autenticación: `test/integration/auth/auth_service_test.dart`

### 4. Pruebas de Sistema

Las pruebas de sistema evalúan el comportamiento de la aplicación como un todo, considerando aspectos como:

- **Rendimiento:** Tiempo de carga, uso de memoria, fluidez
- **Portabilidad:** Comportamiento en diferentes dispositivos y tamaños de pantalla
- **Seguridad:** Protección de datos y validación de entradas
- **Usabilidad:** Experiencia de usuario y accesibilidad

**Ubicación:** `/test/system/`

**Ejemplos implementados:**
- Rendimiento: `test/system/performance/app_performance_test.dart`
- Portabilidad: `test/system/portability/responsive_layout_test.dart`
- Usabilidad: `test/system/usability/ui_usability_test.dart`

### 5. Pruebas de Aceptación

Las pruebas de aceptación verifican que la aplicación cumple con los requisitos de negocio desde la perspectiva del usuario.

**Nota:** Aunque se planificó inicialmente usar Gherkin para las pruebas de aceptación, se encontraron problemas de compatibilidad con las dependencias. Se ha decidido posponer esta implementación y usar un enfoque alternativo basado en `integration_test` para las pruebas de aceptación.

**Ubicación actual:** `/test/acceptance/`

## Implementación

### Dependencias

Las dependencias necesarias están configuradas en el archivo `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.0
  bloc_test: ^9.1.5
  network_image_mock: ^2.1.1
  golden_toolkit: ^0.15.0
  flutter_driver:
    sdk: flutter
```

### Estructura de Directorios

```
/test
  /unit               # Pruebas unitarias
    /controllers      # Pruebas de controladores
    /models           # Pruebas de modelos
    /services         # Pruebas de servicios
    /utils            # Pruebas de utilidades
  /integration        # Pruebas de integración
    /auth             # Pruebas de autenticación
    /services         # Pruebas de servicios integrados
  /system             # Pruebas de sistema
    /performance      # Pruebas de rendimiento
    /portability      # Pruebas de compatibilidad
    /security         # Pruebas de seguridad
    /usability        # Pruebas de usabilidad
  /acceptance         # Pruebas de aceptación
    /gherkin          # Estructura para futuras pruebas con Gherkin
  /widget             # Pruebas de widgets
```

### Reportes y Análisis

El script `scripts/generate_sonar_reports.sh` está configurado para generar reportes de cobertura y resultados de pruebas que pueden ser consumidos por SonarQube.

## Estrategia "Clean as You Code"

Seguimos la estrategia "Clean as You Code" recomendada por SonarSource, que consiste en:

1. **Enfoque en código nuevo:** Garantizar que todo el código nuevo tenga pruebas adecuadas.
2. **Mejora incremental:** Cuando se modifica código existente, aprovechar para agregar o mejorar pruebas.
3. **Cobertura progresiva:** Aumentar gradualmente la cobertura de pruebas del proyecto.

## Buenas Prácticas

1. **Pruebas independientes:** Cada prueba debe ser independiente y no depender del estado dejado por otras pruebas.
2. **Datos de prueba claros:** Usar datos de prueba explícitos y comprensibles.
3. **AAA Pattern:** Seguir el patrón Arrange-Act-Assert:
   - **Arrange:** Preparar los datos y condiciones para la prueba
   - **Act:** Ejecutar la operación que se está probando
   - **Assert:** Verificar que el resultado es el esperado
4. **Mocks y stubs:** Usar simulaciones para aislar el componente bajo prueba.
5. **Refactorización:** Mantener el código de prueba limpio y refactorizado.

## Próximos Pasos

1. **Expandir pruebas de widgets:** Agregar pruebas específicas para más widgets complejos.
2. **Integrar pruebas en CI/CD:** Configurar la ejecución automática de pruebas en el pipeline de CI/CD.
3. **Golden tests:** Implementar más pruebas visuales para verificar la apariencia de la UI.
4. **Solucionar el enfoque de pruebas de aceptación:** Investigar alternativas a Gherkin o solucionar los problemas de compatibilidad.
5. **Aumentar cobertura:** Incrementar progresivamente la cobertura de pruebas en todas las áreas de la aplicación.

## Integración con SonarQube

La integración con SonarQube permite monitorear la calidad del código y establecer umbrales mínimos para la cobertura de pruebas.

### Configuración de SonarQube

Hemos establecido la siguiente configuración para SonarQube:

1. **Archivo `sonar-project.properties`:**
   - Definición de métricas de calidad
   - Exclusión de archivos generados
   - Configuración de reglas personalizadas
   - Organización de pruebas por tipo (unitarias, de widgets, de integración, de sistema)

2. **Scripts de automatización:**
   - `run_tests.sh`: Ejecuta todas las pruebas y genera informes de cobertura
   - `generate_sonar_reports.sh`: Convierte los resultados de pruebas a formato XML compatible con SonarQube
   - `run_sonarqube.sh`: Ejecuta el análisis con SonarQube Scanner

3. **Integración con CI/CD:**
   - Flujo de trabajo de GitHub Actions para ejecutar pruebas y análisis automáticamente
   - Configuración de Quality Gates para verificar la calidad del código

### Análisis de Calidad

SonarQube proporciona un análisis detallado de la calidad del código basado en las siguientes dimensiones:

1. **Fiabilidad (Reliability):** Detección de bugs y errores potenciales
2. **Seguridad (Security):** Identificación de vulnerabilidades y problemas de seguridad
3. **Mantenibilidad (Maintainability):** Evaluación de "code smells" y deuda técnica
4. **Cobertura (Coverage):** Porcentaje de código cubierto por pruebas
5. **Duplicación (Duplication):** Detección de código duplicado

### Interpretación de resultados

El análisis de SonarQube proporciona resultados en varias categorías:

1. **Quality Gate:** Un conjunto de condiciones que determinan si el código cumple con los estándares de calidad definidos. Configuramos nuestro Quality Gate para ser más estricto con el código nuevo, siguiendo la estrategia "Clean as You Code".

2. **Issues:** Problemas detectados, clasificados por severidad:
   - **Blocker:** Impacto crítico, debe resolverse inmediatamente
   - **Critical:** Alto impacto, debe resolverse pronto
   - **Major:** Impacto significativo
   - **Minor:** Impacto menor
   - **Info:** Información, no tiene impacto significativo

3. **Hotspots:** Áreas de código que requieren revisión manual desde el punto de vista de seguridad.

Para más detalles sobre la integración con SonarQube, consulte el documento [INTEGRACION_SONARQUBE.md](INTEGRACION_SONARQUBE.md).

## Estrategia de Mejora Continua

### Enfoque "Clean as You Code"

Siguiendo el enfoque recomendado por SonarSource, nos centramos en:

1. **Calidad en Código Nuevo**: Mantener alta calidad en el código nuevo
2. **Mejora Incremental**: Refactorizar código existente gradualmente
3. **Establecer Objetivos**: Definir metas progresivas para la cobertura

### Plan de Implementación

1. **Fase 1: Establecimiento de Bases** (Completada)
   - Implementar pruebas unitarias para componentes críticos
   - Configurar integración con SonarQube
   - Establecer línea base de calidad

2. **Fase 2: Ampliación de Cobertura** (En progreso)
   - Ampliar pruebas unitarias a más componentes
   - Implementar pruebas de widgets para componentes clave
   - Continuar con pruebas de sistema para rendimiento

3. **Fase 3: Madurez del Proceso** (Planificada)
   - Implementar enfoque alternativo para pruebas de aceptación
   - Automatizar completamente las pruebas en CI/CD
   - Establecer umbrales estrictos de calidad

## Responsabilidades

- **Desarrolladores**: Escribir pruebas unitarias y de widgets para su código
- **QA**: Definir escenarios de prueba y pruebas de aceptación
- **DevOps**: Configurar y mantener la integración con SonarQube
- **Equipo de Proyecto**: Revisar regularmente las métricas de calidad

## Herramientas y Recursos

- [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
- [mocktail](https://pub.dev/packages/mocktail)
- [bloc_test](https://pub.dev/packages/bloc_test)
- [integration_test](https://docs.flutter.dev/testing/integration-tests)
- [SonarQube](https://www.sonarqube.org/)
- [Estrategia Clean as You Code](https://www.sonarqube.org/features/clean-as-you-code/)

## Apéndice: Comandos Útiles

```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar pruebas unitarias con cobertura
flutter test --coverage

# Generar reportes para SonarQube
./scripts/generate_sonar_reports.sh

# Ejecutar análisis SonarQube
./scripts/run_sonarqube.sh

# Ejecutar todas las pruebas y generar informes para SonarQube
./scripts/run_tests.sh
``` 