# PRUEBAS DE CAJA NEGRA - MÉTODOS DE CREACIÓN
## TempoSageMovil - Sistema de Gestión de Productividad

---

## INDICE

1. [Introducción](#introducción)
2. [Método: Crear Hábito](#método-crear-hábito)
3. [Método: Crear Actividad/Tarea](#método-crear-actividadtarea)
4. [Método: Crear Time Block](#método-crear-time-block)
5. [Casos de Prueba Comunes](#casos-de-prueba-comunes)
6. [Matriz de Cobertura](#matriz-de-cobertura)

---

## INTRODUCCIÓN

Este documento presenta las **pruebas de caja negra** para los métodos de creación de entidades principales en TempoSageMovil. Las pruebas se enfocan en validar el comportamiento externo de los métodos sin conocer su implementación interna.

### Objetivos de las Pruebas
- Validar la funcionalidad de creación de entidades
- Verificar el manejo de casos límite y errores
- Asegurar la integridad de los datos
- Confirmar el comportamiento esperado del sistema

---

## MÉTODO: CREAR HÁBITO

### **Firma del Método**
```dart
Future<void> createHabit({
  required String name,
  required String description,
  required List<String> daysOfWeek,
  required String category,
  required String reminder,
  required String time,
}) async
```

### **Parámetros de Entrada**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `name` | String | SI | Nombre del hábito |
| `description` | String | SI | Descripción detallada |
| `daysOfWeek` | List<String> | SI | Días de la semana |
| `category` | String | SI | Categoría del hábito |
| `reminder` | String | SI | Tipo de recordatorio |
| `time` | String | SI | Hora del hábito |

### **Casos de Prueba**

#### **CP-H-001: Creación Exitosa de Hábito**
- **Entrada**: 
  - name: "Ejercicio Matutino"
  - description: "30 minutos de cardio"
  - daysOfWeek: ["Lunes", "Miércoles", "Viernes"]
  - category: "Salud"
  - reminder: "Si"
  - time: "07:00"
- **Resultado Esperado**: Hábito creado exitosamente
- **Validaciones**:
  - ID único generado
  - Fecha de creación establecida
  - Estado inicial: no completado
  - Streak inicial: 0
  - Total completions: 0

#### **CP-H-002: Nombre Vacío**
- **Entrada**: 
  - name: ""
  - description: "Descripción válida"
  - daysOfWeek: ["Lunes"]
  - category: "Trabajo"
  - reminder: "No"
  - time: "09:00"
- **Resultado Esperado**: Error - "El nombre no puede estar vacío"

#### **CP-H-003: Lista de Días Vacía**
- **Entrada**: 
  - name: "Hábito Válido"
  - description: "Descripción válida"
  - daysOfWeek: []
  - category: "Personal"
  - reminder: "No"
  - time: "10:00"
- **Resultado Esperado**: Error - "Selecciona al menos un día"

#### **CP-H-004: Días de Semana Inválidos**
- **Entrada**: 
  - name: "Hábito Válido"
  - description: "Descripción válida"
  - daysOfWeek: ["Día Inválido", "Lunes"]
  - category: "Estudio"
  - reminder: "No"
  - time: "14:00"
- **Resultado Esperado**: Error - "Días de semana inválidos"

#### **CP-H-005: Formato de Hora Inválido**
- **Entrada**: 
  - name: "Hábito Válido"
  - description: "Descripción válida"
  - daysOfWeek: ["Lunes"]
  - category: "Ocio"
  - reminder: "No"
  - time: "25:70"
- **Resultado Esperado**: Error - "Formato de hora inválido"

#### **CP-H-006: Hábito Duplicado**
- **Entrada**: 
  - name: "Hábito Existente"
  - description: "Descripción válida"
  - daysOfWeek: ["Lunes"]
  - category: "Trabajo"
  - reminder: "No"
  - time: "09:00"
- **Resultado Esperado**: Error - "Ya existe un hábito con este nombre"

#### **CP-H-007: Caracteres Especiales en Nombre**
- **Entrada**: 
  - name: "Hábito@#$%"
  - description: "Descripción válida"
  - daysOfWeek: ["Lunes"]
  - category: "Personal"
  - reminder: "No"
  - time: "08:00"
- **Resultado Esperado**: Error - "Nombre contiene caracteres inválidos"

#### **CP-H-008: Nombre Muy Largo**
- **Entrada**: 
  - name: "A" * 256
  - description: "Descripción válida"
  - daysOfWeek: ["Lunes"]
  - category: "Trabajo"
  - reminder: "No"
  - time: "09:00"
- **Resultado Esperado**: Error - "Nombre demasiado largo"

---

## MÉTODO: CREAR ACTIVIDAD/TAREA

### **Firma del Método**
```dart
Future<void> addActivity(ActivityModel activity) async
```

### **Estructura ActivityModel**
```dart
ActivityModel({
  required String id,
  required String title,
  required String description,
  required String category,
  required DateTime startTime,
  required DateTime endTime,
  @Default('Media') String priority,
  @Default(true) bool sendReminder,
  @Default(15) int reminderMinutesBefore,
  @Default(false) bool isCompleted,
})
```

### **Casos de Prueba**

#### **CP-A-001: Creación Exitosa de Actividad**
- **Entrada**: 
  - id: "auto-generated"
  - title: "Reunión de Equipo"
  - description: "Revisión de progreso semanal"
  - category: "Trabajo"
  - startTime: DateTime(2024, 1, 15, 10, 0)
  - endTime: DateTime(2024, 1, 15, 11, 0)
  - priority: "Alta"
  - sendReminder: true
  - reminderMinutesBefore: 15
  - isCompleted: false
- **Resultado Esperado**: Actividad creada exitosamente
- **Validaciones**:
  - ID único generado
  - Duración calculada correctamente
  - Notificación programada si sendReminder = true
  - Sincronización con TimeBlock

#### **CP-A-002: Título Vacío**
- **Entrada**: 
  - title: ""
  - description: "Descripción válida"
  - category: "Trabajo"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 1))
- **Resultado Esperado**: Error - "El título no puede estar vacío"

#### **CP-A-003: Hora de Fin Anterior a Hora de Inicio**
- **Entrada**: 
  - title: "Actividad Válida"
  - description: "Descripción válida"
  - category: "Personal"
  - startTime: DateTime(2024, 1, 15, 14, 0)
  - endTime: DateTime(2024, 1, 15, 13, 0)
- **Resultado Esperado**: Error - "La hora de fin debe ser posterior a la hora de inicio"

#### **CP-A-004: Fecha en el Pasado**
- **Entrada**: 
  - title: "Actividad Pasada"
  - description: "Descripción válida"
  - category: "Trabajo"
  - startTime: DateTime(2020, 1, 1, 10, 0)
  - endTime: DateTime(2020, 1, 1, 11, 0)
- **Resultado Esperado**: Advertencia - "La actividad está programada en el pasado"

#### **CP-A-005: Duración Muy Larga**
- **Entrada**: 
  - title: "Actividad Larga"
  - description: "Descripción válida"
  - category: "Estudio"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(days: 2))
- **Resultado Esperado**: Advertencia - "Duración muy larga para una actividad"

#### **CP-A-006: Categoría Inválida**
- **Entrada**: 
  - title: "Actividad Válida"
  - description: "Descripción válida"
  - category: "Categoría Inexistente"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 1))
- **Resultado Esperado**: Error - "Categoría no válida"

#### **CP-A-007: Prioridad Inválida**
- **Entrada**: 
  - title: "Actividad Válida"
  - description: "Descripción válida"
  - category: "Trabajo"
  - priority: "Muy Alta"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 1))
- **Resultado Esperado**: Error - "Prioridad no válida"

#### **CP-A-008: Recordatorio con Tiempo Inválido**
- **Entrada**: 
  - title: "Actividad Válida"
  - description: "Descripción válida"
  - category: "Personal"
  - sendReminder: true
  - reminderMinutesBefore: -5
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 1))
- **Resultado Esperado**: Error - "Tiempo de recordatorio inválido"

---

## MÉTODO: CREAR TIME BLOCK

### **Firma del Método**
```dart
Future<void> addTimeBlock(TimeBlockModel timeBlock) async
```

### **Estructura TimeBlockModel**
```dart
TimeBlockModel({
  required String id,
  required String title,
  required String description,
  required DateTime startTime,
  required DateTime endTime,
  required String category,
  bool isFocusTime = false,
  required String color,
  bool isCompleted = false,
})
```

### **Casos de Prueba**

#### **CP-TB-001: Creación Exitosa de Time Block**
- **Entrada**: 
  - id: "auto-generated"
  - title: "Bloque de Trabajo"
  - description: "Trabajo en proyecto importante"
  - startTime: DateTime(2024, 1, 15, 9, 0)
  - endTime: DateTime(2024, 1, 15, 11, 0)
  - category: "Work"
  - isFocusTime: true
  - color: "#9D7CD8"
  - isCompleted: false
- **Resultado Esperado**: Time Block creado exitosamente
- **Validaciones**:
  - ID único generado
  - Duración calculada correctamente
  - Color válido aplicado
  - Estado inicial: no completado

#### **CP-TB-002: Título Vacío**
- **Entrada**: 
  - title: ""
  - description: "Descripción válida"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 2))
  - category: "Personal"
  - color: "#7AA2F7"
- **Resultado Esperado**: Error - "El título no puede estar vacío"

#### **CP-TB-003: Hora de Fin Anterior a Hora de Inicio**
- **Entrada**: 
  - title: "Time Block Válido"
  - description: "Descripción válida"
  - startTime: DateTime(2024, 1, 15, 14, 0)
  - endTime: DateTime(2024, 1, 15, 13, 0)
  - category: "Study"
  - color: "#9ECE6A"
- **Resultado Esperado**: Error - "La hora de finalización debe ser posterior a la hora de inicio"

#### **CP-TB-004: Color Inválido**
- **Entrada**: 
  - title: "Time Block Válido"
  - description: "Descripción válida"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 1))
  - category: "Work"
  - color: "rojo"
- **Resultado Esperado**: Error - "El color debe estar en formato hexadecimal (#RRGGBB)"

#### **CP-TB-005: Categoría Inválida**
- **Entrada**: 
  - title: "Time Block Válido"
  - description: "Descripción válida"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 1))
  - category: "Categoría Inexistente"
  - color: "#F7768E"
- **Resultado Esperado**: Error - "Categoría no válida"

#### **CP-TB-006: Time Block Duplicado**
- **Entrada**: 
  - title: "Time Block Existente"
  - description: "Descripción válida"
  - startTime: DateTime(2024, 1, 15, 9, 0)
  - endTime: DateTime(2024, 1, 15, 11, 0)
  - category: "Work"
  - color: "#E0AF68"
- **Resultado Esperado**: Error - "Ya existe un time block similar"

#### **CP-TB-007: Duración Muy Corta**
- **Entrada**: 
  - title: "Time Block Corto"
  - description: "Descripción válida"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(minutes: 5))
  - category: "Personal"
  - color: "#9D7CD8"
- **Resultado Esperado**: Advertencia - "Duración muy corta para un time block"

#### **CP-TB-008: Duración Muy Larga**
- **Entrada**: 
  - title: "Time Block Largo"
  - description: "Descripción válida"
  - startTime: DateTime.now()
  - endTime: DateTime.now().add(Duration(hours: 12))
  - category: "Work"
  - color: "#7AA2F7"
- **Resultado Esperado**: Advertencia - "Duración muy larga para un time block"

---

## CASOS DE PRUEBA COMUNES

### **Validaciones Generales**

#### **CP-G-001: Conexión de Base de Datos**
- **Escenario**: Sin conexión a la base de datos
- **Resultado Esperado**: Error - "Error de conexión a la base de datos"

#### **CP-G-002: Memoria Insuficiente**
- **Escenario**: Sistema con memoria limitada
- **Resultado Esperado**: Error - "Memoria insuficiente"

#### **CP-G-003: Permisos Insuficientes**
- **Escenario**: Sin permisos de escritura
- **Resultado Esperado**: Error - "Permisos insuficientes"

#### **CP-G-004: Datos Corruptos**
- **Escenario**: Base de datos corrupta
- **Resultado Esperado**: Error - "Datos corruptos detectados"

---

## MATRIZ DE COBERTURA

| Caso de Prueba | Entrada Válida | Entrada Inválida | Casos Límite | Manejo de Errores |
|----------------|----------------|------------------|--------------|-------------------|
| **Crear Hábito** | SI | SI | SI | SI |
| **Crear Actividad** | SI | SI | SI | SI |
| **Crear Time Block** | SI | SI | SI | SI |

### **Cobertura de Validaciones**
- SI Campos requeridos
- SI Formatos de datos
- SI Rangos de valores
- SI Duplicados
- SI Casos límite
- SI Manejo de errores
- SI Integridad de datos

---

## CRITERIOS DE ACEPTACIÓN

### **Criterios de Éxito**
1. **Funcionalidad**: Todos los métodos crean entidades correctamente
2. **Validación**: Errores apropiados para entradas inválidas
3. **Integridad**: Datos consistentes y válidos
4. **Rendimiento**: Respuesta en tiempo razonable (< 2 segundos)
5. **Robustez**: Manejo adecuado de errores y excepciones

### **Criterios de Fallo**
1. **Datos Inconsistentes**: Entidades con datos inválidos
2. **Errores No Manejados**: Excepciones no capturadas
3. **Rendimiento**: Tiempo de respuesta > 5 segundos
4. **Memoria**: Fugas de memoria detectadas
5. **Concurrencia**: Problemas con acceso simultáneo

---

## CONCLUSIÓN

Las pruebas de caja negra presentadas cubren los aspectos críticos de los métodos de creación en TempoSageMovil, asegurando:

- **Validación exhaustiva** de entradas
- **Manejo robusto** de errores
- **Integridad** de los datos
- **Comportamiento predecible** del sistema

Estas pruebas garantizan que los métodos de creación funcionen correctamente bajo diversas condiciones y proporcionen una base sólida para la validación del sistema.

---

**Documento generado**: $(date)  
**Versión**: 1.0  
**Autor**: Sistema de Análisis TempoSageMovil
