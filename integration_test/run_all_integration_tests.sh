#!/bin/bash
set -e

echo "Ejecutando todos los tests de integración en dispositivo/emulador..."

TESTS=(
  habit_recommendation_integration_test.dart
  auth_service_integration_test.dart
  recommendation_service_integration_test.dart
  csv_service_integration_test.dart
  schedule_rule_service_integration_test.dart
  migration_service_integration_test.dart
)

for test in "${TESTS[@]}"; do
  echo "\n==============================="
  echo "Ejecutando: $test"
  echo "===============================\n"
  flutter drive --driver integration_test/driver.dart --target integration_test/$test || exit 1
done

echo "\n✅ Todos los tests de integración finalizados." 