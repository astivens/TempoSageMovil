#!/bin/bash

# Colores para salida en terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Crear directorios para informes
mkdir -p test-reports
mkdir -p coverage

echo -e "${BLUE}======================${NC}"
echo -e "${BLUE}= EJECUTANDO PRUEBAS =${NC}"
echo -e "${BLUE}======================${NC}"

# 1. Ejecutar pruebas unitarias
echo -e "\n${YELLOW}Ejecutando pruebas unitarias...${NC}"
flutter test test/unit/ --coverage

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Pruebas unitarias completadas correctamente${NC}"
else
  echo -e "${RED}✗ Error en las pruebas unitarias${NC}"
fi

# 2. Ejecutar pruebas de widgets
echo -e "\n${YELLOW}Ejecutando pruebas de widgets...${NC}"
flutter test test/widget/ --coverage

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Pruebas de widgets completadas correctamente${NC}"
else
  echo -e "${RED}✗ Error en las pruebas de widgets${NC}"
fi

# 3. Ejecutar pruebas de sistema
echo -e "\n${YELLOW}Ejecutando pruebas de sistema...${NC}"
flutter test test/system/ --coverage

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Pruebas de sistema completadas correctamente${NC}"
else
  echo -e "${RED}✗ Error en las pruebas de sistema. Verificar errores.${NC}"
fi

# 4. Ejecutar pruebas de integración
echo -e "\n${YELLOW}Ejecutando pruebas de integración...${NC}"
flutter test test/integration/ --coverage

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Pruebas de integración completadas correctamente${NC}"
else
  echo -e "${RED}✗ Error en las pruebas de integración. Verificar errores.${NC}"
fi

# 5. Generar informe de cobertura en formato LCOV
echo -e "\n${YELLOW}Generando informe de cobertura...${NC}"
genhtml coverage/lcov.info -o coverage/html

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Informe de cobertura generado correctamente${NC}"
  echo -e "${BLUE}Ver informe en: coverage/html/index.html${NC}"
else
  echo -e "${RED}✗ Error al generar informe de cobertura${NC}"
fi

# 6. Preparar informes para SonarQube
echo -e "\n${YELLOW}Preparando informes para SonarQube...${NC}"
./scripts/generate_sonar_reports.sh

echo -e "\n${GREEN}¡Proceso de pruebas completado!${NC}"
echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}= RESUMEN DE PRUEBAS COMPLETADAS =${NC}"
echo -e "${BLUE}==================================${NC}"
echo -e "Ver detalles en los informes generados." 