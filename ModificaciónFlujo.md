# Plan de Especificaciones de Diseño para TempoSage

## Principios Guía
- **Simplicidad ante todo**: Mostrar solo lo esencial en cada pantalla
- **Interacción mínima**: Lograr objetivos con pocos toques
- **Contextual**: Ofrecer herramientas solo cuando son relevantes
- **Asistente, no intruso**: ML debe ayudar sin imponerse

## Estilo Visual

### Estilo de Diseño
- **Base**: Material Design 3 (Material You)
- **Enfoque**: Minimalismo funcional con interfaces limpias
- **Personalidad**: Tranquilidad y organización

### Paleta de Colores
- **Dependencia**: `catppuccin_flutter: ^1.0.0` (ya implementada)
- **Temas disponibles**:
  - **Modo claro**: Catppuccin Latte
  - **Modo oscuro**: Catppuccin Mocha  
- **Configuración**: Usar `AppColors.getCatppuccinColor()` para acceso dinámico
- **Colores principales**:
  - Primario: `blue` (azul catppuccin)
  - Secundario: `mauve` (lavanda catppuccin)
  - Acento: `peach` (melocotón catppuccin)
  - Éxito: `green`
  - Error: `red`
  - Advertencia: `yellow`
  - Información: `sapphire`

### Tipografía
- **Fuente principal**: Noto Sans (ya configurada)
- **Tamaños** (siguiendo Material 3):
  - `headlineLarge`: 26sp
  - `titleLarge`: 24sp
  - `titleMedium`: 20sp
  - `bodyLarge`: 18sp
  - `bodyMedium`: 14sp
  - `bodySmall`: 12sp

### Elementos Visuales
- **Bordes**: Radio de esquina 16dp (tarjetas), 12dp (botones)
- **Elevación**: Máximo 2dp para tarjetas
- **Animaciones**: Duración máxima 300ms con `Curves.easeOutCubic`
- **Iconografía**: Material Icons, 24dp estándar

## Componentes Implementados

### Widgets Principales
- `AccessibleCard`: Tarjetas con soporte para accesibilidad
- `AccessibleButton`: Botones con estados y variantes
- `ExpandableFAB`: FAB expandible para múltiples acciones
- `CustomAppBar`: AppBar personalizada
- `UnifiedDisplayCard`: Tarjetas deslizables para listas
- `ThemedWidgetWrapper`: Wrapper para temas dinámicos

### Navegación
- `BottomNavigation`: Barra inferior implementada
- 4 secciones principales: Dashboard, Actividades, Hábitos, Bloques de Tiempo
- Transiciones suaves entre pantallas

## Flujo de Recomendaciones ML

### Actividades Recomendadas
1. **Notificación discreta**: 
   - Ícono de bombilla (16dp) en Dashboard
   - Color: `catppuccin.peach` según tema actual
2. **Tarjeta expandible**:
   - Altura base: 80dp (expandible hasta 160dp)
   - Usar `AccessibleCard.elevated()`
   - Máximo 2 recomendaciones por tarjeta
3. **Interacciones**:
   - Deslizar derecha = Aceptar (animación check verde)
   - Deslizar izquierda = Descartar
   - Tocar = Expandir opciones

### Hábitos Recomendados
1. **Presentación contextual**:
   - Usar `UnifiedDisplayCard` con indicador visual
   - Gradiente sutil con `catppuccin.blue`
2. **Adopción**:
   - Botón "Probar por 3 días" usando `AccessibleButton.primary()`
   - Indicador de progreso durante periodo de prueba

## Interacciones Clave

### Creación Rápida
- **ExpandableFAB** ya implementado:
  - Diámetro: 56dp
  - Color: `theme.colorScheme.primary`
  - Expande 3 opciones máximo
- **Formularios**:
  - Modal desde abajo (60% altura)
  - Usar `CustomAppBar.detail()` para navegación
  - Botones: cancelar (texto) y guardar (relleno)

### Notificaciones
- **Estilo**: Usar `AccessibleCard` con altura 72dp
- **Agrupamiento**: Indicador numérico para múltiples
- **Acciones**: Botones de texto con colores temáticos

### Estados de la UI

#### Estado Vacío
- Ilustración 200dp x 200dp con `catppuccin.blue` 40% opacidad
- Mensaje con `theme.textTheme.titleMedium`
- `AccessibleButton.primary()` para acción principal

#### Estado de Carga
- `CircularProgressIndicator` 36dp
- Color: `theme.colorScheme.primary`
- Skeleton screens con animación sutil

#### Estado de Error
- Ícono 32dp con `catppuccin.red`
- Mensaje con `theme.textTheme.bodyMedium`
- Botón de reintento usando `TextButton`

## Configuración de Tema

### Implementación Actual
```dart
// Ya configurado en AppColors
static Color getCatppuccinColor(BuildContext context, {required String colorName})

// Temas en AppStyles
static ThemeData get lightTheme // Usando catppuccin.latte
static ThemeData get darkTheme   // Usando catppuccin.mocha
```

### Uso Recomendado
```dart
// Para componentes nuevos
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
final primaryColor = AppColors.getCatppuccinColor(context, colorName: 'blue');

// O usar el ThemeManager existente
final themeManager = ThemeManager.of(context);
```

## Consideraciones de Accesibilidad

- Usar `AccessibilityStyles.spacingMedium` para espaciado consistente
- Mínimo contraste 4.5:1 (ya configurado en Catppuccin)
- Áreas de toque mínimo 48dp
- Soporte para escalado de texto
- Labels semánticos en todos los elementos interactivos

## Flujo de Desarrollo

1. **Nuevos componentes**: Extender widgets existentes en `lib/core/widgets/`
2. **Colores**: Usar `AppColors.getCatppuccinColor()` exclusivamente
3. **Tipografía**: Referenciar `theme.textTheme.*`
4. **Animaciones**: Usar constantes de `AppAnimations`
5. **Testing**: Seguir patrones en `/test/` con mocks de dependencias