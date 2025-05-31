# Perfil de Calidad Personalizado para Dart en SonarQube

Este documento describe cómo configurar un perfil de calidad personalizado para Dart en SonarQube para maximizar el análisis de código en el proyecto TempoSage Móvil.

## Crear un nuevo perfil de calidad

1. Inicia sesión en SonarQube como administrador
2. Ve a **Administración > Perfiles de Calidad**
3. Haz clic en **Crear**
4. Completa los siguientes campos:
   - **Nombre**: `TempoSage Dart Quality Profile`
   - **Lenguaje**: `Dart`
   - **Copiar de**: `Sonar way` (perfil predeterminado)
5. Haz clic en **Crear**

## Reglas recomendadas para activar

Además de las reglas incluidas en el perfil Sonar way, recomendamos activar las siguientes reglas:

### Convenciones de código

- `always_require_non_null_named_parameters`: Requiere que los parámetros nombrados no sean nulos
- `avoid_empty_else`: Evita bloques else vacíos
- `avoid_relative_lib_imports`: Evita importaciones relativas en lib/
- `avoid_returning_null_for_future`: Evita devolver null en Future
- `avoid_void_async`: Evita funciones async void
- `cancel_subscriptions`: Cancela las suscripciones
- `close_sinks`: Cierra los sinks
- `directives_ordering`: Orden de directivas
- `package_api_docs`: Documentación de API de paquete
- `prefer_final_fields`: Prefiere campos finales
- `prefer_final_locals`: Prefiere variables locales finales

### Seguridad

- `avoid_dynamic_calls`: Evita llamadas dinámicas
- `avoid_js_rounded_ints`: Evita enteros redondeados de JS
- `only_throw_errors`: Solo lanza errores

### Rendimiento

- `avoid_unnecessary_containers`: Evita contenedores innecesarios
- `prefer_is_empty`: Prefiere isEmpty
- `prefer_is_not_empty`: Prefiere isNotEmpty

## Configurar el perfil como predeterminado para el proyecto

1. Ve a **Perfiles de Calidad**
2. Busca tu perfil recién creado `TempoSage Dart Quality Profile`
3. Haz clic en los tres puntos (**⋮**) y selecciona **Establecer como predeterminado**
4. Selecciona tu proyecto `temposage-movil` y haz clic en **Establecer como predeterminado**

## Configurar Quality Gate personalizada

Una Quality Gate determina si tu código pasa el análisis de calidad. Para crear una personalizada:

1. Ve a **Administración > Quality Gates**
2. Haz clic en **Crear**
3. Nombra la puerta de calidad, por ejemplo, `TempoSage Quality Gate`
4. Añade las siguientes condiciones:
   - Cobertura de código: mínimo 80%
   - Duplicaciones: máximo 3%
   - Deuda técnica: máximo 5% del tiempo de desarrollo
   - Issues bloqueantes: 0
   - Vulnerabilidades: 0
   - Code smells: máximo 10

5. Establece esta Quality Gate como predeterminada para tu proyecto 