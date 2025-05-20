#!/bin/bash

# Crear directorio si no existe
mkdir -p assets/ml_models/tisasrec

# URL del modelo (esto es un ejemplo, necesitarás reemplazarlo con la URL real)
MODEL_URL="https://storage.googleapis.com/temposage-models/tisasrec_model.tflite"

# Descargar el modelo
echo "Descargando modelo TensorFlow Lite..."
curl -L "$MODEL_URL" -o assets/ml_models/tisasrec/tisasrec_model.tflite

# Verificar que el archivo se descargó correctamente
if [ -f "assets/ml_models/tisasrec/tisasrec_model.tflite" ]; then
    echo "Modelo descargado exitosamente"
else
    echo "Error al descargar el modelo"
    exit 1
fi 