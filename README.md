# TempoSage Movil

Aplicación móvil para la gestión eficiente de actividades, hábitos y bloques de tiempo.

## Descripción

TempoSage es una aplicación de productividad que utiliza inteligencia artificial para ayudar a los usuarios a organizar su tiempo de manera óptima, gestionar hábitos y planificar actividades.

## Características principales

- Gestión de actividades y tareas
- Seguimiento de hábitos y recordatorios
- Recomendaciones personalizadas de bloques de tiempo productivos
- Calendario integrado
- Soporte multilenguaje
- Modo oscuro/claro
- **Análisis de calidad de código con SonarQube**
- **Cobertura de pruebas automatizada**
- **CI/CD con análisis continuo**

## Arquitectura

El proyecto está organizado siguiendo los principios de Clean Architecture:

```
lib/
  ├── core/          # Componentes centrales y utilitarios
  ├── data/          # Capa de datos
  ├── features/      # Módulos funcionales
  ├── presentation/  # Capa de presentación
  └── services/      # Servicios comunes
```

## Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get` para instalar dependencias
3. Ejecutar `flutter run` para iniciar la aplicación

## Pruebas

El proyecto TempoSage cuenta con una estrategia completa de testing para garantizar la calidad del código:

### Pruebas Unitarias
- Ubicadas en `test/unit/`
- Prueban componentes individuales aislados
- Ejemplos: DateTimeHelper, TimeBlockRepository

### Pruebas de Widget
- Ubicadas en `test/widget/`
- Verifican que los componentes visuales se rendericen correctamente
- Utilizan el paquete flutter_test

### Pruebas de Integración
- Ubicadas en `integration_test/`
- Verifican la interacción entre múltiples componentes
- Comprueban flujos completos de la aplicación

### Pruebas de Sistema
- Ubicadas en `test/system/`
- Evalúan el sistema completo en un entorno similar a producción

### Pruebas de Rendimiento
- Ubicadas en `test/performance/` e `integration_test/performance/`
- Miden tiempos de respuesta, uso de memoria y fluidez de la UI
- Incluyen benchmarks de repositorios y pruebas de rendimiento de UI
- Se ejecutan con `./run_tests.sh --performance`

### Estrategia de Mocking
- Utilizamos mockito y mocktail para simular dependencias
- Creamos dobles de prueba para aislar componentes
- Implementamos pruebas con datos y con base de datos vacía

### Ejecución de Pruebas
Para ejecutar todas las pruebas:
```bash
./run_tests.sh
```

Para ejecutar pruebas específicas:
```bash
./run_tests.sh test/unit/utils/date_time_helper_full_test.dart
```

Para generar informe de cobertura:
```bash
./run_tests.sh --coverage
```

### Ejecutor de Pruebas Interactivo
TempoSage incluye una aplicación de consola interactiva para facilitar la ejecución de pruebas:

```bash
# Ejecutar en modo interactivo (menú)
./scripts/ejecutar_pruebas.sh

# Ejecutar pruebas específicas directamente
./scripts/ejecutar_pruebas.sh 3 2  # Ejecuta pruebas de rendimiento de repositorio
```

Alternativamente, puedes usar directamente Dart:

```bash
dart run scripts/test_runner.dart
```

Beneficios de la herramienta:
- Interfaz fácil de usar con categorías de pruebas
- Resultados en tiempo real con formateo de colores
- Verificación automática de dispositivos para pruebas de integración
- Soporte para línea de comandos y modo interactivo

La herramienta permite ejecutar fácilmente:
- Pruebas unitarias
- Pruebas de widgets
- Pruebas de rendimiento
- Pruebas de integración
- Pruebas completas
- Utilidades para pruebas

Para más información, consulta la [documentación de la herramienta](scripts/README.md).

## Análisis de Calidad con SonarQube

El proyecto está configurado para análisis de calidad con SonarQube, siguiendo la estrategia "Clean as You Code".

### Configuración con Docker

Para levantar SonarQube con Docker:

```bash
# Iniciar los contenedores de SonarQube y PostgreSQL
docker-compose -f docker-compose.sonarqube.yml up -d

# Esperar a que SonarQube esté disponible (puede tardar unos minutos)
# Acceder a http://localhost:9000 (credenciales: admin/admin)
```

### Instalación del Plugin de Flutter

```bash
# Descargar el plugin
curl -L https://github.com/insideapp-oss/sonar-flutter/releases/download/0.5.2/sonar-flutter-plugin-0.5.2.jar -o sonar-flutter-plugin.jar

# Copiar al contenedor
docker cp sonar-flutter-plugin.jar sonarqube:/opt/sonarqube/extensions/plugins/

# Reiniciar SonarQube
docker restart sonarqube
```

### Ejecución del Análisis

1. Configurar las variables de entorno:
```bash
export SONAR_HOST_URL="http://localhost:9000"
export SONAR_TOKEN="tu_token_de_sonarqube"
```

2. Ejecutar el análisis:
```bash
./scripts/run_sonarqube.sh
```

Para más detalles sobre la configuración, consulte:

- [Guía de Integración con SonarQube](docs/INTEGRACION_SONARQUBE.md)
- [Configuración de SonarQube con Docker](docs/CONFIGURACION_SONARQUBE_DOCKER.md)

## 🔍 Análisis de Calidad de Código

### SonarQube Integration

Este proyecto incluye análisis de calidad de código automatizado con SonarQube:

#### Métricas Actuales
- **Líneas de Código:** 17,549
- **Cobertura de Pruebas:** 27.2%
- **Calificación de Seguridad:** A (Excelente)
- **Calificación de Confiabilidad:** C (Necesita mejora)
- **Vulnerabilidades:** 0
- **Duplicación:** 0.4%

#### Ejecución Rápida
```bash
# Análisis completo automatizado
./scripts/run_sonarqube_analysis.sh

# Análisis de issues críticos
./scripts/analyze_critical_issues.sh
```

#### Acceso al Dashboard
- **URL:** http://localhost:9000/dashboard?id=temposage-movil
- **Usuario:** admin
- **Contraseña:** admin

### Quality Gates

El proyecto implementa quality gates que verifican:
- ✅ Cobertura de pruebas > 80%
- ✅ Sin vulnerabilidades de seguridad
- ✅ Calificación de seguridad A
- ✅ Duplicación < 3%

### CI/CD

Análisis automático en cada:
- Push a ramas principales
- Pull Request
- Release

## 📚 Documentación adicional

Para más información sobre la estrategia de pruebas y otros aspectos técnicos, consulte:

- [Estrategia de Pruebas](docs/ESTRATEGIA_PRUEBAS.md)
- [Integración con SonarQube](docs/INTEGRACION_SONARQUBE.md)
- [README SonarQube](docs/README_SONARQUBE.md)
- [Reporte de Calidad](docs/REPORTE_SONARQUBE_TEMPOSAGE.md)
- [Entregar Final](docs/ENTREGA_FINAL_SOFTWARE_TEMPOSAGE.md)

## Contribución

1. Realizar pruebas para nuevas funcionalidades
2. Mantener o mejorar la cobertura de pruebas existente
3. Seguir el estilo de código establecido
4. Revisar el código antes de enviar un PR

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.
