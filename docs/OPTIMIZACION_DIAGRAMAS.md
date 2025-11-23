# Optimización de Diagramas PlantUML

Este documento describe las estrategias para optimizar el tamaño de los diagramas sin sacrificar legibilidad.

## Análisis de Tamaño Actual

### Comparación de Formatos

| Formato | Tamaño Total | Tamaño Promedio | Ventajas |
|---------|--------------|-----------------|----------|
| **PNG (600 DPI)** | ~6.6 MB | 330 KB | Alta resolución, compatibilidad universal |
| **SVG** | ~984 KB | 49 KB | **Vectorial, escalable, 85% más pequeño** |

### Recomendación Principal

**Usar SVG como formato principal** - Es 85% más pequeño y mantiene calidad perfecta en cualquier zoom.

## Estrategias de Optimización

### 1. Balance DPI: Calidad vs Tamaño

#### DPI 300 (Recomendado para PNG)
- **Tamaño de archivo**: ~4x más pequeño que DPI 600
- **Calidad**: Excelente para visualización digital e impresión estándar
- **Uso**: Casos de uso generales

#### DPI 600 (Solo cuando sea necesario)
- **Tamaño de archivo**: 4x más grande
- **Calidad**: Impresión profesional de alta calidad
- **Uso**: Documentación impresa de alta calidad

**Configuración actual**: DPI 600 → **Optimizado a DPI 300**

### 2. Optimización de Fuentes

#### Tamaños de Fuente Optimizados

| Tipo de Elemento | DPI 600 | DPI 300 (Optimizado) | Reducción |
|------------------|---------|----------------------|-----------|
| Fuente por defecto | 16px | 14px | -12.5% |
| Casos de uso | 15px | 13px | -13.3% |
| Actores | 17px | 15px | -11.8% |
| Clases | 12px | 11px | -8.3% |
| Atributos/Métodos | 11px | 10px | -9.1% |

**Legibilidad mantenida**: Las fuentes siguen siendo 100% legibles a DPI 300.

### 3. Formato SVG (Recomendado)

**Ventajas del SVG**:
- ✅ **85% más pequeño** que PNG
- ✅ Escalable sin pérdida de calidad
- ✅ Texto siempre nítido en cualquier zoom
- ✅ Ideal para documentación web y visualización
- ✅ Editable con herramientas vectoriales

**Desventajas**:
- ⚠️ Requiere visor compatible (navegadores modernos)
- ⚠️ No ideal para impresión directa (usar PDF para impresión)

### 4. Compresión Post-Procesamiento (PNG)

Si necesitas PNG, se puede comprimir adicionalmente:

```bash
# Usando optipng (sin pérdida de calidad)
optipng -o7 -strip all docs/diagrams/images/png/*.png

# Usando pngquant (con pérdida mínima)
pngquant --quality=85-95 --ext .png --force docs/diagrams/images/png/*.png
```

### 5. División de Diagramas Grandes

Diagramas complejos pueden dividirse en múltiples diagramas más pequeños:
- **Más legibles**
- **Más fáciles de mantener**
- **Tamaños de archivo más manejables**

Ejemplo: `class_diagram.puml` → Dividido en:
- `class_diagram_core_domain.puml`
- `class_diagram_data_layer.puml`
- `class_diagram_presentation_services.puml`

## Configuración Optimizada Aplicada

### Archivos .puml

```plantuml
' Configuración OPTIMIZADA para balance calidad/tamaño
!define DPI 300
' Sin scale fijo - PlantUML calcula automáticamente

skinparam defaultFontSize 14
skinparam usecaseFontSize 13
skinparam actorFontSize 15
skinparam classFontSize 11
```

### Script de Exportación

El script `export_diagrams_high_quality.sh` ahora:
- ✅ Exporta a **SVG** (formato principal, más pequeño)
- ✅ Exporta a **PNG 300 DPI** (balance calidad/tamaño)
- ✅ Limpia imágenes anteriores automáticamente
- ✅ Opción de compresión post-procesamiento

## Tamaños Esperados Después de Optimización

| Tipo de Diagrama | PNG Actual (600 DPI) | PNG Optimizado (300 DPI) | SVG (Recomendado) |
|------------------|---------------------|--------------------------|-------------------|
| Sequence (grande) | ~160 KB | ~40 KB | ~96 KB |
| Use Case | ~540 KB | ~135 KB | ~72 KB |
| Class Diagram | ~600 KB | ~150 KB | ~100 KB |
| **Reducción** | - | **75% más pequeño** | **85% más pequeño** |

## Recomendaciones por Uso

### Documentación Web / Markdown
→ **Usar SVG** (formato principal)

### Impresión Estándar
→ **Usar PNG 300 DPI**

### Impresión Profesional
→ **Usar PDF** o PNG 600 DPI (solo si es necesario)

### Presentaciones
→ **Usar SVG** (escalable sin pérdida)

### Repositorio Git
→ **Usar SVG** (diferencia de tamaño menor en commits)

## Herramientas de Optimización

### Instalación (EndeavourOS/Arch)

```bash
# Para compresión PNG adicional (opcional)
sudo pacman -S optipng pngquant
```

### Uso

```bash
# Compresión sin pérdida
optipng -o7 docs/diagrams/images/png/*.png

# Compresión con pérdida mínima (85-95% calidad)
pngquant --quality=85-95 --ext .png --force docs/diagrams/images/png/*.png
```

## Métricas de Optimización

### Antes de Optimización
- PNG (600 DPI): 6.6 MB total
- SVG: 984 KB total
- Tamaño combinado: ~7.6 MB

### Después de Optimización (estimado)
- PNG (300 DPI): ~1.6 MB total (-75%)
- SVG: 984 KB total (sin cambios)
- Tamaño combinado: ~2.6 MB (**-66% total**)

## Conclusión

1. **SVG es el formato principal** recomendado (85% más pequeño)
2. **PNG a 300 DPI** para casos específicos (75% más pequeño que 600 DPI)
3. **Fuentes optimizadas** mantienen legibilidad al 100%
4. **División de diagramas** grandes mejora mantenibilidad

La optimización reduce el tamaño total en **~66%** sin sacrificar legibilidad.

