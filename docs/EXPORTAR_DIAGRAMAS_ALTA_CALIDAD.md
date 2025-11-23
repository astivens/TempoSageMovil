# Exportar Diagramas PlantUML en Alta Calidad

Este documento explica cómo exportar los diagramas PlantUML del proyecto en alta calidad para evitar problemas de legibilidad.

> **Para usuarios de EndeavourOS/Arch Linux:** Ver [EXPORTAR_DIAGRAMAS_ENDEAVOUROS.md](EXPORTAR_DIAGRAMAS_ENDEAVOUROS.md) para guía rápida específica.

## Problema

Los diagramas exportados en baja calidad pueden ser ilegibles, especialmente cuando contienen texto pequeño o muchas clases/entidades.

## Solución

Se ha implementado una solución completa que incluye:

1. **Configuraciones de alta calidad en los archivos PUML**
2. **Script automatizado de exportación**
3. **Múltiples formatos de salida (SVG, PNG, PDF)**

## Configuraciones Aplicadas

Todos los archivos `.puml` ahora incluyen configuraciones de alta calidad:

```plantuml
' Configuración para exportación en alta calidad
!define DPI 300
scale 2000*1500
```

Esto asegura que:
- Los diagramas se rendericen a 300 DPI (alta resolución)
- El tamaño del canvas sea suficiente para evitar compresión
- El texto y elementos gráficos sean nítidos

## Formato Recomendado: SVG

**El formato SVG es el más recomendado** porque:
- ✅ Es vectorial (escalable sin pérdida de calidad)
- ✅ Texto siempre nítido en cualquier zoom
- ✅ Tamaño de archivo razonable
- ✅ Compatible con navegadores y editores modernos

## Métodos de Exportación

### Método 1: Script Automatizado (Recomendado)

El script `export_diagrams_high_quality.sh` exporta todos los diagramas automáticamente:

```bash
# Desde la raíz del proyecto
./scripts/export_diagrams_high_quality.sh
```

**Salida:**
- `docs/diagrams/images/svg/` - Diagramas en formato SVG (vectorial)
- `docs/diagrams/images/png/` - Diagramas en formato PNG (300 DPI)
- `docs/diagrams/images/pdf/` - Diagramas en formato PDF

### Método 2: PlantUML CLI Individual

Para exportar un diagrama individual:

#### SVG (Recomendado)
```bash
plantuml -tsvg -o docs/diagrams/images/svg docs/diagrams/class_diagram.puml
```

#### PNG Alta Resolución (300 DPI)
```bash
plantuml -tpng -SDPI=300 -o docs/diagrams/images/png docs/diagrams/class_diagram.puml
```

#### PDF
```bash
plantuml -tpdf -o docs/diagrams/images/pdf docs/diagrams/class_diagram.puml
```

### Método 3: Usando plantuml.jar

Para mayor control, usar `plantuml.jar` directamente:

```bash
java -Djava.awt.headless=true -jar plantuml.jar \
    -tsvg \
    -SDPI=300 \
    -o docs/diagrams/images/svg \
    docs/diagrams/class_diagram.puml
```

## Requisitos Previos

### Instalar PlantUML

#### EndeavourOS / Arch Linux
```bash
sudo pacman -S plantuml graphviz
```

**Nota:** Graphviz es recomendado para diagramas avanzados. Si ya tienes Java instalado, PlantUML funcionará. Si no:
```bash
sudo pacman -S jre-openjdk  # Runtime de Java
# o
sudo pacman -S jdk-openjdk  # JDK completo (incluye herramientas de desarrollo)
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install plantuml
```

#### macOS (Homebrew)
```bash
brew install plantuml
```

#### Manual
1. Descargar `plantuml.jar` desde https://plantuml.com/download
2. Guardar en un directorio accesible (ej: `~/bin/`)
3. Crear alias o script wrapper

### Verificar Instalación

```bash
# Verificar PlantUML
plantuml -version

# Verificar Java (requerido)
java -version

# Si instalaste desde AUR o manualmente con JAR
java -jar plantuml.jar -version
```

## Configuración de Escala por Tipo de Diagrama

Diferentes tipos de diagramas tienen diferentes tamaños optimizados:

| Tipo de Diagrama | Escala Configurada | Razón |
|-----------------|-------------------|-------|
| Use Case | 1500×1200 | Diagramas medianos |
| Class | 2000×1500 | Muchas clases, necesita espacio |
| Entity-Relationship | 2000×1500 | Muchas entidades y relaciones |
| Component | 2000×1500 | Componentes y dependencias |
| Sequence | 1800×2000-2500 | Diagramas verticales largos |

Puedes ajustar estos valores en los archivos `.puml` si necesitas más o menos espacio.

## Opciones Avanzadas

### Personalizar DPI

Editar la línea en cada archivo `.puml`:

```plantuml
!define DPI 300  # Cambiar a 150, 200, 300, 600, etc.
```

**Recomendaciones:**
- **150 DPI**: Para web básico
- **300 DPI**: Para impresión y alta calidad (recomendado)
- **600 DPI**: Para impresión profesional (archivos grandes)

### Personalizar Escala

Ajustar el tamaño del canvas:

```plantuml
scale 2000*1500  # Ancho × Alto en píxeles
```

**Consideraciones:**
- Valores muy grandes generan archivos grandes
- Valores muy pequeños pueden comprimir el contenido
- Mantener proporción similar a 4:3 o 16:9

### Exportar Solo SVG (Ligero)

Para exportar solo formato SVG (más ligero):

```bash
# Modificar script o usar directamente
find docs/diagrams -name "*.puml" -exec plantuml -tsvg -o docs/diagrams/images/svg {} \;
```

## Solución de Problemas

### Error: PlantUML no encontrado

```bash
# Verificar instalación
which plantuml

# Si no está instalado
sudo pacman -S plantuml graphviz  # EndeavourOS/Arch Linux
sudo apt install plantuml         # Ubuntu/Debian
brew install plantuml             # macOS
```

### Error: Java no encontrado

PlantUML requiere Java:

```bash
# EndeavourOS/Arch Linux
sudo pacman -S jre-openjdk    # Solo runtime
# o
sudo pacman -S jdk-openjdk    # JDK completo

# Ubuntu/Debian
sudo apt install default-jre

# macOS (generalmente ya incluido, si no)
brew install openjdk

# Verificar instalación
java -version
```

### Diagramas siguen siendo ilegibles

1. **Verificar que la configuración DPI esté aplicada:**
   ```bash
   grep -A 2 "Configuración para exportación" docs/diagrams/*.puml
   ```

2. **Exportar en formato SVG (mejor calidad):**
   ```bash
   plantuml -tsvg docs/diagrams/class_diagram.puml
   ```

3. **Aumentar DPI manualmente:**
   ```bash
   plantuml -tpng -SDPI=600 docs/diagrams/class_diagram.puml
   ```

4. **Aumentar escala en el archivo PUML:**
   ```plantuml
   scale 3000*2000  # Aumentar valores
   ```

### Texto borroso en PNG

- **Usar formato SVG** en lugar de PNG
- **Aumentar DPI** a 600
- **Verificar tamaño de fuente** en el archivo PUML

## Integración en CI/CD

Para exportar diagramas automáticamente en pipelines:

```yaml
# Ejemplo GitHub Actions
- name: Export PlantUML Diagrams
  run: |
    sudo apt-get update
    sudo apt-get install -y plantuml
    ./scripts/export_diagrams_high_quality.sh
```

## Referencias

- [Documentación oficial de PlantUML](https://plantuml.com/)
- [Opciones de línea de comandos](https://plantuml.com/command-line)
- [Configuración de escala y DPI](https://plantuml.com/es/command-line)

## Notas Finales

- **Siempre usa SVG** para la mejor calidad en pantalla
- **Usa PNG 300 DPI** solo si necesitas rasterización
- **Usa PDF** para documentos impresos
- Los archivos SVG pueden abrirse en navegadores, editores de vectores (Inkscape, Illustrator) y muchos visores
- Los archivos generados están en `docs/diagrams/images/` organizados por formato

