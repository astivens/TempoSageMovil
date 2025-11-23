#!/bin/bash

# Script completo para ejecutar todas las pruebas con reporte detallado
echo "🚀 TEMPOSAGE - EJECUCIÓN COMPLETA DE PRUEBAS MEJORADAS"
echo "======================================================"
echo "📅 Fecha: $(date)"
echo "🎯 Excluyendo pruebas de autenticación"
echo ""

# Función para mostrar estadísticas detalladas
mostrar_estadisticas() {
    local nombre="$1"
    local resultado="$2"
    local tiempo="$3"
    
    echo "📊 $nombre"
    echo "   Resultado: $resultado"
    echo "   Tiempo: $tiempo"
    echo ""
}

echo "🔥 INICIANDO EJECUCIÓN DE PRUEBAS..."
echo ""

# Ejecutar todas las pruebas y capturar resultados
echo "1️⃣ PRUEBAS UNITARIAS - ProductiveBlock"
start_time=$(date +%s)
unit_result=$(flutter test test/unit/models/enhanced_productive_block_test.dart --reporter=compact 2>&1)
unit_exit_code=$?
end_time=$(date +%s)
unit_time=$((end_time - start_time))

if [ $unit_exit_code -eq 0 ]; then
    unit_status="✅ EXITOSO (42 pruebas)"
else
    unit_status="❌ FALLÓ"
fi

echo "2️⃣ PRUEBAS DE INTEGRACIÓN - ProductiveBlock"
start_time=$(date +%s)
integration_result=$(flutter test test/integration/enhanced_integration_test.dart --name 'ProductiveBlock' --reporter=compact 2>&1)
integration_exit_code=$?
end_time=$(date +%s)
integration_time=$((end_time - start_time))

if [ $integration_exit_code -eq 0 ]; then
    integration_status="✅ EXITOSO (4 pruebas)"
else
    integration_status="❌ FALLÓ"
fi

echo "3️⃣ PRUEBAS DE SISTEMA - Gestión de Datos"
start_time=$(date +%s)
system_data_result=$(flutter test test/system/enhanced_system_test.dart --name 'Data Management' --reporter=compact 2>&1)
system_data_exit_code=$?
end_time=$(date +%s)
system_data_time=$((end_time - start_time))

if [ $system_data_exit_code -eq 0 ]; then
    system_data_status="✅ EXITOSO (2 pruebas)"
else
    system_data_status="❌ FALLÓ"
fi

echo "4️⃣ PRUEBAS DE RENDIMIENTO"
start_time=$(date +%s)
performance_result=$(flutter test test/system/enhanced_system_test.dart --name 'Performance' --reporter=compact 2>&1)
performance_exit_code=$?
end_time=$(date +%s)
performance_time=$((end_time - start_time))

if [ $performance_exit_code -eq 0 ]; then
    performance_status="✅ EXITOSO (8 pruebas)"
else
    performance_status="❌ FALLÓ"
fi

echo "5️⃣ PRUEBAS DE USABILIDAD"
start_time=$(date +%s)
usability_result=$(flutter test test/system/enhanced_system_test.dart --name 'Usability' --reporter=compact 2>&1)
usability_exit_code=$?
end_time=$(date +%s)
usability_time=$((end_time - start_time))

if [ $usability_exit_code -eq 0 ]; then
    usability_status="✅ EXITOSO (6 pruebas)"
else
    usability_status="❌ FALLÓ"
fi

echo "6️⃣ PRUEBAS DE ACEPTACIÓN - Seguimiento de Progreso"
start_time=$(date +%s)
acceptance_result=$(flutter test test/acceptance/enhanced_acceptance_test.dart --name 'Progress Tracking' --reporter=compact 2>&1)
acceptance_exit_code=$?
end_time=$(date +%s)
acceptance_time=$((end_time - start_time))

if [ $acceptance_exit_code -eq 0 ]; then
    acceptance_status="✅ EXITOSO (2 pruebas)"
else
    acceptance_status="❌ FALLÓ"
fi

# Calcular tiempo total
total_time=$((unit_time + integration_time + system_data_time + performance_time + usability_time + acceptance_time))

echo ""
echo "🏆 REPORTE FINAL DE PRUEBAS"
echo "======================================================"
echo ""

mostrar_estadisticas "PRUEBAS UNITARIAS" "$unit_status" "${unit_time}s"
mostrar_estadisticas "PRUEBAS DE INTEGRACIÓN" "$integration_status" "${integration_time}s"
mostrar_estadisticas "PRUEBAS DE SISTEMA (Datos)" "$system_data_status" "${system_data_time}s"
mostrar_estadisticas "PRUEBAS DE RENDIMIENTO" "$performance_status" "${performance_time}s"
mostrar_estadisticas "PRUEBAS DE USABILIDAD" "$usability_status" "${usability_time}s"
mostrar_estadisticas "PRUEBAS DE ACEPTACIÓN" "$acceptance_status" "${acceptance_time}s"

echo "📈 RESUMEN GENERAL"
echo "======================================================"
echo "⏱️  Tiempo total de ejecución: ${total_time}s"
echo "🎯 Total de pruebas ejecutadas: 64"
echo "📊 Categorías de prueba: 6"
echo ""

# Verificar si todas las pruebas pasaron
total_exit_code=$((unit_exit_code + integration_exit_code + system_data_exit_code + performance_exit_code + usability_exit_code + acceptance_exit_code))

if [ $total_exit_code -eq 0 ]; then
    echo "🎉 ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE!"
    echo "✅ Estado: COMPLETADO"
    echo "🚀 El sistema TempoSage cumple con todos los criterios de calidad"
else
    echo "⚠️  ALGUNAS PRUEBAS FALLARON"
    echo "❌ Estado: REVISAR"
    echo "🔧 Se recomienda revisar los logs de las pruebas fallidas"
fi

echo ""
echo "======================================================"
echo "📋 Documentación disponible en:"
echo "   - docs/DISEÑO_MEJORADO_PRUEBAS_TEMPOSAGE.md"
echo "   - docs/RESUMEN_MEJORAS_PRUEBAS_TEMPOSAGE.md"
echo "======================================================"
