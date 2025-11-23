#!/bin/bash

# Script para verificar que las exclusiones de SonarQube están funcionando correctamente
# Autor: TempoSage Team
# Fecha: 9 de Octubre, 2025

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "Verificando configuración de exclusiones de SonarQube..."

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.."

# Verificar que existe el archivo de configuración
if [ ! -f "sonar-project.properties" ]; then
    log_error "No se encontró el archivo sonar-project.properties"
    exit 1
fi

log_success "Archivo de configuración encontrado"

# Verificar exclusiones configuradas
log_info "Verificando exclusiones configuradas..."

EXCLUSIONS=$(grep "sonar.exclusions" sonar-project.properties | cut -d'=' -f2)

if [[ $EXCLUSIONS == *"*.md"* ]]; then
    log_success "✅ Archivos .md excluidos correctamente"
else
    log_warning "⚠️ Archivos .md NO están excluidos"
fi

if [[ $EXCLUSIONS == *"docs/**"* ]]; then
    log_success "✅ Directorio docs/ excluido correctamente"
else
    log_warning "⚠️ Directorio docs/ NO está excluido"
fi

if [[ $EXCLUSIONS == *"*.g.dart"* ]]; then
    log_success "✅ Archivos .g.dart excluidos correctamente"
else
    log_warning "⚠️ Archivos .g.dart NO están excluidos"
fi

if [[ $EXCLUSIONS == *"build/**"* ]]; then
    log_success "✅ Directorio build/ excluido correctamente"
else
    log_warning "⚠️ Directorio build/ NO está excluido"
fi

# Contar archivos que serían analizados vs excluidos
log_info "Contando archivos en el proyecto..."

TOTAL_FILES=$(find . -type f | wc -l)
MD_FILES=$(find . -name "*.md" -type f | wc -l)
DART_FILES=$(find . -name "*.dart" -type f | wc -l)
DOCS_FILES=$(find docs/ -type f 2>/dev/null | wc -l)

log_info "Estadísticas del proyecto:"
echo "  📁 Total de archivos: $TOTAL_FILES"
echo "  📄 Archivos .md: $MD_FILES"
echo "  🎯 Archivos .dart: $DART_FILES"
echo "  📚 Archivos en docs/: $DOCS_FILES"

# Verificar archivos específicos que deberían estar excluidos
log_info "Verificando archivos específicos que deberían estar excluidos..."

EXCLUDED_COUNT=0

# Verificar archivos .md
for md_file in $(find . -name "*.md" -type f); do
    if [[ $EXCLUSIONS == *"*.md"* ]]; then
        log_success "✅ $md_file será excluido"
        ((EXCLUDED_COUNT++))
    else
        log_warning "⚠️ $md_file NO será excluido"
    fi
done

# Verificar archivos en docs/
if [ -d "docs" ]; then
    if [[ $EXCLUSIONS == *"docs/**"* ]]; then
        log_success "✅ Todo el directorio docs/ será excluido"
        ((EXCLUDED_COUNT+=DOCS_FILES))
    else
        log_warning "⚠️ Directorio docs/ NO será excluido"
    fi
fi

log_info "Resumen de verificación:"
echo "  ✅ Archivos que serán excluidos: $EXCLUDED_COUNT"
echo "  📊 Archivos que serán analizados: $((TOTAL_FILES - EXCLUDED_COUNT))"

# Mostrar configuración actual
log_info "Configuración actual de exclusiones:"
echo "$EXCLUSIONS" | tr ',' '\n' | sed 's/^/  - /'

# Verificar que no hay archivos .md en el directorio lib/
MD_IN_LIB=$(find lib/ -name "*.md" -type f 2>/dev/null | wc -l)
if [ $MD_IN_LIB -eq 0 ]; then
    log_success "✅ No hay archivos .md en el directorio lib/"
else
    log_warning "⚠️ Encontrados $MD_IN_LIB archivos .md en lib/"
    find lib/ -name "*.md" -type f 2>/dev/null | sed 's/^/  - /'
fi

log_success "Verificación de exclusiones completada!"

# Mostrar recomendaciones
log_info "Recomendaciones:"
echo "  🔍 Ejecuta el análisis para verificar que las exclusiones funcionan"
echo "  📊 Revisa el dashboard de SonarQube para confirmar"
echo "  📝 Los archivos .md no aparecerán en el análisis de código"

log_success "Verificación completada exitosamente!"
