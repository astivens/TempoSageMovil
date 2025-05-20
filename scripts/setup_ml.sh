#!/bin/bash

# Script para configurar el entorno de machine learning

# Verificar que Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "Python 3 no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Crear un entorno virtual
echo "Creando entorno virtual..."
python3 -m venv ml_env

# Activar el entorno virtual
echo "Activando entorno virtual..."
source ml_env/bin/activate

# Instalar dependencias
echo "Instalando dependencias..."
pip install tensorflow numpy

# Crear el modelo
echo "Creando modelo TensorFlow Lite..."
python3 scripts/create_model.py

# Desactivar el entorno virtual
echo "Desactivando entorno virtual..."
deactivate

echo "Configuración completada."
echo "El modelo ha sido creado en assets/ml_models/tisasrec/tisasrec_model.tflite" 