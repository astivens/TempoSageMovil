#!/bin/bash

PACKAGE="com.example.temposage"
FECHA=$(date +"%Y%m%d_%H%M%S")
DIRECTORIO="performance_reports"

mkdir -p $DIRECTORIO

echo "=== Análisis de Rendimiento TempoSage ==="
echo "Fecha: $(date)"
echo "Dispositivo: $(adb shell getprop ro.product.model)"
echo "Android: $(adb shell getprop ro.build.version.release)"
echo ""

# Asegurar que la aplicación está en ejecución
echo "Verificando si la aplicación está en ejecución..."
APP_RUNNING=$(adb shell "ps | grep $PACKAGE" | wc -l)
if [ "$APP_RUNNING" -eq "0" ]; then
    echo "⚠️ La aplicación no está en ejecución. Iniciándola..."
    adb shell monkey -p $PACKAGE 1
    sleep 5
fi

echo "Capturando métricas de rendimiento..."

# Capturar uso de memoria
echo "📊 Analizando uso de memoria..."
adb shell dumpsys meminfo $PACKAGE > "$DIRECTORIO/memoria_$FECHA.txt"
TOTAL_PSS=$(grep "TOTAL PSS:" "$DIRECTORIO/memoria_$FECHA.txt" | awk '{print $3}')
TOTAL_JAVA_HEAP=$(grep "Java Heap:" "$DIRECTORIO/memoria_$FECHA.txt" | awk '{print $3}')

# Capturar info de renderizado
echo "🎞️ Analizando rendimiento gráfico..."
adb shell dumpsys gfxinfo $PACKAGE reset > /dev/null
echo "  Espera de 5 segundos para recopilar datos gráficos..."
sleep 5
adb shell dumpsys gfxinfo $PACKAGE > "$DIRECTORIO/gfxinfo_$FECHA.txt"

# Capturar uso de CPU
echo "⚙️ Analizando uso de CPU..."
adb shell dumpsys cpuinfo > "$DIRECTORIO/cpuinfo_$FECHA.txt"
CPU_USAGE=$(grep "$PACKAGE" "$DIRECTORIO/cpuinfo_$FECHA.txt" | head -1 | awk '{print $1}')

# Capturar estadísticas de batería
echo "🔋 Analizando impacto en batería..."
adb shell dumpsys batterystats $PACKAGE > "$DIRECTORIO/batterystats_$FECHA.txt"

# Extraer FPS promedio
TOTAL_FRAMES=$(grep -c "Draw" "$DIRECTORIO/gfxinfo_$FECHA.txt" || echo "0")
JANKY_FRAMES=$(grep -c "Janky" "$DIRECTORIO/gfxinfo_$FECHA.txt" || echo "0")

# Valores por defecto si no se encuentran
if [ -z "$TOTAL_PSS" ]; then TOTAL_PSS="0"; fi
if [ -z "$TOTAL_JAVA_HEAP" ]; then TOTAL_JAVA_HEAP="0"; fi
if [ -z "$CPU_USAGE" ]; then CPU_USAGE="0"; fi

# Crear resumen CSV
echo "Creando resumen..."
echo "Fecha,Memoria_Total_PSS,Java_Heap,CPU_Usage,Total_Frames,Janky_Frames" > "$DIRECTORIO/resumen_$FECHA.csv"
echo "$FECHA,$TOTAL_PSS,$TOTAL_JAVA_HEAP,$CPU_USAGE,$TOTAL_FRAMES,$JANKY_FRAMES" >> "$DIRECTORIO/resumen_$FECHA.csv"

# Mostrar resumen
echo ""
echo "=== RESUMEN DE RENDIMIENTO ==="
echo "Uso de memoria (PSS): $TOTAL_PSS KB"
echo "Java Heap: $TOTAL_JAVA_HEAP KB"
echo "Uso de CPU: $CPU_USAGE %"
echo "Total frames: $TOTAL_FRAMES"
echo "Frames lentos: $JANKY_FRAMES"
if [ "$TOTAL_FRAMES" -gt "0" ]; then
  JANKY_PERCENT=$(( (JANKY_FRAMES * 100) / TOTAL_FRAMES ))
  echo "Porcentaje de frames lentos: $JANKY_PERCENT%"
fi

echo ""
echo "✅ Análisis completo"
echo "Resultados guardados en $DIRECTORIO"
echo "Archivos detallados disponibles en:"
echo "- $DIRECTORIO/memoria_$FECHA.txt"
echo "- $DIRECTORIO/gfxinfo_$FECHA.txt"
echo "- $DIRECTORIO/cpuinfo_$FECHA.txt"
echo "- $DIRECTORIO/batterystats_$FECHA.txt"
echo "- $DIRECTORIO/resumen_$FECHA.csv" 