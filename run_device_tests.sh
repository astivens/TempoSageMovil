#!/bin/bash

# Script para ejecutar pruebas de rendimiento en dispositivo físico
# Autor: TempoSage Team

echo "=== Pruebas de Rendimiento en Dispositivo Físico ==="

# Verificar que hay un dispositivo conectado
DEVICE_COUNT=$(flutter devices | grep -c "android\|ios")

if [ $DEVICE_COUNT -eq 0 ]; then
  echo "ERROR: No se encontró ningún dispositivo físico conectado."
  echo "Conecta tu dispositivo y asegúrate que esté en modo desarrollador."
  exit 1
fi

# Mostrar dispositivos disponibles
echo "Dispositivos disponibles:"
flutter devices

# Ejecutar pruebas en modo perfil para obtener métricas de rendimiento reales
echo ""
echo "Ejecutando pruebas de rendimiento en modo perfil..."
flutter drive \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/performance/app_performance_test.dart \
  --profile \
  --no-dds

echo ""
echo "Pruebas completadas." 