#!/bin/bash

# Colores para salida en terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ruta al nuevo SonarScanner
SONAR_SCANNER_PATH="$HOME/sonar-scanner-new/bin/sonar-scanner"

# Verificar si el nuevo SonarScanner existe
if [ ! -f "$SONAR_SCANNER_PATH" ]; then
    echo -e "${RED}No se encontró el nuevo SonarScanner en $SONAR_SCANNER_PATH${NC}"
    echo -e "${YELLOW}Asegúrate de que la ruta sea correcta${NC}"
    exit 1
fi

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
SONAR_HOST_URL=${SONAR_HOST_URL:-"http://localhost:9000"}

# Intentar obtener el token de varias fuentes
if [ -z "$SONAR_TOKEN" ] && [ -f "$HOME/.sonar/token" ]; then
    SONAR_TOKEN=$(cat "$HOME/.sonar/token")
    echo -e "${YELLOW}Usando token desde archivo $HOME/.sonar/token${NC}"
fi

SONAR_TOKEN=${SONAR_TOKEN:-""}

# Verificar si el token está configurado
if [ -z "$SONAR_TOKEN" ]; then
    echo -e "${YELLOW}ADVERTENCIA: No se ha configurado SONAR_TOKEN. El análisis podría fallar si el servidor requiere autenticación.${NC}"
    echo -e "${YELLOW}Puede configurar el token así: export SONAR_TOKEN=tu_token${NC}"
fi

# Ejecutar SonarQube Scanner
echo -e "${YELLOW}Ejecutando análisis con SonarQube Scanner...${NC}"

if [ -z "$SONAR_TOKEN" ]; then
    # Sin token de autenticación
    "$SONAR_SCANNER_PATH" \
        -Dsonar.host.url=$SONAR_HOST_URL
else
    # Con token de autenticación
    "$SONAR_SCANNER_PATH" \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
fi

# Verificar el resultado
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Análisis de SonarQube completado correctamente${NC}"
    echo -e "${BLUE}Puedes ver los resultados en: ${SONAR_HOST_URL}/dashboard?id=temposage-movil${NC}"
else
    echo -e "${RED}✗ Error en el análisis de SonarQube${NC}"
    exit 1
fi

echo -e "\n${GREEN}¡Proceso de análisis completado!${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}= RESUMEN DE ANÁLISIS DE SONARQUBE =${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Ver detalles completos en el panel de SonarQube." 