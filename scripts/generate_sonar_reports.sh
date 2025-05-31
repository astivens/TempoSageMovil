#!/bin/bash

# Colores para salida en terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Crear directorios necesarios
mkdir -p test-reports
mkdir -p coverage

# 1. Ejecutar pruebas unitarias con cobertura
echo -e "${YELLOW}Ejecutando pruebas unitarias con cobertura...${NC}"
flutter test --coverage --machine > tests.output

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Pruebas unitarias completadas correctamente${NC}"
else
  echo -e "${RED}✗ Error en las pruebas unitarias${NC}"
  exit 1
fi

# 2. Convertir el reporte de pruebas a formato XML para SonarQube
echo -e "${YELLOW}Convirtiendo resultados de pruebas a formato XML...${NC}"
python3 -c '
import json
import xml.etree.ElementTree as ET
import sys
import os
from datetime import datetime

# Crear estructura XML
root = ET.Element("testExecutions", {"version": "1"})

try:
    with open("tests.output", "r") as f:
        for line in f:
            if line.strip().startswith("{"):
                try:
                    data = json.loads(line)
                    if data.get("type") == "testDone":
                        test_file = ET.SubElement(root, "file", {"path": data.get("path", "unknown")})
                        test_case = ET.SubElement(test_file, "testCase", {"name": data.get("name", "unknown")})
                        
                        # Si hay error, agregar detalles
                        if data.get("result") != "success":
                            error = ET.SubElement(test_case, "failure", {"message": "Test failed"})
                            if data.get("message"):
                                error.text = data.get("message")
                except json.JSONDecodeError:
                    pass
except Exception as e:
    print(f"Error procesando archivo de pruebas: {e}", file=sys.stderr)
    sys.exit(1)

# Guardar el XML
tree = ET.ElementTree(root)
tree.write("test-reports/test-report.xml", encoding="utf-8", xml_declaration=True)
' 2>/dev/null

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Conversión de resultados completada${NC}"
else
  echo -e "${RED}✗ Error al convertir resultados de pruebas${NC}"
  exit 1
fi

# 3. Generar reporte de cobertura
echo -e "${YELLOW}Procesando reporte de cobertura...${NC}"
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  '**/*.config.dart' \
  '**/l10n/**' \
  '**/*_config.dart' \
  -o coverage/lcov_filtered.info

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Reporte de cobertura procesado correctamente${NC}"
  mv coverage/lcov_filtered.info coverage/lcov.info
else
  echo -e "${YELLOW}⚠ No se pudo procesar el reporte de cobertura, se usará el original${NC}"
fi

# 4. Ejecutar análisis de Dart
echo -e "${YELLOW}Ejecutando análisis de Dart...${NC}"
flutter analyze > analysis-report.txt

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Análisis de Dart completado correctamente${NC}"
else
  echo -e "${YELLOW}⚠ Análisis de Dart completado con advertencias${NC}"
fi

# 5. Convertir el resultado del análisis a un formato que SonarQube pueda leer
echo -e "${YELLOW}Preparando resultados de análisis para SonarQube...${NC}"
cat > sonar-issues.json << EOF
{
  "issues": [
EOF

# Procesar el reporte de análisis y convertirlo a formato JSON para SonarQube
grep -e "info" -e "warning" -e "error" analysis-report.txt | while IFS= read -r line; do
  # Extraer información de la línea
  severity=$(echo "$line" | grep -o -E "info|warning|error")
  message=$(echo "$line" | sed 's/.*• \(.*\) •.*/\1/')
  file_info=$(echo "$line" | grep -o -E "lib/[^ ]*")
  line_number=$(echo "$line" | grep -o -E "[0-9]+:[0-9]+" | cut -d':' -f1)
  
  # Determinar la severidad para SonarQube
  sonar_severity="INFO"
  if [ "$severity" == "warning" ]; then
    sonar_severity="MINOR"
  elif [ "$severity" == "error" ]; then
    sonar_severity="MAJOR"
  fi
  
  # Agregar al archivo JSON
  cat >> sonar-issues.json << ISSUE
  {
    "engineId": "dart",
    "ruleId": "dart:${severity}",
    "severity": "${sonar_severity}",
    "type": "CODE_SMELL",
    "primaryLocation": {
      "message": "${message}",
      "filePath": "${file_info}",
      "textRange": {
        "startLine": ${line_number:-1}
      }
    }
  },
ISSUE
done

# Eliminar la última coma y cerrar el archivo JSON
sed -i '$ s/},/}/' sonar-issues.json
echo -e "  ]\n}" >> sonar-issues.json

echo -e "${GREEN}✓ Generación de reportes completada${NC}"
echo -e "${BLUE}Reportes generados:${NC}"
echo -e " - Pruebas: test-reports/test-report.xml"
echo -e " - Cobertura: coverage/lcov.info"
echo -e " - Análisis: sonar-issues.json"

exit 0 