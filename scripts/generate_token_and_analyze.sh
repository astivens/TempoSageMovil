#!/bin/bash

echo "🔑 Generando token de SonarQube..."

# Intentar generar el token
TOKEN_RESPONSE=$(curl -s -X POST "http://localhost:9000/api/user_tokens/generate" \
  -u admin:admin \
  -d "name=temposage-token-$(date +%s)" \
  -H "Content-Type: application/x-www-form-urlencoded")

echo "Respuesta del servidor: $TOKEN_RESPONSE"

# Extraer el token si la respuesta es exitosa
if echo "$TOKEN_RESPONSE" | grep -q '"token"'; then
    TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Token generado: $TOKEN"
    
    # Ejecutar análisis con el token
    echo "🚀 Ejecutando análisis de SonarQube..."
    sonar-scanner \
        -Dsonar.login="$TOKEN" \
        -Dsonar.projectKey=temposage-movil \
        -Dsonar.projectName="TempoSage Movil" \
        -Dsonar.projectVersion=1.0.0 \
        -Dsonar.sources=lib \
        -Dsonar.tests=test \
        -Dsonar.coverageReportPaths=coverage/lcov.info \
        -Dsonar.exclusions="**/*.g.dart,**/*.freezed.dart,**/*.mocks.dart,**/*.gr.dart,**/*.chopper.dart,**/generated/**,**/build/**,**/.dart_tool/**,**/*.md,**/docs/**,**/*.json,**/*.yaml,**/*.yml,**/*.lock,**/*.txt,**/*.csv,**/*.pickle,**/performance_reports/**,**/test-reports/**,**/coverage/**,**/web/**,**/ios/**,**/android/**,**/linux/**,**/macos/**,**/windows/**,**/.github/**,**/sonar-plugins/**,**/ollama_proxy/**,**/data/**,**/assets/**,**/*.xml,**/*.properties,**/*.toml,**/*.sh,**/*.py,**/*.jar,**/*.pdf,**/*.jpg,**/*.png,**/*.gif,**/*.svg,**/*.ico,**/*.ttf,**/*.otf"
    
    if [ $? -eq 0 ]; then
        echo "✅ Análisis completado exitosamente!"
        echo "🌐 Dashboard: http://localhost:9000/dashboard?id=temposage-movil"
    else
        echo "❌ Error en el análisis"
    fi
else
    echo "❌ No se pudo generar el token. Respuesta: $TOKEN_RESPONSE"
    echo "💡 Intenta acceder manualmente a http://localhost:9000 para generar un token"
fi
