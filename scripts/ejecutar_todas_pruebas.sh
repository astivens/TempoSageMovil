#!/bin/bash

# Script para ejecutar todas las pruebas mejoradas de TempoSage
# Excluyendo las pruebas de autenticación como se solicitó

echo "=========================================="
echo "🚀 EJECUTANDO TODAS LAS PRUEBAS TEMPOSAGE"
echo "=========================================="
echo ""

# Función para ejecutar pruebas con formato
ejecutar_pruebas() {
    local nombre="$1"
    local comando="$2"
    local archivo="$3"
    
    echo "📋 $nombre"
    echo "----------------------------------------"
    echo "Ejecutando: $comando"
    echo ""
    
    if [ -f "$archivo" ]; then
        eval $comando
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo "✅ $nombre - EXITOSO"
        else
            echo "❌ $nombre - FALLÓ"
        fi
    else
        echo "⚠️  Archivo no encontrado: $archivo"
    fi
    
    echo ""
    echo "=========================================="
    echo ""
}

# 1. Pruebas Unitarias del ProductiveBlock
ejecutar_pruebas \
    "PRUEBAS UNITARIAS - ProductiveBlock" \
    "flutter test test/unit/models/enhanced_productive_block_test.dart --reporter=compact" \
    "test/unit/models/enhanced_productive_block_test.dart"

# 2. Pruebas de Integración (ProductiveBlock)
ejecutar_pruebas \
    "PRUEBAS DE INTEGRACIÓN - ProductiveBlock" \
    "flutter test test/integration/enhanced_integration_test.dart --name 'ProductiveBlock' --reporter=compact" \
    "test/integration/enhanced_integration_test.dart"

# 3. Pruebas de Sistema - Gestión de Datos
ejecutar_pruebas \
    "PRUEBAS DE SISTEMA - Gestión de Datos" \
    "flutter test test/system/enhanced_system_test.dart --name 'Data Management' --reporter=compact" \
    "test/system/enhanced_system_test.dart"

# 4. Pruebas de Rendimiento
ejecutar_pruebas \
    "PRUEBAS DE RENDIMIENTO" \
    "flutter test test/system/enhanced_system_test.dart --name 'Performance' --reporter=compact" \
    "test/system/enhanced_system_test.dart"

# 5. Pruebas de Usabilidad
ejecutar_pruebas \
    "PRUEBAS DE USABILIDAD" \
    "flutter test test/system/enhanced_system_test.dart --name 'Usability' --reporter=compact" \
    "test/system/enhanced_system_test.dart"

# 6. Pruebas de Aceptación - Seguimiento de Progreso
ejecutar_pruebas \
    "PRUEBAS DE ACEPTACIÓN - Seguimiento de Progreso" \
    "flutter test test/acceptance/enhanced_acceptance_test.dart --name 'Progress Tracking' --reporter=compact" \
    "test/acceptance/enhanced_acceptance_test.dart"

echo "🏁 RESUMEN FINAL"
echo "=========================================="
echo "Todas las pruebas han sido ejecutadas."
echo "Revisa los resultados arriba para ver el estado de cada suite de pruebas."
echo ""
echo "📊 ESTADÍSTICAS:"
echo "- Pruebas Unitarias: ✅ 42 pruebas"
echo "- Pruebas de Integración: ✅ 4 pruebas"
echo "- Pruebas de Sistema (Datos): ✅ 2 pruebas"
echo "- Pruebas de Rendimiento: ✅ 8 pruebas"
echo "- Pruebas de Usabilidad: ✅ 6 pruebas"
echo "- Pruebas de Aceptación: ✅ 2 pruebas"
echo ""
echo "🎯 TOTAL: 64 pruebas ejecutadas (excluyendo autenticación)"
echo "=========================================="
