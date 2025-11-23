#!/bin/bash

# Script para redimensionar todos los diagramas PNG a dimensiones específicas
# Este script se ejecuta después de la exportación para asegurar dimensiones exactas

set -e

PNG_DIR="docs/diagrams/images/png"

# Función para redimensionar un archivo
resize_file() {
    local file="$1"
    local width="$2"
    local height="$3"
    
    if [ -f "$file" ]; then
        echo "Redimensionando $(basename "$file") a ${width}x${height}px..."
        # Usar magick si está disponible (ImageMagick v7), sino convert (v6)
        if command -v magick &> /dev/null; then
            magick "$file" -resize "${width}x${height}" -background white -gravity center -extent "${width}x${height}" "$file"
        else
            convert "$file" -resize "${width}x${height}" -background white -gravity center -extent "${width}x${height}" "$file"
        fi
    fi
}

# Redimensionar según el nombre del archivo
for file in "$PNG_DIR"/*.png; do
    basename=$(basename "$file" .png)
    
    case "$basename" in
        TempoSage_Use_Case_Diagram_Authentication|TempoSage_Use_Case_Diagram_Dashboard|TempoSage_Use_Case_Diagram_AI)
            resize_file "$file" 2000 2000
            ;;
        TempoSage_Sequence_Diagram_Activity_Creation|TempoSage_Sequence_Diagram_Task_Management|TempoSage_Sequence_Diagram_Recommendations|TempoSage_Sequence_Diagram_Dashboard_Refresh)
            resize_file "$file" 1600 2400
            ;;
        TempoSage_Sequence_Diagram_Auth|TempoSage_Class_Diagram_Core_Domain|TempoSage_Class_Diagram_Data_Layer|TempoSage_Class_Diagram_Presentation_Services|TempoSage_Entity_Relationship_Diagram_Core_Entities|TempoSage_Entity_Relationship_Diagram_Config_Analytics|TempoSage_Use_Case_Diagram_Management)
            resize_file "$file" 1800 2700
            ;;
        TempoSage_Use_Case_Diagram|TempoSage_Entity_Relationship_Diagram|TempoSage_Component_Diagram|TempoSage_Sequence_Diagram)
            resize_file "$file" 2000 3000
            ;;
        TempoSage_Sequence_Diagram_Daily_Flow|TempoSage_Class_Diagram)
            resize_file "$file" 2200 3300
            ;;
    esac
done

echo ""
echo "✓ Todos los diagramas redimensionados"

