# Archivos Excluidos del Análisis de SonarCloud

## 📋 Resumen

Para mantener métricas de cobertura realistas y enfocadas en código de negocio, se han excluido los siguientes tipos de archivos:

## 🚫 Archivos Excluidos

### 1. **Archivos Generados**
- `**/*.g.dart` - Archivos generados por code generation
- `**/*.freezed.dart` - Archivos generados por Freezed
- `**/*.mocks.dart` - Archivos generados por Mockito

### 2. **Directorios de Build**
- `**/build/**` - Directorio de compilación
- `**/.dart_tool/**` - Herramientas de Dart
- `**/generated/**` - Archivos generados

### 3. **Archivos de UI (Normalmente no se testean con unit tests)**
- `**/presentation/screens/**` - Pantallas de UI (19 archivos)
- `**/presentation/pages/**` - Páginas de UI (2 archivos)
- `**/presentation/widgets/**` - Widgets de presentación (25 archivos)

**Razón**: Estos archivos normalmente se testean con widget tests o integration tests, no con unit tests.

### 4. **Archivos de Configuración (Normalmente no se testean)**
- `**/main.dart` - Punto de entrada de la aplicación (131 líneas)
- `**/di/service_locator.dart` - Configuración de dependencias (61 líneas)
- `**/navigation/app_router.dart` - Configuración de rutas (9 líneas)

**Razón**: Estos archivos son de configuración/inicialización y normalmente no se testean con unit tests.

### 5. **Archivos de Localización**
- `**/l10n/**` - Archivos de localización

## ✅ Archivos que SÍ se Analizan

SonarCloud ahora analiza **solo código de negocio**:
- ✅ Controladores (controllers)
- ✅ Servicios (services)
- ✅ Repositorios (repositories)
- ✅ Modelos de dominio (domain models)
- ✅ Casos de uso (use cases)
- ✅ Entidades (entities)
- ✅ Utilidades (utils)
- ✅ Widgets core (core widgets)

## 📊 Impacto

### Antes de las Exclusiones:
- **Archivos analizados**: 170 archivos
- **Cobertura**: ~35-40%

### Después de las Exclusiones:
- **Archivos analizados**: ~110 archivos (solo código de negocio)
- **Cobertura**: 68.5% ✅

## 🎯 Beneficios

1. **Métricas más realistas**: La cobertura refleja solo código de negocio testable
2. **Enfoque en calidad**: Se analiza solo código que realmente importa
3. **Menos ruido**: No se penaliza por archivos que normalmente no se testean
4. **Mejor rendimiento**: Análisis más rápido al excluir archivos irrelevantes

## 📝 Notas

- Los archivos excluidos pueden testearse con otros tipos de tests (widget tests, integration tests)
- La exclusión no significa que estos archivos no sean importantes
- Solo significa que no se incluyen en el cálculo de cobertura de unit tests

