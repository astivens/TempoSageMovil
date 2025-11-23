# Exportar Diagramas PlantUML en EndeavourOS

Guía rápida para instalar y exportar diagramas PlantUML en alta calidad en EndeavourOS (Arch Linux).

## Instalación Rápida

### Paso 1: Instalar PlantUML

```bash
sudo pacman -S plantuml graphviz
```

**Nota:** 
- `plantuml`: La herramienta principal
- `graphviz`: Recomendado para diagramas avanzados y mejor renderizado

### Paso 2: Verificar Instalación

```bash
plantuml -version
```

Deberías ver algo como:
```
PlantUML version X.XX.X (YEAR MM DD)
```

### Paso 3: Verificar Java (si es necesario)

PlantUML requiere Java. Si no está instalado:

```bash
# Verificar si Java está instalado
java -version

# Si no está instalado, instalar JRE
sudo pacman -S jre-openjdk

# O instalar JDK completo (incluye herramientas de desarrollo)
sudo pacman -S jdk-openjdk
```

## Exportar Diagramas

### Opción 1: Usar el Script Automatizado (Recomendado)

```bash
# Desde la raíz del proyecto
./scripts/export_diagrams_high_quality.sh
```

Este script:
- ✅ Exporta todos los diagramas automáticamente
- ✅ Genera SVG (vectorial, mejor calidad)
- ✅ Genera PNG (300 DPI, alta resolución)
- ✅ Genera PDF

**Salida:**
- `docs/diagrams/images/svg/` - Diagramas vectoriales
- `docs/diagrams/images/png/` - Diagramas raster (300 DPI)
- `docs/diagrams/images/pdf/` - Diagramas PDF

### Opción 2: Exportación Individual

```bash
# SVG (recomendado - vectorial, escalable)
plantuml -tsvg -o docs/diagrams/images/svg docs/diagrams/class_diagram.puml

# PNG alta resolución (300 DPI)
plantuml -tpng -SDPI=300 -o docs/diagrams/images/png docs/diagrams/class_diagram.puml

# PDF
plantuml -tpdf -o docs/diagrams/images/pdf docs/diagrams/class_diagram.puml
```

## Formato Recomendado: SVG

**Usa formato SVG** porque:
- ✅ Es vectorial (escalable sin pérdida de calidad)
- ✅ Texto siempre nítido en cualquier zoom
- ✅ Tamaño de archivo razonable
- ✅ Compatible con navegadores y editores modernos

## Solución de Problemas

### Error: "plantuml: command not found"

```bash
# Verificar si está instalado
which plantuml

# Si no está, instalar
sudo pacman -S plantuml graphviz

# Verificar que está en PATH
echo $PATH
```

### Error: "java: command not found"

```bash
# Instalar Java
sudo pacman -S jre-openjdk

# Verificar
java -version
```

### Error: "Graphviz no encontrado" (para diagramas complejos)

```bash
# Instalar Graphviz
sudo pacman -S graphviz

# Verificar
dot -V
```

### Diagramas siguen siendo ilegibles

1. **Asegúrate de usar SVG:**
   ```bash
   plantuml -tsvg docs/diagrams/class_diagram.puml
   ```

2. **Verifica que la configuración de alta calidad esté aplicada:**
   ```bash
   grep "DPI 300" docs/diagrams/*.puml
   ```

3. **Aumenta el DPI manualmente:**
   ```bash
   plantuml -tpng -SDPI=600 docs/diagrams/class_diagram.puml
   ```

## Configuraciones de Alta Calidad

Todos los diagramas ya tienen configuraciones de alta calidad:

```plantuml
' Configuración para exportación en alta calidad
!define DPI 300
scale 2000*1500
```

Estas configuraciones aseguran:
- 300 DPI (alta resolución)
- Tamaño de canvas adecuado
- Texto y elementos nítidos

## Instalación desde AUR (Opcional)

Si prefieres instalar desde AUR:

```bash
# Con yay (recomendado en EndeavourOS)
yay -S plantuml

# Con paru
paru -S plantuml
```

## Instalación Manual (Alternativa)

Si prefieres usar el JAR directamente:

```bash
# Descargar plantuml.jar
mkdir -p ~/.local/share/plantuml
cd ~/.local/share/plantuml
wget https://github.com/plantuml/plantuml/releases/download/v1.2024.5/plantuml-1.2024.5.jar
mv plantuml-*.jar plantuml.jar

# Crear script wrapper
sudo tee /usr/local/bin/plantuml > /dev/null <<EOF
#!/bin/bash
java -jar ~/.local/share/plantuml/plantuml.jar "\$@"
EOF

sudo chmod +x /usr/local/bin/plantuml

# Verificar
plantuml -version
```

## Comandos Útiles

```bash
# Ver versión
plantuml -version

# Listar opciones
plantuml -help

# Exportar con configuración personalizada
plantuml -tsvg -SDPI=600 -Sbackgroundcolor=white docs/diagrams/class_diagram.puml

# Exportar todos los diagramas en un directorio
find docs/diagrams -name "*.puml" -exec plantuml -tsvg {} \;
```

## Recursos

- [PlantUML Official](https://plantuml.com/)
- [Arch Wiki - PlantUML](https://wiki.archlinux.org/title/PlantUML)
- [EndeavourOS Forum](https://forum.endeavouros.com/)

## Notas Finales

- **Recomendación:** Usa SVG para la mejor calidad
- Los archivos SVG pueden abrirse en Firefox, Chrome, Inkscape, VS Code, etc.
- Los diagramas generados estarán en `docs/diagrams/images/` organizados por formato
- EndeavourOS usa `pacman` como gestor de paquetes (similar a Arch Linux)

