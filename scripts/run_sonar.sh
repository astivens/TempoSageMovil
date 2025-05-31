#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Iniciando análisis de SonarQube...${NC}"

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker no está instalado.${NC}"
    echo "Por favor, instala Docker siguiendo las instrucciones en:"
    echo "https://docs.docker.com/engine/install/"
    exit 1
fi

# Verificar que SonarQube esté corriendo
if ! docker ps | grep -q sonarqube; then
    echo "Iniciando SonarQube..."
    docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
    echo "Esperando a que SonarQube esté listo..."
    sleep 30
fi

# Ejecutar tests con cobertura
echo "Ejecutando tests con cobertura..."
flutter test --coverage

# Convertir el reporte de cobertura a formato LCOV
echo "Generando reporte LCOV..."
lcov --remove coverage/lcov.info '**/*.g.dart' '**/*.freezed.dart' '**/*.mocks.dart' -o coverage/lcov.info

# Ejecutar análisis de código
echo "Ejecutando análisis de código..."
# dart run dart_code_metrics:metrics analyze lib --reporter=json > build/analyzer-report.json

# Ejecutar sonar-scanner usando Docker
echo "Ejecutando sonar-scanner..."
docker run \
    --rm \
    --network="host" \
    -e SONAR_HOST_URL="http://localhost:9000" \
    -e SONAR_TOKEN="squ_2ebfdc46fea11b6aa6f91ff3db1762cfbc6a2036" \
    -v "$(pwd):/usr/src" \
    sonarsource/sonar-scanner-cli

echo -e "${GREEN}¡Análisis completado!${NC}"
echo "Revisa los resultados en http://localhost:9000"
echo "Usuario por defecto: admin"
echo "Contraseña por defecto: admin"
echo "Nota: El token de SonarQube está configurado" 