#!/bin/bash

# Script para ejecutar la aplicación con una clave API de Google AI

# Verifica si se proporcionó una clave API
if [ $# -eq 0 ]; then
    echo "Error: Debes proporcionar tu clave API de Google AI."
    echo "Uso: $0 <TU_CLAVE_API>"
    exit 1
fi

API_KEY="$1"

echo "Ejecutando la aplicación con la clave API proporcionada..."
flutter run --dart-define=GOOGLE_AI_API_KEY="$API_KEY" 