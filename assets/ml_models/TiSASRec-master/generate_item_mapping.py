import os
import json
from collections import defaultdict
from util import cleanAndsort, timeSlice

def extract_item_mapping(dataset_name):
    """
    Extrae el mapeo de IDs originales a IDs enteros desde el dataset
    """
    print(f"Procesando dataset {dataset_name}...")
    
    # Paso 1: Leer archivo de datos
    user_data = defaultdict(list)
    time_set = set()
    
    try:
        file_path = f"data/{dataset_name}.txt"
        print(f"Leyendo archivo {file_path}...")
        
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split('\t')
                
                if len(parts) == 4:  # Formato: user, item, rating, timestamp
                    user_id, item_id, _, timestamp = parts
                elif len(parts) == 3:  # Formato: user, item, timestamp
                    user_id, item_id, timestamp = parts
                else:
                    print(f"Formato no reconocido en línea: {line}")
                    continue
                
                user_id = int(user_id)
                item_id = int(item_id)
                timestamp = float(timestamp)
                
                time_set.add(timestamp)
                user_data[user_id].append([item_id, timestamp])
    
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo {file_path}")
        return None
    
    # Paso 2: Procesar datos usando funciones de util.py
    print("Procesando timestamps...")
    time_map = timeSlice(time_set)
    
    print("Limpiando y ordenando datos...")
    processed_data, usernum, itemnum, timenum = cleanAndsort(user_data, time_map)
    
    # Paso 3: Extraer el mapeo de items
    print("Extrayendo mapeo de items...")
    item_mapping = {}
    
    # Para cada usuario, recorremos sus interacciones
    for user_id, interactions in user_data.items():
        for item_orig, _ in interactions:
            # Si el item no está en el mapeo, lo agregamos
            if str(item_orig) not in item_mapping:
                # Nota: cleanAndsort() en util.py haría este mapeo,
                # pero aquí simplemente estamos guardando el original -> entero
                # Esta lógica debe coincidir con cleanAndsort
                item_mapping[str(item_orig)] = len(item_mapping) + 1
    
    print(f"Encontrados {len(item_mapping)} items únicos")
    
    # Paso 4: Guardar el mapeo
    output_path = f"data/item_mapping_{dataset_name}.json"
    print(f"Guardando mapeo en {output_path}...")
    
    with open(output_path, 'w') as f:
        json.dump(item_mapping, f)
    
    print(f"Mapeo guardado exitosamente en {output_path}")
    
    # Crear también el mapeo inverso
    reverse_mapping = {str(v): k for k, v in item_mapping.items()}
    
    output_reverse_path = f"data/reverse_item_mapping_{dataset_name}.json"
    print(f"Guardando mapeo inverso en {output_reverse_path}...")
    
    with open(output_reverse_path, 'w') as f:
        json.dump(reverse_mapping, f)
    
    print(f"Mapeo inverso guardado exitosamente en {output_reverse_path}")
    
    return item_mapping

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Generar mapeo de items para dataset TiSASRec")
    parser.add_argument('--dataset', default='ml-1m', help="Nombre del dataset (por defecto: ml-1m)")
    
    args = parser.parse_args()
    extract_item_mapping(args.dataset) 