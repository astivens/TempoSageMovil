# Herramientas de Scripts para TempoSage

Este directorio contiene scripts y herramientas auxiliares para facilitar el desarrollo y pruebas del proyecto TempoSage.

## Ejecutor de Pruebas (test_runner.dart)

Una aplicación de consola interactiva para ejecutar diferentes tipos de pruebas en el proyecto TempoSage.

### Requisitos

- Dart SDK instalado
- Flutter SDK instalado
- Estar en el directorio raíz del proyecto

### Uso

#### Modo Interactivo

```bash
dart run scripts/test_runner.dart
```

Esto abrirá un menú interactivo donde podrás:
- Seleccionar categorías de pruebas
- Elegir pruebas específicas para ejecutar
- Ver resultados en tiempo real
- Navegar entre diferentes opciones

#### Modo Línea de Comandos

```bash
dart run scripts/test_runner.dart [categoría] [opción]
```

Por ejemplo:
```bash
# Ejecutar pruebas de rendimiento de repositorio
dart run scripts/test_runner.dart 3 2

# Ejecutar todas las pruebas unitarias
dart run scripts/test_runner.dart 1 1

# Ver ayuda
dart run scripts/test_runner.dart --help
```

### Categorías de Pruebas

1. **Pruebas Unitarias** - Pruebas de lógica y componentes individuales
2. **Pruebas de Widget** - Pruebas de componentes visuales
3. **Pruebas de Rendimiento** - Análisis de rendimiento y eficiencia
4. **Pruebas de Integración** - Pruebas end-to-end y de integración
5. **Pruebas Completas** - Ejecutar todas las pruebas
6. **Utilidades** - Herramientas auxiliares para pruebas

### Agregar Nuevas Pruebas

Para agregar nuevas opciones de prueba, edita el archivo `scripts/test_runner.dart` y modifica el mapa `categories` en la clase `TestRunner`.

Ejemplo:
```dart
'7': TestCategory(
  name: 'Mis Pruebas Personalizadas',
  description: 'Pruebas específicas para mi módulo',
  options: {
    '1': TestOption(
      name: 'Prueba específica',
      command: 'flutter test test/unit/mi_modulo/mi_prueba.dart',
    ),
  },
),
``` 