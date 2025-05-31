#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Visualizador de métricas de rendimiento para TempoSage
Este script genera gráficos a partir de los datos de rendimiento recopilados.
"""

import os
import sys
import glob
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime

# Verificar dependencias
try:
    import pandas as pd
    import matplotlib.pyplot as plt
except ImportError:
    print("Error: Este script requiere pandas y matplotlib.")
    print("Instala las dependencias con: pip install pandas matplotlib")
    sys.exit(1)

def main():
    # Configurar estilo de gráficos
    plt.style.use('ggplot')
    
    # Buscar archivos CSV de resumen
    csv_files = glob.glob('performance_reports/resumen_*.csv')
    
    if not csv_files:
        print("No se encontraron archivos CSV de rendimiento.")
        print("Ejecuta primero './scripts/analizar_rendimiento.sh'")
        return
    
    # Cargar todos los CSV en un DataFrame
    all_data = []
    for csv_file in csv_files:
        try:
            df = pd.read_csv(csv_file)
            df['Timestamp'] = pd.to_datetime(df['Fecha'], format='%Y%m%d_%H%M%S')
            all_data.append(df)
        except Exception as e:
            print(f"Error al procesar {csv_file}: {e}")
    
    if not all_data:
        print("No se pudieron cargar datos de los archivos CSV.")
        return
    
    # Combinar todos los datos
    data = pd.concat(all_data).sort_values('Timestamp')
    
    # Crear directorio para gráficos
    os.makedirs('performance_reports/graficos', exist_ok=True)
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    # Generar gráficos
    
    # 1. Memoria
    plt.figure(figsize=(10, 6))
    plt.plot(data['Timestamp'], data['Memoria_Total_PSS'], 'b-', label='PSS Total')
    plt.plot(data['Timestamp'], data['Java_Heap'], 'r-', label='Java Heap')
    plt.title('Uso de Memoria a lo largo del tiempo')
    plt.xlabel('Fecha')
    plt.ylabel('Memoria (KB)')
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f'performance_reports/graficos/memoria_{timestamp}.png')
    
    # 2. CPU
    plt.figure(figsize=(10, 6))
    plt.plot(data['Timestamp'], data['CPU_Usage'], 'g-')
    plt.title('Uso de CPU a lo largo del tiempo')
    plt.xlabel('Fecha')
    plt.ylabel('CPU (%)')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f'performance_reports/graficos/cpu_{timestamp}.png')
    
    # 3. Frames
    plt.figure(figsize=(10, 6))
    plt.bar(data['Timestamp'], data['Total_Frames'], label='Total Frames')
    plt.bar(data['Timestamp'], data['Janky_Frames'], color='red', label='Frames Lentos')
    plt.title('Rendimiento de Frames')
    plt.xlabel('Fecha')
    plt.ylabel('Número de Frames')
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f'performance_reports/graficos/frames_{timestamp}.png')
    
    # 4. Porcentaje de Janky Frames
    if 'Total_Frames' in data and data['Total_Frames'].max() > 0:
        data['Janky_Percent'] = (data['Janky_Frames'] / data['Total_Frames']) * 100
        plt.figure(figsize=(10, 6))
        plt.plot(data['Timestamp'], data['Janky_Percent'], 'r-')
        plt.axhline(y=16, color='orange', linestyle='--', label='Umbral de advertencia (16%)')
        plt.title('Porcentaje de Frames Lentos')
        plt.xlabel('Fecha')
        plt.ylabel('Porcentaje (%)')
        plt.legend()
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig(f'performance_reports/graficos/janky_percent_{timestamp}.png')
    
    print(f"Gráficos generados en performance_reports/graficos/")
    print("Archivos:")
    for img in glob.glob('performance_reports/graficos/*_{}.png'.format(timestamp)):
        print(f"- {img}")

if __name__ == "__main__":
    main() 