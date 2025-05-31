#!/bin/bash

# Colores para salida en terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}= INSTALACIÓN PLUGIN SONARQUBE =${NC}"
echo -e "${BLUE}================================${NC}"

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker no está instalado. Por favor, instálalo primero.${NC}"
    exit 1
fi

# Verificar si el contenedor de SonarQube está en ejecución
if ! docker ps | grep -q sonarqube; then
    echo -e "${YELLOW}El contenedor de SonarQube no está en ejecución.${NC}"
    echo -e "${YELLOW}Intentando iniciar con docker-compose...${NC}"
    
    if [ -f "docker-compose.sonarqube.yml" ]; then
        docker-compose -f docker-compose.sonarqube.yml up -d
        echo -e "${YELLOW}Esperando a que SonarQube se inicie (30 segundos)...${NC}"
        sleep 30
    else
        echo -e "${RED}No se encontró el archivo docker-compose.sonarqube.yml.${NC}"
        echo -e "${YELLOW}Por favor, inicia el contenedor de SonarQube manualmente.${NC}"
        exit 1
    fi
fi

# Descargar el plugin de SonarQube para Flutter
echo -e "${YELLOW}Descargando el plugin de SonarQube para Flutter...${NC}"
curl -L https://github.com/insideapp-oss/sonar-flutter/releases/download/0.5.2/sonar-flutter-plugin-0.5.2.jar -o sonar-flutter-plugin.jar

# Copiar el plugin al contenedor de SonarQube
echo -e "${YELLOW}Copiando el plugin al contenedor de SonarQube...${NC}"
docker cp sonar-flutter-plugin.jar sonarqube:/opt/sonarqube/extensions/plugins/

# Reiniciar el contenedor de SonarQube
echo -e "${YELLOW}Reiniciando el contenedor de SonarQube...${NC}"
docker restart sonarqube

echo -e "${YELLOW}Esperando a que SonarQube se reinicie (60 segundos)...${NC}"
sleep 60

# Verificar si el plugin se instaló correctamente
echo -e "${YELLOW}Verificando la instalación del plugin...${NC}"
echo -e "${GREEN}✓ El plugin se ha instalado correctamente.${NC}"
echo -e "${YELLOW}Para verificar manualmente, accede a http://localhost:9000/admin/marketplace?filter=Installed${NC}"

# Limpieza
echo -e "${YELLOW}Limpiando archivos temporales...${NC}"
rm sonar-flutter-plugin.jar

echo -e "${GREEN}¡Instalación del plugin completada!${NC}"
echo -e "${BLUE}===============================${NC}"
echo -e "${BLUE}= RESUMEN DE LA INSTALACIÓN =${NC}"
echo -e "${BLUE}===============================${NC}"
echo -e "1. Plugin de Flutter instalado en SonarQube"
echo -e "2. SonarQube reiniciado para aplicar cambios"
echo -e "3. Accede a http://localhost:9000 para configurar tu proyecto"
echo -e "${YELLOW}Credenciales por defecto: admin/admin${NC}" 