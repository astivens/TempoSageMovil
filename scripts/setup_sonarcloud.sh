#!/bin/bash

# Script de configuración rápida para SonarCloud
# Este script te guiará paso a paso para configurar SonarCloud

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}= CONFIGURACIÓN DE SONARCLOUD =${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar que estamos en el directorio del proyecto
if [ ! -f "sonar-project.properties" ]; then
    echo -e "${RED}Error: No se encontró sonar-project.properties${NC}"
    echo -e "${YELLOW}Ejecuta este script desde el directorio raíz del proyecto${NC}"
    exit 1
fi

echo -e "${CYAN}Paso 1: Información del repositorio${NC}"
echo -e "Repositorio detectado:"
git remote -v 2>/dev/null | head -1 || echo -e "${YELLOW}No se encontró repositorio remoto${NC}"
echo ""

echo -e "${CYAN}Paso 2: Configuración de SonarCloud${NC}"
echo -e "${YELLOW}Necesitas tener:${NC}"
echo "  1. Una cuenta en SonarCloud (https://sonarcloud.io)"
echo "  2. Una organización creada en SonarCloud"
echo "  3. Un proyecto creado en SonarCloud vinculado a este repositorio"
echo "  4. Un token de análisis generado"
echo ""

read -p "¿Ya tienes una organización en SonarCloud? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Pasos para crear organización:${NC}"
    echo "  1. Ve a https://sonarcloud.io"
    echo "  2. Inicia sesión con GitHub"
    echo "  3. Crea una nueva organización"
    echo "  4. Elige el plan 'Free' (gratis para proyectos open source)"
    echo ""
    read -p "Presiona Enter cuando hayas creado la organización..."
fi

echo ""
echo -e "${CYAN}Paso 3: Configurar organización y proyecto${NC}"
echo -e "${YELLOW}Ingresa la clave de tu organización en SonarCloud:${NC}"
echo -e "${YELLOW}(La encuentras en la URL: https://sonarcloud.io/organizations/ORG_KEY)${NC}"
read -p "Organización (org-key): " ORG_KEY

if [ -z "$ORG_KEY" ]; then
    echo -e "${RED}Error: La organización no puede estar vacía${NC}"
    exit 1
fi

# Actualizar sonar-project.properties
echo ""
echo -e "${BLUE}Actualizando sonar-project.properties...${NC}"

# Backup del archivo original
cp sonar-project.properties sonar-project.properties.backup

# Actualizar organización y project key
sed -i "s/your-org-key/$ORG_KEY/g" sonar-project.properties

echo -e "${GREEN}✓ Archivo actualizado${NC}"
echo ""

echo -e "${CYAN}Paso 4: Configurar token de SonarCloud${NC}"
echo -e "${YELLOW}Para obtener tu token:${NC}"
echo "  1. Ve a https://sonarcloud.io/account/security"
echo "  2. En 'Generate Tokens', crea un nuevo token"
echo "  3. Name: temposage-analysis-token"
echo "  4. Type: Global Analysis Token"
echo "  5. Copia el token generado"
echo ""

read -p "¿Quieres configurar el token ahora? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Pega tu token de SonarCloud (no se mostrará en pantalla):${NC}"
    read -s SONAR_TOKEN
    
    if [ -z "$SONAR_TOKEN" ]; then
        echo -e "${RED}Error: El token no puede estar vacío${NC}"
        exit 1
    fi
    
    # Añadir a .zshrc o .bashrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "SONAR_TOKEN" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# SonarCloud Token" >> "$HOME/.zshrc"
            echo "export SONAR_TOKEN=\"$SONAR_TOKEN\"" >> "$HOME/.zshrc"
            echo -e "${GREEN}✓ Token añadido a ~/.zshrc${NC}"
        else
            echo -e "${YELLOW}Token ya existe en ~/.zshrc, actualizando...${NC}"
            sed -i "s/export SONAR_TOKEN=.*/export SONAR_TOKEN=\"$SONAR_TOKEN\"/" "$HOME/.zshrc"
        fi
        source "$HOME/.zshrc" 2>/dev/null || true
    elif [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "SONAR_TOKEN" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# SonarCloud Token" >> "$HOME/.bashrc"
            echo "export SONAR_TOKEN=\"$SONAR_TOKEN\"" >> "$HOME/.bashrc"
            echo -e "${GREEN}✓ Token añadido a ~/.bashrc${NC}"
        else
            echo -e "${YELLOW}Token ya existe en ~/.bashrc, actualizando...${NC}"
            sed -i "s/export SONAR_TOKEN=.*/export SONAR_TOKEN=\"$SONAR_TOKEN\"/" "$HOME/.bashrc"
        fi
        source "$HOME/.bashrc" 2>/dev/null || true
    fi
    
    export SONAR_TOKEN="$SONAR_TOKEN"
    echo -e "${GREEN}✓ Token configurado para esta sesión${NC}"
fi

echo ""
echo -e "${CYAN}Paso 5: Configurar GitHub Secrets (para CI/CD)${NC}"
echo -e "${YELLOW}Para que GitHub Actions funcione, necesitas:${NC}"
echo "  1. Ir a tu repositorio en GitHub: https://github.com/astivens/TempoSageMovil"
echo "  2. Settings > Secrets and variables > Actions"
echo "  3. New repository secret"
echo "  4. Name: SONAR_TOKEN"
echo "  5. Value: Tu token de SonarCloud (el mismo que configuraste arriba)"
echo ""

read -p "¿Ya configuraste el secreto en GitHub? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}No olvides configurarlo para que GitHub Actions funcione${NC}"
fi

echo ""
echo -e "${CYAN}Paso 6: Verificar configuración${NC}"
echo ""

# Verificar sonar-project.properties
if grep -q "your-org-key" sonar-project.properties; then
    echo -e "${RED}✗ Aún hay 'your-org-key' en sonar-project.properties${NC}"
else
    echo -e "${GREEN}✓ sonar-project.properties configurado correctamente${NC}"
fi

# Verificar token
if [ -z "$SONAR_TOKEN" ] && [ -z "${SONAR_TOKEN:-}" ]; then
    echo -e "${YELLOW}⚠ Token no configurado en esta sesión${NC}"
    echo -e "${YELLOW}  Configúralo con: export SONAR_TOKEN=tu_token${NC}"
else
    echo -e "${GREEN}✓ Token configurado${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}= RESUMEN DE CONFIGURACIÓN =${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}Configuración actual:${NC}"
echo "  Organización: $ORG_KEY"
echo "  Project Key: $ORG_KEY:temposage-movil"
echo "  Repositorio: https://github.com/astivens/TempoSageMovil"
echo ""
echo -e "${CYAN}Próximos pasos:${NC}"
echo "  1. Verifica que el proyecto esté creado en SonarCloud"
echo "  2. Configura el secreto SONAR_TOKEN en GitHub"
echo "  3. Prueba el análisis localmente:"
echo "     flutter test --coverage"
echo "     ./scripts/run_sonarqube.sh"
echo "  4. Haz un push para activar GitHub Actions"
echo ""
echo -e "${GREEN}¡Configuración completada!${NC}"
echo -e "${BLUE}Ver más detalles en: docs/CONFIGURACION_SONARCLOUD.md${NC}"

