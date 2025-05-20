#!/usr/bin/env python3
"""
Script para generar un modelo TensorFlow Lite simple para recomendaciones.
Este modelo es un placeholder para demostrar la integración con TensorFlow Lite.
"""

import os
import json
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Asegurar que el directorio existe
os.makedirs("assets/ml_models/tisasrec", exist_ok=True)

# Cargar el mapeo de categorías
with open("assets/ml_models/tisasrec/item_mapping.json", "r") as f:
    item_mapping = json.load(f)

num_categories = len(item_mapping)
sequence_length = 50
embedding_dim = 32

# Crear un modelo simple de recomendación
def create_model():
    inputs = keras.Input(shape=(sequence_length,))
    
    # Embedding para las categorías
    x = layers.Embedding(
        input_dim=num_categories + 1,  # +1 para el padding (0)
        output_dim=embedding_dim
    )(inputs)
    
    # LSTM para procesar la secuencia
    x = layers.LSTM(32)(x)
    
    # Capa densa para la salida
    outputs = layers.Dense(num_categories + 1, activation='softmax')(x)
    
    model = keras.Model(inputs=inputs, outputs=outputs)
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

# Crear el modelo
model = create_model()
print("Modelo creado")

# Generar algunos datos de ejemplo para entrenar el modelo
# Esto es solo para demostración, no tiene sentido real
X_train = np.random.randint(0, num_categories + 1, size=(100, sequence_length))
y_train = np.random.randint(0, num_categories + 1, size=(100, 1))

# Entrenar el modelo con datos de ejemplo
model.fit(X_train, y_train, epochs=1, verbose=1)
print("Modelo entrenado")

# Convertir el modelo a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Guardar el modelo
with open("assets/ml_models/tisasrec/tisasrec_model.tflite", "wb") as f:
    f.write(tflite_model)

print("Modelo TensorFlow Lite guardado en assets/ml_models/tisasrec/tisasrec_model.tflite")

# Verificar que el modelo se puede cargar
interpreter = tf.lite.Interpreter(model_path="assets/ml_models/tisasrec/tisasrec_model.tflite")
interpreter.allocate_tensors()

# Obtener información sobre las entradas y salidas
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Detalles de entrada:", input_details)
print("Detalles de salida:", output_details)

print("Modelo verificado correctamente") 