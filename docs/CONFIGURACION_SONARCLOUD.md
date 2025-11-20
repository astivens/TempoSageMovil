# Configuración de SonarCloud para TempoSage Movil

Esta guía te ayudará a configurar SonarCloud para analizar tu proyecto Flutter con soporte oficial completo para Dart/Flutter.

## 🎯 Ventajas de SonarCloud

- ✅ **Soporte oficial completo** para Dart/Flutter (sin necesidad de plugins)
- ✅ **Gratis para proyectos open source**
- ✅ **Sin necesidad de servidor local** - todo en la nube
- ✅ **Integración con GitHub/GitLab/Bitbucket**
- ✅ **Actualizaciones automáticas** - siempre la última versión
- ✅ **Análisis continuo** con pull requests

## 📋 Prerrequisitos

1. Cuenta en [SonarCloud](https://sonarcloud.io) (gratis)
2. Repositorio en GitHub, GitLab o Bitbucket
3. SonarScanner instalado (o usar GitHub Actions)

## 🚀 Pasos de Configuración

### 1. Crear cuenta en SonarCloud

1. Ve a [https://sonarcloud.io](https://sonarcloud.io)
2. Haz clic en "Log in" y elige tu proveedor (GitHub, GitLab, Bitbucket)
3. Autoriza SonarCloud para acceder a tus repositorios

### 2. Crear una Organización

1. En SonarCloud, haz clic en "Create Organization"
2. Elige un nombre para tu organización (ej: `temposage` o tu nombre de usuario)
3. Selecciona el plan:
   - **Free Plan**: Para proyectos open source (recomendado)
   - **Team/Enterprise**: Para proyectos privados (requiere suscripción)

### 3. Crear el Proyecto

1. En SonarCloud, haz clic en "Analyze a project"
2. Selecciona tu organización
3. Selecciona tu repositorio (GitHub/GitLab/Bitbucket)
4. SonarCloud detectará automáticamente que es un proyecto Flutter/Dart

### 4. Obtener el Token de Análisis

1. Ve a "My Account" > "Security"
2. En "Generate Tokens", crea un nuevo token:
   - **Name**: `temposage-analysis-token`
   - **Type**: `Global Analysis Token`
   - **Expiration**: Elige un período (recomendado: sin expiración para CI/CD)
3. Haz clic en "Generate"
4. **⚠️ IMPORTANTE**: Copia el token inmediatamente, no se mostrará nuevamente

### 5. Configurar el Proyecto Local

#### Actualizar `sonar-project.properties`

Edita el archivo `sonar-project.properties` y reemplaza:

```properties
# Reemplaza 'your-org-key' con la clave de tu organización en SonarCloud
sonar.projectKey=your-org-key:temposage-movil
sonar.organization=your-org-key
```

**Ejemplo:**
Si tu organización se llama `temposage`, quedaría:
```properties
sonar.projectKey=temposage:temposage-movil
sonar.organization=temposage
```

#### Configurar el Token

Configura el token como variable de entorno:

```bash
export SONAR_TOKEN="tu_token_de_sonarcloud"
```

O añádelo a tu archivo `~/.bashrc` o `~/.zshrc`:

```bash
echo 'export SONAR_TOKEN="tu_token_de_sonarcloud"' >> ~/.zshrc
source ~/.zshrc
```

### 6. Ejecutar el Análisis

```bash
# 1. Generar cobertura
flutter test --coverage

# 2. Ejecutar análisis de SonarCloud
sonar-scanner
```

O usa el script automatizado:

```bash
./scripts/run_sonarqube.sh
```

## 🔄 Integración con GitHub Actions

Para análisis automático en cada push y pull request, crea `.github/workflows/sonarcloud.yml`:

```yaml
name: SonarCloud Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Shallow clones should be disabled for better analysis
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.2.3'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**Configurar el secreto en GitHub:**
1. Ve a tu repositorio en GitHub
2. Settings > Secrets and variables > Actions
3. New repository secret
4. Name: `SONAR_TOKEN`
5. Value: Tu token de SonarCloud

## 📊 Ver Resultados

Una vez completado el análisis:

1. Ve a [https://sonarcloud.io](https://sonarcloud.io)
2. Selecciona tu organización y proyecto
3. Verás el dashboard con:
   - **Overview**: Resumen de calidad del código
   - **Issues**: Bugs, vulnerabilidades y code smells
   - **Measures**: Métricas detalladas
   - **Code**: Explorador de código con anotaciones

## 🔧 Solución de Problemas

### Error: "Invalid project key"

- Verifica que `sonar.projectKey` tenga el formato: `organization_key:project_key`
- Asegúrate de que la organización existe en SonarCloud
- Verifica que el proyecto esté creado en SonarCloud

### Error: "Invalid authentication credentials"

- Verifica que `SONAR_TOKEN` esté configurado correctamente
- Asegúrate de que el token no haya expirado
- Verifica que el token tenga permisos de análisis

### La cobertura no se muestra

- Verifica que `coverage/lcov.info` existe y tiene contenido
- Asegúrate de que `sonar.dart.coverage.reportPaths=coverage/lcov.info` esté configurado
- Verifica que los archivos no estén excluidos en `sonar.exclusions`

### El análisis no detecta Dart/Flutter

- SonarCloud detecta automáticamente Dart/Flutter
- Verifica que `sonar.language=dart` esté en `sonar-project.properties`
- Asegúrate de que el proyecto esté correctamente configurado en SonarCloud

## 📚 Recursos Adicionales

- [Documentación oficial de SonarCloud](https://docs.sonarcloud.io/)
- [Guía de Dart/Flutter en SonarCloud](https://docs.sonarcloud.io/languages/dart/)
- [Precios y planes de SonarCloud](https://sonarcloud.io/pricing)
- [Integración con GitHub Actions](https://docs.sonarcloud.io/ci-integration/github-actions/)

## ✅ Checklist de Configuración

- [ ] Cuenta creada en SonarCloud
- [ ] Organización creada
- [ ] Proyecto creado en SonarCloud
- [ ] Token de análisis generado
- [ ] `sonar-project.properties` actualizado con organización y project key
- [ ] `SONAR_TOKEN` configurado como variable de entorno
- [ ] Primer análisis ejecutado exitosamente
- [ ] (Opcional) GitHub Actions configurado para análisis automático

## 🎉 ¡Listo!

Una vez completados estos pasos, tendrás análisis continuo de calidad de código con soporte oficial completo para Dart/Flutter, sin necesidad de mantener un servidor local.

