#!/bin/bash

# Script para ejecutar todas las pruebas de la aplicación TempoSage
# Autor: [Tu Nombre]
# Fecha: [Fecha actual]

# Colores para mejorar la legibilidad
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando pruebas completas de TempoSage Mobile${NC}"
echo "----------------------------------------"

# Función para ejecutar pruebas y verificar resultado
run_test_category() {
  local category=$1
  local test_path=$2
  
  echo -e "${YELLOW}Ejecutando pruebas de $category...${NC}"
  flutter test $test_path
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Pruebas de $category completadas exitosamente${NC}"
  else
    echo -e "${RED}✗ Pruebas de $category fallaron${NC}"
    FAILED_CATEGORIES="$FAILED_CATEGORIES\n- $category"
  fi
  
  echo "----------------------------------------"
}

# Inicializar variable para categorías fallidas
FAILED_CATEGORIES=""

# 1. Pruebas Unitarias
run_test_category "unitarias" "test/unit/"

# 2. Pruebas de Integración
run_test_category "integración de servicios" "test/integration/services/"

# 3. Pruebas de Sistema
echo -e "${YELLOW}Ejecutando pruebas de sistema...${NC}"

# 3.1 Seguridad
run_test_category "seguridad" "test/system/security/"

# 3.2 Rendimiento
run_test_category "rendimiento" "test/system/performance/"

# 3.3 Usabilidad
run_test_category "usabilidad" "test/system/usability/"

# 3.4 Portabilidad
run_test_category "portabilidad" "test/system/portability/"

# 4. Pruebas de Aceptación
run_test_category "aceptación" "test/acceptance/"

# Resumen final
echo -e "${YELLOW}Resumen de pruebas:${NC}"
if [ -z "$FAILED_CATEGORIES" ]; then
  echo -e "${GREEN}✓ Todas las pruebas pasaron exitosamente${NC}"
else
  echo -e "${RED}✗ Las siguientes categorías de pruebas fallaron:${FAILED_CATEGORIES}${NC}"
  exit 1
fi

echo "----------------------------------------"
echo -e "${GREEN}Pruebas completadas.${NC}"
exit 0 