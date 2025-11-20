# SonarQube Soporte Oficial para Dart/Flutter (2024)

## 🎉 Novedad: Soporte Oficial Nativo

Desde **2024**, SonarQube incorporó **soporte oficial nativo** para proyectos Dart y Flutter. Esto significa que:

- ✅ **No necesitas plugins externos** - El soporte está incluido en SonarQube 10.7+
- ✅ **Mejor integración** - Análisis más preciso y completo
- ✅ **Mantenimiento oficial** - Actualizaciones y mejoras continuas por SonarSource
- ✅ **Disponible en SonarCloud y SonarQube Server** - Funciona en ambas plataformas

## Requisitos

### Versiones Compatibles

- **SonarQube Server:** 10.7 o superior (Developer Edition y superiores)
- **SonarCloud:** Disponible en planes Team y Enterprise, y para proyectos de código abierto
- **SonarScanner:** Cualquier versión reciente compatible con SonarQube 10.7+

### Ediciones de SonarQube

El soporte oficial para Dart/Flutter está disponible en:
- ✅ Developer Edition (requerida para soporte oficial)
- ✅ Enterprise Edition
- ✅ Data Center Edition
- ✅ SonarCloud (planes Team y Enterprise, y proyectos open source)
- ❌ Community Edition (no incluye soporte oficial - usar plugin externo o SonarCloud)

**Nota importante:** Si usas Community Edition localmente, puedes:
1. Usar SonarCloud (gratis para proyectos open source) que incluye soporte oficial
2. Usar el plugin externo `sonar-flutter-plugin` (ver script `instalar_plugin_sonarqube.sh`)
3. Actualizar a Developer Edition para obtener soporte oficial completo

## Configuración del Proyecto

### 1. Archivo sonar-project.properties

El archivo `sonar-project.properties` ya está configurado con las propiedades correctas:

```properties
# Configuración básica
sonar.projectKey=temposage-movil
sonar.projectName=TempoSage Movil
sonar.projectVersion=1.0.0

# Fuentes y tests
sonar.sources=lib
sonar.tests=test
sonar.sourceEncoding=UTF-8

# Idioma - Soporte oficial
sonar.language=dart

# Cobertura - Propiedad específica para Dart/Flutter
sonar.dart.coverage.reportPaths=coverage/lcov.info
sonar.coverage.exclusions=**/*.g.dart,**/*.freezed.dart,**/*.mocks.dart

# Excluir archivos generados y recursos
sonar.exclusions=**/*.g.dart,**/*.freezed.dart,**/generated/**,**/build/**,...
```

### 2. Propiedades Clave para Dart/Flutter

| Propiedad | Descripción | Ejemplo |
|-----------|-------------|---------|
| `sonar.language` | Especifica el lenguaje (opcional, se detecta automáticamente) | `dart` |
| `sonar.dart.coverage.reportPaths` | Ruta al informe de cobertura LCOV | `coverage/lcov.info` |
| `sonar.coverage.exclusions` | Archivos a excluir del análisis de cobertura | `**/*.g.dart` |

## Generación de Cobertura

Para generar el informe de cobertura que SonarQube necesita:

```bash
# Ejecutar pruebas con cobertura
flutter test --coverage

# Esto genera: coverage/lcov.info
```

## Ejecución del Análisis

### Opción 1: Usando el script automatizado

```bash
./scripts/run_sonarqube_analysis.sh
```

Este script:
1. Inicia SonarQube con Docker
2. Ejecuta las pruebas y genera cobertura
3. Obtiene un token de autenticación
4. Ejecuta el análisis de SonarQube
5. Genera un reporte con métricas

### Opción 2: Manual

```bash
# 1. Iniciar SonarQube
docker-compose -f docker-compose.sonarqube.yml up -d

# 2. Generar cobertura
flutter test --coverage

# 3. Configurar token (si no está en variables de entorno)
export SONAR_TOKEN="tu_token_aqui"

# 4. Ejecutar análisis
sonar-scanner
```

## Ventajas del Soporte Oficial

### Antes (con plugin externo)
- ❌ Requería instalar plugin manualmente
- ❌ Actualizaciones del plugin no siempre sincronizadas
- ❌ Posibles incompatibilidades con nuevas versiones de SonarQube
- ❌ Soporte comunitario limitado

### Ahora (soporte oficial)
- ✅ Incluido nativamente en SonarQube 10.7+
- ✅ Actualizaciones automáticas con SonarQube
- ✅ Compatibilidad garantizada
- ✅ Soporte oficial de SonarSource
- ✅ Mejor detección de problemas específicos de Dart/Flutter
- ✅ Métricas más precisas

## Características del Análisis

El soporte oficial de SonarQube para Dart/Flutter incluye:

- **Análisis de código estático** - Detección de bugs, vulnerabilidades y code smells
- **Métricas de calidad** - Complejidad, duplicación, mantenibilidad
- **Cobertura de pruebas** - Integración con informes LCOV
- **Reglas específicas de Dart** - Más de 200 reglas optimizadas para Dart/Flutter
- **Análisis de seguridad** - Detección de vulnerabilidades comunes

## Migración desde Plugin Externo

Si anteriormente usabas un plugin externo (como `sonar-flutter-plugin`):

1. **Actualiza SonarQube** a la versión 10.7 o superior
2. **Elimina el plugin externo** - Ya no es necesario
3. **Actualiza sonar-project.properties** - Usa las propiedades oficiales (ya configurado)
4. **Verifica la configuración** - Asegúrate de que `sonar.dart.coverage.reportPaths` esté configurado

## Recursos Adicionales

- [Anuncio oficial de soporte para Dart](https://www.sonarsource.com/blog/announcing-sonar-support-for-dart-elevate-your-code-quality/)
- [Documentación oficial de SonarQube para Dart](https://docs.sonarqube.org/latest/analyzing-source-code/languages/dart/)
- [Documentación de SonarCloud para Dart](https://sonarcloud.io/documentation/languages/dart/)

## Solución de Problemas

### El análisis no detecta Dart/Flutter

1. Verifica que estás usando SonarQube 10.7 o superior:
   ```bash
   docker exec sonarqube cat /opt/sonarqube/lib/sonar-application-*.jar | grep version
   ```

2. Verifica que `sonar.language=dart` esté en `sonar-project.properties`

3. Revisa los logs de SonarQube:
   ```bash
   docker logs sonarqube
   ```

### La cobertura no se muestra

1. Verifica que el archivo `coverage/lcov.info` existe y tiene contenido
2. Verifica que `sonar.dart.coverage.reportPaths=coverage/lcov.info` está configurado
3. Asegúrate de que los archivos de cobertura no estén excluidos en `sonar.exclusions`

### Errores de autenticación

1. Verifica que `SONAR_TOKEN` está configurado correctamente
2. Asegúrate de que el token tiene permisos de análisis
3. Verifica que `sonar.host.url` apunta al servidor correcto

## Conclusión

El soporte oficial de SonarQube para Dart/Flutter simplifica significativamente la integración y proporciona un análisis más robusto y mantenible. El proyecto TempoSageMovil ya está configurado para usar este soporte oficial.

