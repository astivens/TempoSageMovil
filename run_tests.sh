#!/bin/bash

# Colores para los resultados
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}   Ejecutando pruebas de TempoSage    ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Crear archivos temporales para guardar la salida completa y resultados JSON
TEMP_OUTPUT=$(mktemp)
JSON_OUTPUT=$(mktemp)

# Ejecutar las pruebas con reportero JSON para contar resultados
echo -e "${YELLOW}Ejecutando pruebas... (puede tomar un momento)${NC}"

# Ejecutar las pruebas mostrando todos los logs
{ flutter test --reporter expanded $@ 2>&1 | tee $TEMP_OUTPUT; } &
{ flutter test --reporter json $@ > $JSON_OUTPUT; } &
wait

# Obtener código de salida
EXIT_CODE=0
if grep -q "Some tests failed" $TEMP_OUTPUT || grep -q "Test failed" $TEMP_OUTPUT; then
  EXIT_CODE=1
fi

# Contar pruebas usando el JSON
if [ -s "$JSON_OUTPUT" ]; then
  # Contar el número de entradas en el JSON (cada una es una prueba)
  TEST_COUNT=$(grep -o '"testID":' $JSON_OUTPUT | wc -l)
  FAILED_COUNT=$(grep -o '"success":false' $JSON_OUTPUT | wc -l)
  PASSED_COUNT=$((TEST_COUNT - FAILED_COUNT))
  
  # Si no hay pruebas en el JSON, intenta extraer los números de la salida principal
  if [ "$TEST_COUNT" -eq 0 ]; then
    if [[ $(cat $TEMP_OUTPUT) =~ All\ tests\ passed ]]; then
      # Buscar la última línea con el formato "+X"
      LAST_LINE=$(grep -E "[0-9]+:[0-9]+ \+[0-9]+" $TEMP_OUTPUT | tail -1)
      if [[ $LAST_LINE =~ \+([0-9]+) ]]; then
        TEST_COUNT=${BASH_REMATCH[1]}
        PASSED_COUNT=$TEST_COUNT
        FAILED_COUNT=0
      fi
    else
      TEST_COUNT="?"
      PASSED_COUNT="?"
      FAILED_COUNT="?"
    fi
  fi
else
  # Si el JSON está vacío, intenta extraer los números de la salida principal
  if [[ $(cat $TEMP_OUTPUT) =~ All\ tests\ passed ]]; then
    # Buscar la última línea con el formato "+X"
    LAST_LINE=$(grep -E "[0-9]+:[0-9]+ \+[0-9]+" $TEMP_OUTPUT | tail -1)
    if [[ $LAST_LINE =~ \+([0-9]+) ]]; then
      TEST_COUNT=${BASH_REMATCH[1]}
      PASSED_COUNT=$TEST_COUNT
      FAILED_COUNT=0
    fi
  else
    TEST_COUNT="?"
    PASSED_COUNT="?"
    FAILED_COUNT="?"
  fi
fi

# Mostrar resumen
echo -e "\n${BLUE}=======================================${NC}"
echo -e "${BLUE}      Resumen de las pruebas      ${NC}"
echo -e "${BLUE}=======================================${NC}"

if [ "$EXIT_CODE" -eq 0 ]; then
  echo -e "${GREEN}✓ Todas las pruebas pasaron${NC}"
else
  echo -e "${RED}✗ Algunas pruebas fallaron${NC}"
fi

echo -e "\n${BLUE}Total de pruebas:${NC} $TEST_COUNT"
echo -e "${GREEN}Pruebas exitosas:${NC} $PASSED_COUNT"

if [ "$FAILED_COUNT" = "0" ] || [ "$FAILED_COUNT" = "?" ]; then
  echo -e "${GREEN}Pruebas fallidas:${NC} $FAILED_COUNT"
else
  echo -e "${RED}Pruebas fallidas:${NC} $FAILED_COUNT"
  
  # Extraer los nombres de las pruebas fallidas
  echo -e "\n${RED}Detalles de fallos:${NC}"
  grep -B 2 -A 2 "\[E\]" $TEMP_OUTPUT | sed 's/^/  /'
fi

# Mostrar cobertura si se especificó
if [[ "$*" == *"--coverage"* ]]; then
  echo -e "\n${BLUE}Generando reporte de cobertura...${NC}"
  if command -v genhtml > /dev/null; then
    genhtml coverage/lcov.info -o coverage/html > /dev/null 2>&1
    echo -e "${GREEN}Reporte de cobertura generado en:${NC} coverage/html/index.html"
  else
    echo -e "${YELLOW}⚠️ genhtml no está instalado. Instálalo para generar reportes HTML:${NC}"
    echo "  sudo apt-get install lcov   # Para Ubuntu/Debian"
    echo "  brew install lcov           # Para macOS"
  fi
fi

# Mostrar el tiempo total que tomó la ejecución
if [ -f "$TEMP_OUTPUT" ]; then
  LAST_LINE=$(grep -E "[0-9]+:[0-9]+ \+[0-9]+" $TEMP_OUTPUT | tail -1)
  if [[ $LAST_LINE =~ ([0-9]+):([0-9]+) ]]; then
    MINUTES=${BASH_REMATCH[1]}
    SECONDS=${BASH_REMATCH[2]}
    if [ "$MINUTES" != "00" ]; then
      echo -e "${BLUE}Tiempo de ejecución:${NC} ${MINUTES}m ${SECONDS}s"
    else
      echo -e "${BLUE}Tiempo de ejecución:${NC} ${SECONDS}s"
    fi
  fi
fi

# Limpiar
rm $TEMP_OUTPUT $JSON_OUTPUT

exit $EXIT_CODE 