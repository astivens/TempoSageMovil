#!/bin/bash

# Colores para salida en terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Buscar SonarScanner en varias ubicaciones posibles
if [ -f "$HOME/sonar-scanner-new/bin/sonar-scanner" ]; then
    SONAR_SCANNER_PATH="$HOME/sonar-scanner-new/bin/sonar-scanner"
elif command -v sonar-scanner &> /dev/null; then
    SONAR_SCANNER_PATH="sonar-scanner"
elif [ -f "/opt/sonar-scanner/bin/sonar-scanner" ]; then
    SONAR_SCANNER_PATH="/opt/sonar-scanner/bin/sonar-scanner"
else
    echo -e "${RED}No se encontró SonarScanner${NC}"
    echo -e "${YELLOW}Opciones para instalar:${NC}"
    echo "  1. Descargar desde: https://docs.sonarcloud.io/advanced-setup/ci-based-analysis/sonarscanner/"
    echo "  2. O usar GitHub Actions (ya configurado en .github/workflows/sonarcloud.yml)"
    exit 1
fi

echo -e "${GREEN}Usando SonarScanner: $SONAR_SCANNER_PATH${NC}"

# Verificar si los directorios necesarios existen
if [ ! -d "test-reports" ]; then
    echo -e "${YELLOW}Creando directorio test-reports...${NC}"
    mkdir -p test-reports
fi

if [ ! -d "coverage" ]; then
    echo -e "${YELLOW}Creando directorio coverage...${NC}"
    mkdir -p coverage
fi

# Ejecutar pruebas y generar reportes si no se han generado
if [ ! -f "coverage/lcov.info" ]; then
    echo -e "${YELLOW}No se encontró informe de cobertura. Ejecutando pruebas...${NC}"
    ./scripts/run_tests.sh
fi

echo -e "${BLUE}==========================${NC}"
echo -e "${BLUE}= EJECUTANDO SONARQUBE =${NC}"
echo -e "${BLUE}==========================${NC}"

# Variables de configuración
# Detectar si estamos usando SonarCloud o SonarQube local
if grep -q "sonar.host.url=https://sonarcloud.io" sonar-project.properties 2>/dev/null; then
    SONAR_HOST_URL="https://sonarcloud.io"
    SONAR_TYPE="SonarCloud"
    echo -e "${BLUE}Detectado: SonarCloud${NC}"
else
    SONAR_HOST_URL=${SONAR_HOST_URL:-"http://localhost:9000"}
    SONAR_TYPE="SonarQube"
    echo -e "${BLUE}Detectado: SonarQube local${NC}"
fi

# Intentar obtener el token de varias fuentes
if [ -z "$SONAR_TOKEN" ] && [ -f "$HOME/.sonar/token" ]; then
    SONAR_TOKEN=$(cat "$HOME/.sonar/token")
    echo -e "${YELLOW}Usando token desde archivo $HOME/.sonar/token${NC}"
fi

SONAR_TOKEN=${SONAR_TOKEN:-""}

# Verificar si el token está configurado
if [ -z "$SONAR_TOKEN" ]; then
    echo -e "${RED}ERROR: No se ha configurado SONAR_TOKEN.${NC}"
    if [ "$SONAR_TYPE" = "SonarCloud" ]; then
        echo -e "${YELLOW}Para SonarCloud, configura el token así:${NC}"
        echo -e "${YELLOW}  export SONAR_TOKEN=tu_token_de_sonarcloud${NC}"
        echo -e "${YELLOW}Obtén tu token en: https://sonarcloud.io/account/security${NC}"
    else
        echo -e "${YELLOW}Para SonarQube local, configura el token así:${NC}"
        echo -e "${YELLOW}  export SONAR_TOKEN=tu_token${NC}"
    fi
    exit 1
fi

# Ejecutar SonarQube Scanner
echo -e "${YELLOW}Ejecutando análisis con ${SONAR_TYPE} Scanner...${NC}"

if [ "$SONAR_SCANNER_PATH" = "sonar-scanner" ]; then
    # Si es un comando en PATH, ejecutarlo directamente
    $SONAR_SCANNER_PATH \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
else
    # Si es una ruta absoluta, ejecutarla
    "$SONAR_SCANNER_PATH" \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
fi

# Verificar el resultado
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Análisis de ${SONAR_TYPE} completado correctamente${NC}"
    if [ "$SONAR_TYPE" = "SonarCloud" ]; then
        # Obtener el project key del archivo de propiedades
        PROJECT_KEY=$(grep "^sonar.projectKey=" sonar-project.properties | cut -d'=' -f2)
        ORG_KEY=$(grep "^sonar.organization=" sonar-project.properties | cut -d'=' -f2)
        echo -e "${BLUE}Puedes ver los resultados en: https://sonarcloud.io/project/overview?id=${PROJECT_KEY}${NC}"
    else
        echo -e "${BLUE}Puedes ver los resultados en: ${SONAR_HOST_URL}/dashboard?id=temposage-movil${NC}"
    fi
else
    echo -e "${RED}✗ Error en el análisis de ${SONAR_TYPE}${NC}"
    exit 1
fi

echo -e "\n${GREEN}¡Proceso de análisis completado!${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}= RESUMEN DE ANÁLISIS DE ${SONAR_TYPE} =${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Ver detalles completos en el panel de ${SONAR_TYPE}." 