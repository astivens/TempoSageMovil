#!/bin/bash

# Script opcional para comprimir PNG adicionalmente después de la exportación
# Esto reduce aún más el tamaño de los archivos PNG sin pérdida notable de calidad
#
# Requisitos:
# - optipng: sudo pacman -S optipng (EndeavourOS/Arch)
# - pngquant: sudo pacman -S pngquant (EndeavourOS/Arch)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PNG_DIR="$PROJECT_ROOT/docs/diagrams/images/png"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Optimizador de PNG - PlantUML${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar que el directorio existe
if [ ! -d "$PNG_DIR" ]; then
    echo -e "${RED}Error:${NC} Directorio no encontrado: $PNG_DIR"
    exit 1
fi

# Contar archivos PNG
PNG_COUNT=$(find "$PNG_DIR" -name "*.png" | wc -l)

if [ "$PNG_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Advertencia:${NC} No se encontraron archivos PNG en $PNG_DIR"
    exit 0
fi

echo -e "${GREEN}Encontrados${NC} $PNG_COUNT archivo(s) PNG"
echo ""

# Calcular tamaño antes
SIZE_BEFORE=$(du -sh "$PNG_DIR" 2>/dev/null | awk '{print $1}')
echo -e "Tamaño antes: ${BLUE}$SIZE_BEFORE${NC}"
echo ""

# Verificar herramientas disponibles
HAS_OPTIPNG=false
HAS_PNGQUANT=false

if command -v optipng &> /dev/null; then
    HAS_OPTIPNG=true
    echo -e "${GREEN}✓${NC} optipng disponible"
else
    echo -e "${YELLOW}⚠${NC} optipng no disponible (compresión sin pérdida no aplicada)"
    echo "  Instalar: sudo pacman -S optipng"
fi

if command -v pngquant &> /dev/null; then
    HAS_PNGQUANT=true
    echo -e "${GREEN}✓${NC} pngquant disponible"
else
    echo -e "${YELLOW}⚠${NC} pngquant no disponible (compresión adicional no aplicada)"
    echo "  Instalar: sudo pacman -S pngquant"
fi

echo ""

if [ "$HAS_OPTIPNG" = false ] && [ "$HAS_PNGQUANT" = false ]; then
    echo -e "${RED}Error:${NC} No hay herramientas de compresión disponibles"
    echo ""
    echo "Instalar herramientas:"
    echo "  sudo pacman -S optipng pngquant  # EndeavourOS/Arch"
    exit 1
fi

# Función para comprimir con optipng (sin pérdida)
compress_optipng() {
    local file="$1"
    echo -e "  ${BLUE}→${NC} Comprimiendo con optipng (sin pérdida)..."
    optipng -o7 -quiet -preserve "$file" 2>&1 || true
}

# Función para comprimir con pngquant (con pérdida mínima)
compress_pngquant() {
    local file="$1"
    echo -e "  ${BLUE}→${NC} Comprimiendo con pngquant (calidad 85-95%)..."
    pngquant --quality=85-95 --ext .png --force --quiet "$file" 2>&1 || true
}

# Procesar cada archivo PNG
COMPRESSED=0

while IFS= read -r -d '' png_file; do
    basename=$(basename "$png_file")
    echo -e "${BLUE}Procesando:${NC} $basename"
    
    file_size_before=$(du -h "$png_file" | awk '{print $1}')
    
    # Aplicar compresión sin pérdida primero
    if [ "$HAS_OPTIPNG" = true ]; then
        compress_optipng "$png_file"
    fi
    
    # Aplicar compresión adicional con pngquant (opcional - comenta si prefieres solo sin pérdida)
    # if [ "$HAS_PNGQUANT" = true ]; then
    #     compress_pngquant "$png_file"
    # fi
    
    file_size_after=$(du -h "$png_file" | awk '{print $1}')
    
    echo -e "  ${GREEN}✓${NC} $basename: $file_size_before → $file_size_after"
    echo ""
    
    COMPRESSED=$((COMPRESSED + 1))
done < <(find "$PNG_DIR" -name "*.png" -type f -print0)

# Calcular tamaño después
SIZE_AFTER=$(du -sh "$PNG_DIR" 2>/dev/null | awk '{print $1}')

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Optimización completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Archivos procesados: ${BLUE}$COMPRESSED${NC}"
echo -e "Tamaño antes: ${BLUE}$SIZE_BEFORE${NC}"
echo -e "Tamaño después: ${BLUE}$SIZE_AFTER${NC}"
echo ""
echo -e "${YELLOW}Nota:${NC} Se usa solo compresión sin pérdida (optipng)"
echo -e "      Para compresión adicional, descomenta pngquant en el script"
echo ""

