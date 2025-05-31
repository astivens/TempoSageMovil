# Integración con SonarQube para TempoSage Movil

Esta guía describe el proceso de configuración e integración de SonarQube con el proyecto TempoSage Movil para análisis de calidad de código.

## Requisitos previos

1. Tener acceso a un servidor SonarQube (local o remoto)
2. Tener instalado SonarQube Scanner en la máquina de desarrollo
3. Haber configurado las pruebas del proyecto

## Configuración inicial de SonarQube

### 1. Crear un proyecto en SonarQube

1. Accede a la interfaz web de SonarQube (por defecto: `http://localhost:9000`)
2. Inicia sesión con tus credenciales (por defecto: admin/admin)
3. Haz clic en "Create Project" > "Manually"
4. Completa la información del proyecto:
   - Project Display Name: TempoSage Movil
   - Project Key: temposage-movil
5. Haz clic en "Set Up"
6. Selecciona el método de análisis "Locally"

### 2. Generar un token de autenticación

1. Ve a "My Account" > "Security"
2. En la sección "Generate Tokens", crea un nuevo token:
   - Name: temposage-analysis-token
   - Type: Project Analysis Token
   - Expiration: selecciona un período adecuado (recomendado: 30 días)
3. Haz clic en "Generate"
4. **Importante:** Guarda el token generado en un lugar seguro, no se mostrará nuevamente

## Configuración del proyecto

### 1. Configurar archivo sonar-project.properties

Ya hemos configurado el archivo `sonar-project.properties` en la raíz del proyecto con los siguientes parámetros principales:

```properties
sonar.projectKey=temposage-movil
sonar.projectName=TempoSage Movil
sonar.sources=lib
sonar.tests=test
sonar.flutter.coverage.reportPath=coverage/lcov.info
sonar.testExecutionReportPaths=test-reports/test-report.xml
```

### 2. Configurar variables de entorno

Para evitar exponer el token en el código fuente, configura las siguientes variables de entorno:

```bash
# Configura el URL del servidor SonarQube
export SONAR_HOST_URL="http://localhost:9000"

# Configura el token generado anteriormente
export SONAR_TOKEN="tu_token_generado"
```

También puedes añadir estas líneas a tu archivo `.bashrc` o `.zshrc` para hacerlas persistentes.

## Ejecución del análisis

### 1. Generar informes de pruebas y cobertura

Ejecuta el siguiente comando para generar los informes necesarios:

```bash
./scripts/run_tests.sh
```

Este script ejecutará todas las pruebas unitarias, de widgets, de integración y de sistema, y generará los informes de cobertura necesarios.

### 2. Ejecutar el análisis de SonarQube

Una vez generados los informes, ejecuta el análisis de SonarQube:

```bash
./scripts/run_sonarqube.sh
```

Este script ejecutará SonarQube Scanner y enviará los resultados al servidor SonarQube.

## Verificación de resultados

1. Accede a la interfaz web de SonarQube
2. Navega a tu proyecto "TempoSage Movil"
3. Revisa los resultados del análisis en las siguientes secciones:
   - Overview: Visión general de la calidad del código
   - Issues: Problemas detectados
   - Measures: Métricas detalladas
   - Code: Explorador de código con anotaciones

## Interpretación de resultados

### Calidad general (Quality Gate)

El "Quality Gate" es un conjunto de condiciones que determinan si el código cumple con los estándares de calidad definidos. Un status de "Passed" indica que el código cumple con todas las condiciones.

### Métricas principales

- **Reliability:** Indica la presencia de bugs
- **Security:** Indica la presencia de vulnerabilidades
- **Maintainability:** Indica la presencia de "code smells" o deuda técnica
- **Coverage:** Porcentaje de código cubierto por pruebas
- **Duplications:** Porcentaje de código duplicado

## Integración con CI/CD

Para integrar SonarQube en un pipeline de CI/CD (por ejemplo, GitHub Actions), añade los siguientes pasos a tu workflow:

```yaml
- name: Run tests with coverage
  run: ./scripts/run_tests.sh

- name: SonarQube analysis
  env:
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: ./scripts/run_sonarqube.sh
```

Asegúrate de configurar los secretos `SONAR_HOST_URL` y `SONAR_TOKEN` en tu plataforma de CI/CD.

## Estrategia "Clean as You Code"

Seguimos la estrategia "Clean as You Code" recomendada por SonarSource, que consiste en:

1. **Enfoque en código nuevo:** Garantizar que todo el código nuevo tenga alta calidad
2. **Mejora incremental:** Cuando se modifica código existente, aprovechar para mejorarlo
3. **Cobertura progresiva:** Aumentar gradualmente la cobertura de pruebas

## Recursos adicionales

- [Documentación oficial de SonarQube](https://docs.sonarqube.org/)
- [Analizando proyectos Dart/Flutter en SonarQube](https://docs.sonarqube.org/latest/analyzing-source-code/languages/dart/)
- [Estrategia Clean as You Code](https://www.sonarqube.org/features/clean-as-you-code/)
- [Guía de integración con CI/CD](https://docs.sonarqube.org/latest/devops-platform-integration/) 