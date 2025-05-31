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

El proyecto implementa una estrategia completa de pruebas con los siguientes niveles:

### 1. Pruebas Unitarias

Las pruebas unitarias verifican componentes individuales como controladores, servicios y utilidades.

```bash
# Ejecutar pruebas unitarias
flutter test test/unit/
```

### 2. Pruebas de Widgets

Las pruebas de widgets verifican componentes de UI individuales.

```bash
# Ejecutar pruebas de widgets
flutter test test/widget/
```

### 3. Pruebas de Integración

Las pruebas de integración verifican la correcta interacción entre diferentes componentes.

```bash
# Ejecutar pruebas de integración
flutter test test/integration/
```

### 4. Pruebas de Sistema

Las pruebas de sistema evalúan aspectos como rendimiento, portabilidad y usabilidad.

```bash
# Ejecutar pruebas de sistema
flutter test test/system/
```

### Ejecutar todas las pruebas

Para ejecutar todas las pruebas y generar informes, use el script:

```bash
# Ejecutar todas las pruebas
./scripts/run_tests.sh
```

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

## Documentación adicional

Para más información sobre la estrategia de pruebas y otros aspectos técnicos, consulte:

- [Estrategia de Pruebas](docs/ESTRATEGIA_PRUEBAS.md)
- [Integración con SonarQube](docs/INTEGRACION_SONARQUBE.md)

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.
