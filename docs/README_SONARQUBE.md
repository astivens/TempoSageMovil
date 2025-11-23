# 🔍 ANÁLISIS DE CALIDAD CON SONARQUBE

Este documento describe cómo usar SonarQube para el análisis de calidad de código en el proyecto TempoSageMovil.

## 📋 Índice

- [Configuración Inicial](#configuración-inicial)
- [Ejecución de Análisis](#ejecución-de-análisis)
- [Interpretación de Resultados](#interpretación-de-resultados)
- [Quality Gates](#quality-gates)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## 🚀 Configuración Inicial

### Prerrequisitos

- Docker y Docker Compose
- SonarScanner CLI
- Flutter SDK
- jq (para procesamiento de JSON)

### Instalación

1. **Clonar el repositorio:**
```bash
git clone <repository-url>
cd TempoSageMovil
```

2. **Instalar SonarScanner:**
```bash
curl -sSLo /tmp/sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip -q /tmp/sonar-scanner-cli.zip -d /opt
sudo ln -sf /opt/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner /usr/local/bin/
```

3. **Iniciar SonarQube:**
```bash
docker-compose up -d
```

4. **Esperar inicialización:**
```bash
# Esperar hasta que SonarQube esté listo
timeout 300 bash -c 'until curl -f http://localhost:9000/api/system/status; do sleep 5; done'
```

## 🔄 Ejecución de Análisis

### Análisis Completo Automatizado

```bash
# Ejecutar análisis completo
./scripts/run_sonarqube_analysis.sh
```

Este script:
- ✅ Inicia SonarQube
- ✅ Ejecuta pruebas y genera cobertura
- ✅ Obtiene token de autenticación
- ✅ Ejecuta análisis de SonarQube
- ✅ Genera reporte de métricas
- ✅ Opcionalmente detiene SonarQube

### Análisis Manual

```bash
# 1. Iniciar SonarQube
docker-compose up -d

# 2. Ejecutar pruebas con cobertura
flutter test --coverage

# 3. Obtener token
TOKEN=$(curl -u admin:admin -X POST "http://localhost:9000/api/user_tokens/generate?name=manual-token&type=GLOBAL_ANALYSIS_TOKEN" | jq -r '.token')

# 4. Ejecutar análisis
sonar-scanner -Dsonar.host.url=http://localhost:9000 -Dsonar.login="$TOKEN"
```

### Análisis de Issues Críticos

```bash
# Analizar y priorizar issues críticos
./scripts/analyze_critical_issues.sh
```

## 📊 Interpretación de Resultados

### Métricas Principales

| Métrica | Descripción | Valor Ideal |
|---------|-------------|-------------|
| **NCLOC** | Líneas de código sin comentarios | - |
| **Coverage** | Cobertura de pruebas | >80% |
| **Duplicated Lines** | Líneas duplicadas | <3% |
| **Security Rating** | Calificación de seguridad | A |
| **Reliability Rating** | Calificación de confiabilidad | A |
| **Bugs** | Número de bugs | 0 |
| **Vulnerabilities** | Vulnerabilidades de seguridad | 0 |
| **Code Smells** | Problemas de mantenibilidad | <1000 |

### Calificaciones

- **A**: Excelente (1.0)
- **B**: Bueno (2.0)
- **C**: Regular (3.0)
- **D**: Malo (4.0)
- **E**: Crítico (5.0)

### Severidades de Issues

- **BLOCKER**: Debe corregirse inmediatamente
- **CRITICAL**: Debe corregirse en la próxima release
- **MAJOR**: Debe corregirse en el próximo sprint
- **MINOR**: Debe corregirse cuando sea posible
- **INFO**: Sugerencias de mejora

## 🚧 Quality Gates

### Configuración Estándar

Los quality gates están configurados para fallar si:

- Cobertura de nuevas líneas < 80%
- Duplicación de nuevas líneas > 3%
- Calificación de mantenibilidad > A
- Calificación de confiabilidad > A
- Calificación de seguridad > A
- Bugs nuevos > 0
- Vulnerabilidades nuevas > 0
- Code smells nuevos > 100
- Security hotspots nuevos > 0

### Personalización

Para modificar los quality gates:

1. Acceder a SonarQube: http://localhost:9000
2. Ir a Quality Gates
3. Crear o modificar gate existente
4. Aplicar al proyecto

## 🔄 CI/CD Integration

### GitHub Actions

El proyecto incluye un workflow de GitHub Actions que:

- Ejecuta análisis en cada push y PR
- Comenta resultados en PRs
- Sube cobertura a Codecov
- Verifica quality gates

**Archivo:** `.github/workflows/sonarqube-analysis.yml`

### Configuración Local

Para ejecutar análisis localmente:

```bash
# Configurar variables de entorno
export SONAR_TOKEN="your-token"

# Ejecutar análisis
sonar-scanner
```

## 🛠️ Troubleshooting

### Problemas Comunes

#### SonarQube no inicia
```bash
# Verificar logs
docker-compose logs sonarqube

# Reiniciar servicios
docker-compose down
docker-compose up -d
```

#### Token de autenticación inválido
```bash
# Generar nuevo token
curl -u admin:admin -X POST "http://localhost:9000/api/user_tokens/generate?name=new-token&type=GLOBAL_ANALYSIS_TOKEN"
```

#### Análisis falla
```bash
# Verificar configuración
cat sonar-project.properties

# Ejecutar con debug
sonar-scanner -X
```

#### Cobertura no se detecta
```bash
# Verificar que existe el archivo
ls -la coverage/lcov.info

# Regenerar cobertura
flutter test --coverage
```

### Logs y Debugging

```bash
# Ver logs de SonarQube
docker-compose logs -f sonarqube

# Ver logs de análisis
sonar-scanner -X > sonar-scanner.log 2>&1

# Verificar estado del sistema
curl http://localhost:9000/api/system/status
```

## 📚 Recursos Adicionales

### Enlaces Útiles

- [SonarQube Documentation](https://docs.sonarqube.org/)
- [SonarScanner Documentation](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
- [Flutter Testing](https://docs.flutter.dev/testing)

### Archivos de Configuración

- `sonar-project.properties` - Configuración del proyecto
- `sonar-quality-gate.json` - Configuración de quality gates
- `.github/workflows/sonarqube-analysis.yml` - CI/CD workflow
- `docker-compose.yml` - Configuración de SonarQube
- `.sonarqube/exclusions.conf` - Configuración de exclusiones

### Exclusiones Configuradas

Los siguientes archivos y directorios están excluidos del análisis:

#### 📄 **Archivos de Documentación**
- `*.md`, `docs/`, `README.md`, `CHANGELOG.md`

#### 🔧 **Archivos Generados por Flutter/Dart**
- `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`, `*.gr.dart`, `*.chopper.dart`

#### 🏗️ **Directorios de Build y Generación**
- `build/`, `.dart_tool/`, `generated/`, `.idea/`, `.vscode/`

#### ⚙️ **Archivos de Configuración**
- `*.yaml`, `*.yml`, `*.json`, `*.xml`, `*.properties`, `*.toml`, `*.lock`

#### 📊 **Archivos de Datos y Reportes**
- `*.txt`, `*.csv`, `*.pickle`, `performance_reports/`, `test-reports/`, `coverage/`

#### 🎨 **Archivos de Assets**
- `assets/`, `*.png`, `*.jpg`, `*.gif`, `*.svg`, `*.ico`, `*.ttf`, `*.otf`, `*.pdf`

#### 📱 **Directorios de Plataforma**
- `web/`, `ios/`, `android/`, `linux/`, `macos/`, `windows/`

#### 🔄 **CI/CD y Herramientas**
- `.github/`, `sonar-plugins/`, `ollama_proxy/`

#### 📁 **Directorios de Datos**
- `data/`

#### 🛠️ **Scripts y Herramientas**
- `*.sh`, `*.py`, `*.jar`

### Scripts Disponibles

- `scripts/run_sonarqube_analysis.sh` - Análisis completo
- `scripts/analyze_critical_issues.sh` - Análisis de issues críticos

## 📞 Soporte

Para problemas o preguntas:

1. Revisar este documento
2. Verificar logs de SonarQube
3. Consultar documentación oficial
4. Crear issue en el repositorio

---

*Última actualización: 9 de Octubre, 2025*
