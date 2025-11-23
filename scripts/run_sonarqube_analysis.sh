#!/bin/bash

# Script para ejecutar análisis completo de SonarQube
# Autor: TempoSage Team
# Fecha: 9 de Octubre, 2025

set -e

echo "🔍 Iniciando análisis de calidad de código con SonarQube..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Docker esté disponible
if ! command -v docker &> /dev/null; then
    log_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

# Verificar que docker-compose esté disponible
if ! command -v docker-compose &> /dev/null; then
    log_error "docker-compose no está instalado. Por favor instala docker-compose primero."
    exit 1
fi

# Verificar que sonar-scanner esté disponible
if ! command -v sonar-scanner &> /dev/null; then
    log_error "sonar-scanner no está instalado. Instalando..."
    curl -sSLo /tmp/sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
    sudo unzip -q /tmp/sonar-scanner-cli.zip -d /opt
    sudo ln -sf /opt/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner /usr/local/bin/
    log_success "sonar-scanner instalado correctamente"
fi

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.."

log_info "Directorio de trabajo: $(pwd)"

# Paso 1: Iniciar SonarQube
log_info "Iniciando SonarQube con Docker Compose..."
docker-compose up -d

# Esperar a que SonarQube esté listo
log_info "Esperando a que SonarQube esté operativo..."
sleep 30

# Verificar que SonarQube esté funcionando
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:9000/api/system/status | grep -q "UP"; then
        log_success "SonarQube está operativo"
        break
    fi
    log_info "Esperando SonarQube... (intento $((attempt + 1))/$max_attempts)"
    sleep 10
    ((attempt++))
done

if [ $attempt -eq $max_attempts ]; then
    log_error "SonarQube no se pudo iniciar en el tiempo esperado"
    exit 1
fi

# Paso 2: Ejecutar pruebas y generar cobertura
log_info "Ejecutando pruebas y generando cobertura..."
if flutter test --coverage; then
    log_success "Pruebas ejecutadas y cobertura generada"
else
    log_warning "Algunas pruebas fallaron, pero continuando con el análisis..."
fi

# Paso 3: Obtener token de autenticación
log_info "Obteniendo token de autenticación..."
TOKEN=$(curl -u admin:admin -X POST "http://localhost:9000/api/user_tokens/generate?name=temposage-token&type=GLOBAL_ANALYSIS_TOKEN" | jq -r '.token')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    log_error "No se pudo obtener el token de autenticación"
    exit 1
fi

log_success "Token obtenido correctamente"

# Paso 4: Ejecutar análisis de SonarQube
log_info "Ejecutando análisis de SonarQube..."
if sonar-scanner -Dsonar.host.url=http://localhost:9000 -Dsonar.login="$TOKEN" -Dsonar.exclusions="**/*.g.dart,**/*.freezed.dart,**/*.mocks.dart,**/*.gr.dart,**/*.chopper.dart,**/generated/**,**/build/**,**/.dart_tool/**,**/*.md,**/docs/**,**/*.json,**/*.yaml,**/*.yml,**/*.lock,**/*.txt,**/*.csv,**/*.pickle,**/performance_reports/**,**/test-reports/**,**/coverage/**,**/web/**,**/ios/**,**/android/**,**/linux/**,**/macos/**,**/windows/**,**/.github/**,**/sonar-plugins/**,**/ollama_proxy/**,**/data/**,**/assets/**,**/*.xml,**/*.properties,**/*.toml,**/*.sh,**/*.py,**/*.jar,**/*.pdf,**/*.jpg,**/*.png,**/*.gif,**/*.svg,**/*.ico,**/*.ttf,**/*.otf"; then
    log_success "Análisis de SonarQube completado exitosamente"
else
    log_error "El análisis de SonarQube falló"
    exit 1
fi

# Paso 5: Obtener métricas del análisis
log_info "Obteniendo métricas del análisis..."
METRICS=$(curl -u admin:admin "http://localhost:9000/api/measures/component?component=temposage-movil&metricKeys=ncloc,coverage,duplicated_lines_density,security_hotspots,code_smells,bugs,vulnerabilities,reliability_rating,security_rating" 2>/dev/null)

if [ $? -eq 0 ]; then
    log_success "Métricas obtenidas correctamente"
    echo "$METRICS" | jq '.'
else
    log_warning "No se pudieron obtener las métricas"
fi

# Paso 6: Generar reporte
log_info "Generando reporte de análisis..."
REPORT_FILE="docs/REPORTE_SONARQUBE_$(date +%Y%m%d_%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# REPORTE DE ANÁLISIS SONARQUBE - $(date)

## Resumen Ejecutivo
- **Proyecto:** TempoSageMovil
- **Fecha:** $(date)
- **Estado:** Análisis completado

## Métricas Principales
$(echo "$METRICS" | jq -r '.component.measures[] | "- **\(.metric):** \(.value)"')

## Enlaces
- **Dashboard:** http://localhost:9000/dashboard?id=temposage-movil
- **Proyecto:** http://localhost:9000/project/overview?id=temposage-movil

EOF

log_success "Reporte generado: $REPORT_FILE"

# Paso 7: Mostrar resumen final
log_info "=== RESUMEN DEL ANÁLISIS ==="
echo "✅ SonarQube iniciado y operativo"
echo "✅ Análisis de código completado"
echo "✅ Métricas obtenidas"
echo "✅ Reporte generado"
echo ""
echo "🌐 Accede al dashboard en: http://localhost:9000/dashboard?id=temposage-movil"
echo "📊 Usuario: admin / Contraseña: admin"

log_success "Análisis de SonarQube completado exitosamente!"

# Opcional: Detener SonarQube después del análisis
read -p "¿Deseas detener SonarQube? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Deteniendo SonarQube..."
    docker-compose down
    log_success "SonarQube detenido"
fi
