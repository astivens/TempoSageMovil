# DISEÑO DE PRUEBAS UNITARIAS EXTENDIDAS - TEMPOSAGE

## 1. INTRODUCCIÓN

Este documento presenta el diseño sistemático de pruebas unitarias extendidas para la aplicación TempoSage, basado en el análisis completo del código fuente. El objetivo es expandir la cobertura de pruebas del 10.5% actual al 100% de los módulos críticos.

## 2. METODOLOGÍA DE DISEÑO

### 2.1 Técnicas de Diseño de Pruebas

- **Clases de Equivalencia**: Dividir datos de entrada en grupos válidos e inválidos
- **Valores Límite**: Probar valores en los límites de las clases de equivalencia
- **Cobertura de Caminos**: Ejecutar todos los caminos posibles en el código
- **Pruebas de Estado**: Verificar transiciones de estado en objetos
- **Pruebas de Contrato**: Validar cumplimiento de interfaces y contratos

### 2.2 Criterios de Cobertura

- **Cobertura de Líneas**: 100% de líneas de código ejecutables
- **Cobertura de Ramas**: 100% de ramas condicionales
- **Cobertura de Funciones**: 100% de métodos públicos
- **Cobertura de Estados**: 100% de estados posibles

## 3. FASE 1: MODELOS DE DATOS (PRIORIDAD ALTA)

### 3.1 HabitModel - Pruebas Unitarias

**Ubicación:** `lib/features/habits/data/models/habit_model.dart`

#### 3.1.1 Clases de Equivalencia

| **Campo** | **Clase Válida** | **Clase Inválida** |
|:-:|:-:|:-:|
| **id** | UUID válido, no vacío | null, vacío, formato inválido |
| **title** | 1-100 caracteres, no vacío | null, vacío, >100 caracteres |
| **description** | 0-500 caracteres | >500 caracteres |
| **daysOfWeek** | Lista con 1-7 días válidos | null, vacío, días inválidos |
| **category** | Categorías predefinidas | null, vacío, categorías inválidas |
| **streak** | 0-365 días | <0, >365 |
| **totalCompletions** | 0-10000 | <0, >10000 |

#### 3.1.2 Valores Límite

| **Campo** | **Valores Límite** |
|:-:|:-:|
| **title** | "", "a", "a"*100, "a"*101 |
| **description** | "", "a"*500, "a"*501 |
| **streak** | -1, 0, 365, 366 |
| **totalCompletions** | -1, 0, 10000, 10001 |

#### 3.1.3 Casos de Prueba Estimados: 20

1. **Constructor Principal** (5 pruebas)
   - Creación con todos los parámetros válidos
   - Creación con parámetros opcionales
   - Validación de campos requeridos
   - Manejo de valores null
   - Validación de tipos de datos

2. **Factory Constructor** (3 pruebas)
   - `HabitModel.create()` con datos válidos
   - Generación automática de ID
   - Valores por defecto correctos

3. **Método copyWith** (5 pruebas)
   - Copia con modificaciones parciales
   - Copia sin modificaciones
   - Validación de campos modificados
   - Inmutabilidad del objeto original
   - Casos extremos de modificación

4. **Validaciones de Negocio** (4 pruebas)
   - Validación de días de semana
   - Validación de categorías
   - Validación de fechas
   - Validación de streak

5. **Serialización Hive** (3 pruebas)
   - Serialización completa
   - Deserialización completa
   - Manejo de campos faltantes

### 3.2 ActivityModel - Pruebas Unitarias

**Ubicación:** `lib/features/activities/data/models/activity_model.dart`

#### 3.2.1 Clases de Equivalencia

| **Campo** | **Clase Válida** | **Clase Inválida** |
|:-:|:-:|:-:|
| **startTime** | Fecha/hora válida | null, fecha pasada inválida |
| **endTime** | Fecha posterior a startTime | null, anterior a startTime |
| **priority** | "Baja", "Media", "Alta" | null, valores inválidos |
| **reminderMinutesBefore** | 1-1440 minutos | <1, >1440 |

#### 3.2.2 Valores Límite

| **Campo** | **Valores Límite** |
|:-:|:-:|
| **reminderMinutesBefore** | 0, 1, 1440, 1441 |
| **startTime/endTime** | Mismo momento, 1ms diferencia |

#### 3.2.3 Casos de Prueba Estimados: 15

1. **Constructor Freezed** (4 pruebas)
   - Creación con parámetros requeridos
   - Valores por defecto
   - Validación de tipos
   - Inmutabilidad

2. **Métodos de Negocio** (6 pruebas)
   - `toggleCompletion()` - cambio de estado
   - `isOverdue` - cálculo de vencimiento
   - `duration` - cálculo de duración
   - `isActive` - estado activo
   - Validaciones de tiempo
   - Casos extremos de fechas

3. **Serialización JSON** (3 pruebas)
   - Serialización completa
   - Deserialización completa
   - Manejo de campos faltantes

4. **Validaciones de Integridad** (2 pruebas)
   - Validación de rangos de tiempo
   - Validación de prioridades

### 3.3 TimeBlockModel - Pruebas Unitarias

**Ubicación:** `lib/features/timeblocks/data/models/time_block_model.dart`

#### 3.3.1 Clases de Equivalencia

| **Campo** | **Clase Válida** | **Clase Inválida** |
|:-:|:-:|:-:|
| **title** | 1-100 caracteres | null, vacío, >100 caracteres |
| **startTime** | DateTime válido | null, formato inválido |
| **endTime** | DateTime posterior a startTime | null, anterior a startTime |
| **color** | Formato #RRGGBB | null, formato inválido |

#### 3.3.2 Valores Límite

| **Campo** | **Valores Límite** |
|:-:|:-:|
| **title** | "", "a", "a"*100, "a"*101 |
| **color** | "#000000", "#FFFFFF", "#12345", "#1234567" |
| **startTime/endTime** | Mismo momento, 1ms diferencia |

#### 3.3.3 Casos de Prueba Estimados: 25

1. **Constructor y Validaciones** (6 pruebas)
   - Creación con datos válidos
   - Validación de título vacío
   - Validación de tiempo de fin
   - Validación de formato de color
   - Manejo de assertions
   - Casos de error

2. **Factory Constructor** (3 pruebas)
   - `TimeBlockModel.create()` válido
   - Generación de UUID
   - Valores por defecto

3. **Getters de Estado** (6 pruebas)
   - `duration` - cálculo correcto
   - `isInProgress` - estado en progreso
   - `isPending` - estado pendiente
   - `isPast` - estado pasado
   - Casos límite de tiempo
   - Precisión de cálculos

4. **Métodos de Modificación** (4 pruebas)
   - `copyWith()` completo
   - `markAsCompleted()` - cambio de estado
   - `markAsNotCompleted()` - cambio de estado
   - Inmutabilidad

5. **Serialización Hive** (3 pruebas)
   - Serialización completa
   - Deserialización completa
   - Manejo de campos faltantes

6. **Validaciones de Integridad** (3 pruebas)
   - Validación de rangos de tiempo
   - Validación de formato de color
   - Validación de categorías

### 3.4 UserModel - Pruebas Unitarias

**Ubicación:** `lib/features/auth/data/models/user_model.dart`

#### 3.4.1 Casos de Prueba Estimados: 12

1. **Constructor y Factory** (5 pruebas)
   - Creación con parámetros válidos
   - `UserModel.create()` factory
   - Validación de campos requeridos
   - Generación de ID automático
   - Valores por defecto

2. **Validaciones de Datos** (4 pruebas)
   - Validación de formato de email
   - Validación de longitud de nombre
   - Validación de hash de contraseña
   - Validación de tipos

3. **Serialización Hive** (3 pruebas)
   - Serialización completa
   - Deserialización completa
   - Manejo de campos faltantes

## 4. FASE 2: UTILIDADES CRÍTICAS (PRIORIDAD ALTA)

### 4.1 FormValidators - Pruebas Unitarias

**Ubicación:** `lib/core/utils/validators/form_validators.dart`

#### 4.1.1 Clases de Equivalencia

| **Método** | **Clase Válida** | **Clase Inválida** |
|:-:|:-:|:-:|
| **validateEmail** | Emails válidos | null, vacío, formato inválido |
| **validatePassword** | 8+ caracteres | null, vacío, <8 caracteres |
| **validateRequired** | Valores no vacíos | null, vacío, espacios |
| **validateTime** | Formato HH:MM | null, vacío, formato inválido |

#### 4.1.2 Valores Límite

| **Método** | **Valores Límite** |
|:-:|:-:|
| **validatePassword** | "", "1234567", "12345678", "123456789" |
| **validateTime** | "", "0:00", "23:59", "24:00", "12:60" |
| **validateEmail** | "", "a@b.c", "user@domain.com", "user@domain.co.uk" |

#### 4.1.3 Casos de Prueba Estimados: 30

1. **validateEmail** (8 pruebas)
   - Emails válidos estándar
   - Emails con subdominios
   - Emails con extensiones múltiples
   - Casos límite válidos
   - Emails inválidos (sin @)
   - Emails inválidos (dominio incompleto)
   - Casos null y vacío
   - Caracteres especiales

2. **validatePassword** (6 pruebas)
   - Contraseñas válidas (8+ caracteres)
   - Contraseñas con caracteres especiales
   - Contraseñas límite (exactamente 8)
   - Contraseñas cortas (<8)
   - Casos null y vacío
   - Contraseñas muy largas

3. **validateRequired** (6 pruebas)
   - Valores válidos no vacíos
   - Strings con contenido
   - Strings con espacios
   - Casos null
   - Strings vacíos
   - Diferentes tipos de datos

4. **validateTime** (10 pruebas)
   - Horas válidas (00:00-23:59)
   - Horas límite (00:00, 23:59)
   - Horas con minutos límite
   - Horas inválidas (>23)
   - Minutos inválidos (>59)
   - Formato inválido (sin :)
   - Formato inválido (caracteres)
   - Casos null y vacío
   - Formato con segundos
   - Formato de 12 horas

### 4.2 DateTimeUtils - Pruebas Unitarias

**Ubicación:** `lib/core/utils/date_time_utils.dart`

#### 4.2.1 Casos de Prueba Estimados: 40

1. **Formateo de Fechas** (8 pruebas)
   - `formatDate()` - formato estándar
   - `formatLongDate()` - formato largo
   - Fechas límite (1/1, 31/12)
   - Años límite (1900, 2100)
   - Diferentes meses
   - Diferentes días
   - Fechas con años bisiestos
   - Casos extremos

2. **Nombres de Días** (6 pruebas)
   - `getDayOfWeekES()` - todos los días
   - `getDayOfWeekEN()` - todos los días
   - Días límite (lunes, domingo)
   - Fechas especiales
   - Diferentes años
   - Casos de año bisiesto

3. **Nombres de Meses** (6 pruebas)
   - `getMonthNameES()` - todos los meses
   - `getShortMonthES()` - abreviaciones
   - Meses límite (enero, diciembre)
   - Diferentes años
   - Casos de año bisiesto
   - Validación de índices

4. **Formateo de Tiempo** (4 pruebas)
   - `formatTime()` - formato HH:MM
   - Horas límite (00:00, 23:59)
   - Diferentes horas del día
   - Precisión de minutos

5. **Operaciones de Fecha** (8 pruebas)
   - `isSameDay()` - comparación correcta
   - `startOfDay()` - inicio del día
   - `endOfDay()` - final del día
   - `combineDateAndTime()` - combinación
   - Fechas límite (cambio de día)
   - Horas límite (00:00, 23:59)
   - Casos de año bisiesto
   - Zonas horarias

6. **Casos Extremos** (8 pruebas)
   - Fechas muy antiguas
   - Fechas futuras
   - Años límite
   - Meses con 28/29/30/31 días
   - Casos de error
   - Valores null
   - Validación de rangos
   - Precisión de tiempo

## 5. PLAN DE IMPLEMENTACIÓN

### 5.1 Cronograma de Desarrollo

| **Fase** | **Módulos** | **Pruebas** | **Duración** | **Prioridad** |
|:-:|:-:|:-:|:-:|:-:|
| **Fase 1** | Modelos de Datos | 72 | 1 semana | 🔴 Alta |
| **Fase 2** | Utilidades Críticas | 70 | 1 semana | 🔴 Alta |
| **Fase 3** | Servicios Core | 45 | 1 semana | 🟡 Media |
| **Fase 4** | Repositorios | 65 | 1 semana | 🟡 Media |
| **TOTAL** | **8 módulos** | **252 pruebas** | **4 semanas** | |

### 5.2 Criterios de Éxito

- ✅ **Cobertura de código**: >95%
- ✅ **Todas las pruebas pasan**: 100%
- ✅ **Tiempo de ejecución**: <30 segundos
- ✅ **Documentación**: Completa y actualizada

### 5.3 Herramientas y Configuración

- **Framework**: flutter_test
- **Mocks**: mockito para dependencias
- **Cobertura**: flutter test --coverage
- **CI/CD**: Integración con pipeline existente

## 6. CONCLUSIÓN

Este diseño sistemático de pruebas unitarias extendidas transformará TempoSage de un proyecto con cobertura básica (10.5%) a uno con cobertura empresarial (100% de módulos críticos). La implementación de estas 252 pruebas adicionales garantizará la máxima calidad, confiabilidad y mantenibilidad del software.

La metodología propuesta incluye técnicas probadas de diseño de pruebas, criterios claros de cobertura y un plan de implementación realista que permitirá al equipo desarrollar pruebas de calidad profesional de manera sistemática y eficiente.
