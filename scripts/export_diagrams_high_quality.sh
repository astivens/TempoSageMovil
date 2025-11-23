#!/bin/bash

# Script para exportar diagramas PlantUML en alta calidad
# Este script genera diagramas en formato SVG (vectorial) y PNG (alta resolución)
# 
# Requisitos:
# - PlantUML instalado (sudo apt install plantuml o brew install plantuml)
# - Java instalado (requerido por PlantUML)

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
DIAGRAMS_DIR="$PROJECT_ROOT/docs/diagrams"
OUTPUT_SVG_DIR="$PROJECT_ROOT/docs/diagrams/images/svg"
OUTPUT_PNG_DIR="$PROJECT_ROOT/docs/diagrams/images/png"
OUTPUT_PDF_DIR="$PROJECT_ROOT/docs/diagrams/images/pdf"

# Crear directorios de salida si no existen
mkdir -p "$OUTPUT_SVG_DIR"
mkdir -p "$OUTPUT_PNG_DIR"
mkdir -p "$OUTPUT_PDF_DIR"

# Limpiar imágenes anteriores para evitar confusión
echo -e "${YELLOW}Limpiando imágenes anteriores...${NC}"
rm -f "$OUTPUT_SVG_DIR"/*.svg
rm -f "$OUTPUT_PNG_DIR"/*.png
rm -f "$OUTPUT_PDF_DIR"/*.pdf
echo -e "${GREEN}✓${NC} Imágenes anteriores eliminadas"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Exportador de Diagramas PlantUML${NC}"
echo -e "${BLUE}Alta Calidad (SVG, PNG, PDF)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar que PlantUML está instalado
if ! command -v plantuml &> /dev/null; then
    echo -e "${RED}Error: PlantUML no está instalado.${NC}"
    
    # Detectar sistema operativo
    if [ -f /etc/arch-release ] || [ -f /etc/endeavouros-release ]; then
        echo -e "${YELLOW}Instalación en EndeavourOS/Arch Linux:${NC}"
        echo "  sudo pacman -S plantuml graphviz"
        echo ""
        echo -e "${YELLOW}Nota:${NC} Graphviz es recomendado para diagramas avanzados"
    elif [ -f /etc/debian_version ]; then
        echo -e "${YELLOW}Instalación en Ubuntu/Debian:${NC}"
        echo "  sudo apt update"
        echo "  sudo apt install plantuml"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}Instalación en macOS:${NC}"
        echo "  brew install plantuml"
    else
        echo -e "${YELLOW}Instalación manual:${NC}"
        echo "  Descargar plantuml.jar desde https://plantuml.com/download"
        echo "  Ejecutar: java -jar plantuml.jar -version"
    fi
    
    echo ""
    echo -e "${YELLOW}Alternativa (solo JAR):${NC}"
    echo "  Descargar plantuml.jar desde https://plantuml.com/download"
    echo "  Guardar en directorio accesible y usar directamente con java"
    exit 1
fi

# Verificar versión de PlantUML
PLANTUML_VERSION=$(plantuml -version 2>&1 | head -n 1 || echo "unknown")
echo -e "${GREEN}PlantUML detectado:${NC} $PLANTUML_VERSION"
echo ""

# Función para redimensionar PNG a dimensiones específicas
resize_png_to_target_size() {
    local png_file="$1"
    local basename="$2"
    local width=""
    local height=""
    
    # Determinar dimensiones según el nombre del archivo
    case "$basename" in
        *Use_Case_Diagram_Authentication*|*Use_Case_Diagram_Dashboard*|*Use_Case_Diagram_AI*)
            width=2000
            height=2000
            ;;
        *Sequence_Diagram_Activity_Creation*|*Sequence_Diagram_Task_Management*|*Sequence_Diagram_Recommendations*|*Sequence_Diagram_Dashboard_Refresh*)
            width=1600
            height=2400
            ;;
        *Sequence_Diagram_Auth*|*Class_Diagram_Core_Domain*|*Class_Diagram_Data_Layer*|*Class_Diagram_Presentation_Services*|*Entity_Relationship_Diagram_Core_Entities*|*Entity_Relationship_Diagram_Config_Analytics*|*Use_Case_Diagram_Management*)
            width=1800
            height=2700
            ;;
        TempoSage_Use_Case_Diagram|TempoSage_Entity_Relationship_Diagram|TempoSage_Component_Diagram|TempoSage_Sequence_Diagram)
            width=2000
            height=3000
            ;;
        TempoSage_Sequence_Diagram_Daily_Flow|TempoSage_Class_Diagram)
            width=2200
            height=3300
            ;;
        *Use_Case_Diagram|*Entity_Relationship_Diagram|*Component_Diagram|*Sequence_Diagram)
            width=2000
            height=3000
            ;;
        *)
            # Si no coincide, no redimensionar
            return 0
            ;;
    esac
    
    # Verificar si ImageMagick está disponible
    if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
        echo -e "  ${YELLOW}⚠${NC} ImageMagick no disponible, saltando redimensionamiento"
        return 0
    fi
    
    # Redimensionar usando ImageMagick
    local convert_cmd="magick"
    if ! command -v magick &> /dev/null; then
        convert_cmd="convert"
    fi
    
    echo -e "  ${BLUE}→${NC} Redimensionando a ${width}x${height}px..."
    $convert_cmd "$png_file" -resize "${width}x${height}" -background white -gravity center -extent "${width}x${height}" "$png_file" 2>&1 | grep -v -E "\[OK\]|WARNING" || true
}

# Función para exportar un diagrama
export_diagram() {
    local puml_file="$1"
    local basename=$(basename "$puml_file" .puml)
    local dirname=$(dirname "$puml_file")
    
    echo -e "${BLUE}Procesando:${NC} $basename"
    
    # Cambiar al directorio del archivo para que las rutas relativas funcionen
    cd "$dirname"
    
    # Exportar a SVG (vectorial, mejor calidad)
    echo -e "  ${GREEN}→${NC} Exportando SVG..."
    plantuml -tsvg -o "$OUTPUT_SVG_DIR" "$puml_file" 2>&1 | grep -v "\[OK\]" || true
    
    # Exportar a PNG con resolución optimizada (400 DPI - legibilidad en diagramas grandes)
    echo -e "  ${GREEN}→${NC} Exportando PNG (400 DPI - optimizado)..."
    plantuml -tpng -SDPI=400 -DPLANTUML_LIMIT_SIZE=8192 -o "$OUTPUT_PNG_DIR" "$puml_file" 2>&1 | grep -v "\[OK\]" || true
    
    # Redimensionar PNG a dimensiones específicas según el archivo
    local basename=$(basename "$puml_file" .puml)
    local png_output="$OUTPUT_PNG_DIR/$basename.png"
    if [ -f "$png_output" ]; then
        resize_png_to_target_size "$png_output" "$basename"
    fi
    
    # Exportar a PDF (alta calidad)
    echo -e "  ${GREEN}→${NC} Exportando PDF..."
    plantuml -tpdf -o "$OUTPUT_PDF_DIR" "$puml_file" 2>&1 | grep -v "\[OK\]" || true
    
    # Volver al directorio original
    cd "$PROJECT_ROOT"
    
    echo -e "  ${GREEN}✓${NC} Completado: $basename"
    echo ""
}

# Función para exportar usando plantuml.jar directamente (más control)
export_diagram_jar() {
    local puml_file="$1"
    local basename=$(basename "$puml_file" .puml)
    local dirname=$(dirname "$puml_file")
    
    # Buscar plantuml.jar
    PLANTUML_JAR=""
    if [ -f "$HOME/.local/share/plantuml/plantuml.jar" ]; then
        PLANTUML_JAR="$HOME/.local/share/plantuml/plantuml.jar"
    elif [ -f "/usr/share/plantuml/plantuml.jar" ]; then
        PLANTUML_JAR="/usr/share/plantuml/plantuml.jar"
    elif [ -f "/opt/plantuml/plantuml.jar" ]; then
        PLANTUML_JAR="/opt/plantuml/plantuml.jar"
    elif [ -f "$PROJECT_ROOT/plantuml.jar" ]; then
        PLANTUML_JAR="$PROJECT_ROOT/plantuml.jar"
    fi
    
    if [ -z "$PLANTUML_JAR" ]; then
        echo -e "${YELLOW}Advertencia:${NC} plantuml.jar no encontrado. Usando comando plantuml."
        export_diagram "$puml_file"
        return
    fi
    
    echo -e "${BLUE}Procesando (JAR):${NC} $basename"
    
    cd "$dirname"
    
    # SVG con configuraciones adicionales (formato recomendado - más pequeño)
    echo -e "  ${GREEN}→${NC} Exportando SVG (formato recomendado)..."
    java -Djava.awt.headless=true -jar "$PLANTUML_JAR" \
        -tsvg \
        -SDPI=400 \
        -o "$OUTPUT_SVG_DIR" \
        "$puml_file" 2>&1 | grep -v "\[OK\]" || true
    
    # PNG con resolución optimizada (400 DPI - mejor legibilidad)
    echo -e "  ${GREEN}→${NC} Exportando PNG (400 DPI - optimizado)..."
    java -Djava.awt.headless=true -DPLANTUML_LIMIT_SIZE=8192 -jar "$PLANTUML_JAR" \
        -tpng \
        -SDPI=400 \
        -Sbackgroundcolor=white \
        -o "$OUTPUT_PNG_DIR" \
        "$puml_file" 2>&1 | grep -v "\[OK\]" || true
    
    # Redimensionar PNG a dimensiones específicas según el archivo
    local basename=$(basename "$puml_file" .puml)
    local png_output="$OUTPUT_PNG_DIR/$basename.png"
    if [ -f "$png_output" ]; then
        resize_png_to_target_size "$png_output" "$basename"
    fi
    
    # PDF
    echo -e "  ${GREEN}→${NC} Exportando PDF..."
    java -Djava.awt.headless=true -jar "$PLANTUML_JAR" \
        -tpdf \
        -o "$OUTPUT_PDF_DIR" \
        "$puml_file" 2>&1 | grep -v "\[OK\]" || true
    
    cd "$PROJECT_ROOT"
    
    echo -e "  ${GREEN}✓${NC} Completado: $basename"
    echo ""
}

# Función principal
main() {
    # Verificar que el directorio de diagramas existe
    if [ ! -d "$DIAGRAMS_DIR" ]; then
        echo -e "${RED}Error:${NC} Directorio de diagramas no encontrado: $DIAGRAMS_DIR"
        exit 1
    fi
    
    # Contar archivos .puml
    PUML_COUNT=$(find "$DIAGRAMS_DIR" -name "*.puml" | wc -l)
    
    if [ "$PUML_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}Advertencia:${NC} No se encontraron archivos .puml en $DIAGRAMS_DIR"
        exit 0
    fi
    
    echo -e "${GREEN}Encontrados${NC} $PUML_COUNT archivo(s) .puml"
    echo ""
    
    # Procesar cada archivo .puml
    while IFS= read -r -d '' puml_file; do
        # Intentar usar JAR primero (más control), luego fallback a comando
        if command -v java &> /dev/null; then
            export_diagram_jar "$puml_file"
        else
            export_diagram "$puml_file"
        fi
    done < <(find "$DIAGRAMS_DIR" -name "*.puml" -type f -print0)
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Exportación completada${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "Diagramas exportados en:"
    echo -e "  ${BLUE}SVG:${NC} $OUTPUT_SVG_DIR"
    echo -e "  ${BLUE}PNG:${NC} $OUTPUT_PNG_DIR"
    echo -e "  ${BLUE}PDF:${NC} $OUTPUT_PDF_DIR"
    echo ""
    echo -e "${YELLOW}Recomendación:${NC} Usa formato SVG para mejor calidad y escalabilidad"
    echo ""
}

# Ejecutar función principal
main

