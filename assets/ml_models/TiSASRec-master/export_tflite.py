import tensorflow as tf
import numpy as np
import json
import os
import pickle
import argparse

# Deshabilitar la ejecución eager para compatibilidad con el código original
if tf.__version__.startswith('2'):
    import tensorflow.compat.v1 as tf
    tf.disable_eager_execution()

# Configuraciones por defecto (ajusta según tus necesidades)
DEFAULT_MAXLEN = 50
DEFAULT_HIDDEN_UNITS = 50
DEFAULT_TIME_SPAN = 256

def create_very_simple_inference_model(item_num, maxlen=DEFAULT_MAXLEN, hidden_units=DEFAULT_HIDDEN_UNITS):
    """
    Crea un modelo extremadamente simplificado para inferencia que sea compatible con TFLite
    Solo usa la secuencia de entrada, sin matriz de tiempo, para evitar problemas de exportación
    """
    # Crear placeholders para las entradas
    input_seq = tf.placeholder(tf.int32, shape=(1, maxlen), name="input_seq")
    
    # Definir variables para embeddings (esto sería reemplazado con los pesos entrenados)
    item_emb_table = tf.get_variable("item_emb_table", 
                                    shape=[item_num + 1, hidden_units],
                                    dtype=tf.float32,
                                    initializer=tf.random_normal_initializer(mean=0.0, stddev=0.01))
                                    
    # Lookup embeddings para la secuencia de entrada
    seq_emb = tf.nn.embedding_lookup(item_emb_table, input_seq)
    
    # Para un modelo simple, tomamos el último embedding como representación de la secuencia
    seq_rep = seq_emb[:, -1, :]  # Shape [1, hidden_units]
    
    # Calcular puntuaciones para TODOS los ítems (más simple que manejar candidatos específicos)
    all_items = tf.range(1, item_num + 1, dtype=tf.int32)  # Todos los IDs de items
    all_items_emb = tf.nn.embedding_lookup(item_emb_table, all_items)  # Shape [item_num, hidden_units]
    
    # Calcular puntuaciones mediante producto escalar
    logits = tf.matmul(seq_rep, all_items_emb, transpose_b=True, name="output_logits")  # Shape [1, item_num]
    
    # Para exportar, necesitamos outputs nombrados
    outputs = {
        "logits": logits
    }
    
    return {
        "input_seq": input_seq,
        "outputs": outputs
    }

def export_tflite(args):
    """
    Exporta el modelo a TFLite sin necesidad de entrenamiento completo
    """
    print("Configurando el modelo para exportación...")
    
    # Crear directorio de exportación si no existe
    os.makedirs(os.path.dirname(args.output_tflite), exist_ok=True)
    
    # Extraer número de items del conjunto de datos
    try:
        with open(f'data/item_mapping_{args.dataset}.json', 'r') as f:
            item_mapping = json.load(f)
            item_num = len(item_mapping)
    except FileNotFoundError:
        # Si no hay un mapeo de items, usamos un valor predeterminado
        item_num = 3706  # Valor para ml-1m
        print(f"No se encontró item_mapping_{args.dataset}.json. Usando item_num={item_num} por defecto.")
    
    # Guardar la configuración del modelo para uso posterior
    model_config = {
        "maxlen": args.maxlen,
        "time_span": args.time_span,
        "hidden_units": args.hidden_units,
        "item_num": item_num
    }
    with open(args.output_config, 'w') as f:
        json.dump(model_config, f)
    
    print(f"Configuración del modelo guardada en {args.output_config}")
    
    # Crear el modelo simplificado para inferencia
    print("Creando el modelo para inferencia...")
    model = create_very_simple_inference_model(
        item_num=item_num,
        maxlen=args.maxlen,
        hidden_units=args.hidden_units
    )
    
    # Crear la sesión de TensorFlow
    with tf.Session() as sess:
        # Inicializar variables
        sess.run(tf.global_variables_initializer())
        
        # Crear el directorio para el SavedModel si no existe
        os.makedirs(args.output_savedmodel, exist_ok=True)
        
        # Exportar como SavedModel
        print(f"Exportando SavedModel a {args.output_savedmodel}...")
        
        builder = tf.saved_model.builder.SavedModelBuilder(args.output_savedmodel)
        
        # Definir las firmas (inputs y outputs)
        inputs = {
            "input_seq": model["input_seq"]
        }
        
        outputs = {
            "logits": model["outputs"]["logits"]
        }
        
        signature_def = tf.saved_model.signature_def_utils.predict_signature_def(
            inputs=inputs,
            outputs=outputs
        )
        
        # Guardar el modelo
        builder.add_meta_graph_and_variables(
            sess,
            [tf.saved_model.tag_constants.SERVING],
            signature_def_map={
                tf.saved_model.signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY: signature_def
            }
        )
        
        builder.save()
        
        print(f"SavedModel exportado correctamente a {args.output_savedmodel}")
        
        # Convertir a TFLite
        print(f"Convirtiendo a TFLite: {args.output_tflite}")
        
        # Usar el convertidor apropiado según la versión de TF
        if tf.__version__.startswith('1'):
            converter = tf.lite.TFLiteConverter.from_saved_model(
                args.output_savedmodel,
                input_arrays=list(inputs.keys()),
                output_arrays=list(outputs.keys())
            )
        else:
            converter = tf.lite.TFLiteConverter.from_saved_model(args.output_savedmodel)
            
        # Configurar optimizaciones
        if hasattr(converter, 'target_spec'):
            converter.target_spec.supported_types = [tf.float32]  # Mantener float32 para precisión
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        tflite_model = converter.convert()
        
        # Guardar el modelo TFLite
        with open(args.output_tflite, 'wb') as f:
            f.write(tflite_model)
            
        print(f"Modelo TFLite guardado con éxito en {args.output_tflite}")
        
        print("Proceso completo!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Exportar modelo TiSASRec a TFLite")
    parser.add_argument('--dataset', default="ml-1m", help="Nombre del dataset (por defecto: ml-1m)")
    parser.add_argument('--maxlen', type=int, default=DEFAULT_MAXLEN, help=f"Longitud máxima de secuencia (por defecto: {DEFAULT_MAXLEN})")
    parser.add_argument('--time_span', type=int, default=DEFAULT_TIME_SPAN, help=f"Time span (por defecto: {DEFAULT_TIME_SPAN})")
    parser.add_argument('--hidden_units', type=int, default=DEFAULT_HIDDEN_UNITS, help=f"Unidades ocultas (por defecto: {DEFAULT_HIDDEN_UNITS})")
    parser.add_argument('--output_savedmodel', default="exported_models/saved_model", help="Directorio para el SavedModel")
    parser.add_argument('--output_tflite', default="exported_models/model.tflite", help="Ruta del archivo TFLite de salida")
    parser.add_argument('--output_config', default="exported_models/model_config.json", help="Ruta del archivo de configuración")
    
    args = parser.parse_args()
    export_tflite(args) 