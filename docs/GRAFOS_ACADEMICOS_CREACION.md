# GRAFOS ACADÉMICOS - MÉTODOS DE CREACIÓN
## TempoSageMovil - Sistema de Gestión de Productividad

---

## ÍNDICE

1. [Introducción](#introducción)
2. [Grafos de Creación](#grafos-de-creación)
   - [Crear Actividad](#crear-actividad)
   - [Crear Hábito](#crear-hábito)
   - [Crear Time Block](#crear-time-block)
3. [Casos de Prueba Derivados](#casos-de-prueba-derivados)
4. [Matriz de Cobertura](#matriz-de-cobertura)
5. [Criterios de Aceptación](#criterios-de-aceptación)

---

## INTRODUCCIÓN

Este documento presenta los **grafos académicos** que representan los flujos de creación de las entidades principales en TempoSageMovil. Estos grafos han sido generados a partir del análisis de las pruebas de caja negra existentes y representan los caminos de ejecución para los métodos de creación.

### Objetivos de los Grafos
- Visualizar los flujos de creación de entidades
- Identificar puntos de validación y decisión
- Mapear casos de éxito y error
- Establecer cobertura completa de pruebas

---

## GRAFOS DE CREACIÓN

### CREAR ACTIVIDAD

El grafo académico para la creación de actividades muestra el siguiente flujo:

#### **Nodos Principales:**
1. **Inicio** - Punto de entrada del método `addActivity`
2. **Validar Título** - Verificación de título no vacío
3. **Validar Fechas** - Verificación de fechas válidas
4. **Validar Duración** - Verificación de duración positiva
5. **Generar ID** - Creación de identificador único
6. **Crear Entidad** - Instanciación del ActivityModel
7. **Persistir Datos** - Guardado en base de datos
8. **Programar Notificación** - Configuración de recordatorios
9. **Actualizar Estado** - Actualización del estado de la aplicación
10. **Fin Exitoso** - Retorno exitoso
11. **Fin con Error** - Retorno con excepción

#### **Arcos de Decisión:**
- **Título Válido?** → Sí: Continuar / No: Error
- **Fechas Válidas?** → Sí: Continuar / No: Error
- **Duración Positiva?** → Sí: Continuar / No: Error
- **Recordatorio Activo?** → Sí: Programar / No: Omitir

#### **Casos de Prueba Identificados:**
- **CP-A-001**: Creación exitosa con todos los parámetros
- **CP-A-002**: Error por título vacío
- **CP-A-003**: Error por fecha de fin anterior a inicio
- **CP-A-004**: Error por fecha en el pasado
- **CP-A-005**: Creación sin recordatorio
- **CP-A-006**: Creación con recordatorio personalizado

### CREAR HÁBITO

El grafo académico para la creación de hábitos presenta el siguiente flujo:

#### **Nodos Principales:**
1. **Inicio** - Punto de entrada del método `createHabit`
2. **Validar Nombre** - Verificación de nombre no vacío
3. **Validar Descripción** - Verificación de descripción válida
4. **Validar Días** - Verificación de días de la semana
5. **Validar Categoría** - Verificación de categoría válida
6. **Validar Hora** - Verificación de formato de hora
7. **Generar ID** - Creación de identificador único
8. **Crear Entidad** - Instanciación del HabitModel
9. **Persistir Datos** - Guardado en base de datos
10. **Configurar Recordatorio** - Configuración de notificaciones
11. **Actualizar Estado** - Actualización del estado de la aplicación
12. **Fin Exitoso** - Retorno exitoso
13. **Fin con Error** - Retorno con excepción

#### **Arcos de Decisión:**
- **Nombre Válido?** → Sí: Continuar / No: Error
- **Descripción Válida?** → Sí: Continuar / No: Error
- **Días Válidos?** → Sí: Continuar / No: Error
- **Categoría Válida?** → Sí: Continuar / No: Error
- **Hora Válida?** → Sí: Continuar / No: Error
- **Recordatorio Activo?** → Sí: Configurar / No: Omitir

#### **Casos de Prueba Identificados:**
- **CP-H-001**: Creación exitosa con todos los parámetros
- **CP-H-002**: Error por nombre vacío
- **CP-H-003**: Error por descripción vacía
- **CP-H-004**: Error por días de semana inválidos
- **CP-H-005**: Error por categoría inválida
- **CP-H-006**: Error por formato de hora inválido
- **CP-H-007**: Error por nombre muy largo
- **CP-H-008**: Creación con recordatorio desactivado

### CREAR TIME BLOCK

El grafo académico para la creación de time blocks muestra el siguiente flujo:

#### **Nodos Principales:**
1. **Inicio** - Punto de entrada del método `addTimeBlock`
2. **Validar Título** - Verificación de título no vacío
3. **Validar Fechas** - Verificación de fechas válidas
4. **Validar Duración** - Verificación de duración positiva
5. **Validar Color** - Verificación de formato hexadecimal
6. **Validar Categoría** - Verificación de categoría válida
7. **Verificar Duplicados** - Verificación de bloques duplicados
8. **Generar ID** - Creación de identificador único
9. **Crear Entidad** - Instanciación del TimeBlockModel
10. **Persistir Datos** - Guardado en base de datos
11. **Actualizar Estado** - Actualización del estado de la aplicación
12. **Fin Exitoso** - Retorno exitoso
13. **Fin con Error** - Retorno con excepción

#### **Arcos de Decisión:**
- **Título Válido?** → Sí: Continuar / No: Error
- **Fechas Válidas?** → Sí: Continuar / No: Error
- **Duración Positiva?** → Sí: Continuar / No: Error
- **Color Válido?** → Sí: Continuar / No: Error
- **Categoría Válida?** → Sí: Continuar / No: Error
- **Es Duplicado?** → Sí: Error / No: Continuar

#### **Casos de Prueba Identificados:**
- **CP-TB-001**: Creación exitosa con todos los parámetros
- **CP-TB-002**: Error por título vacío
- **CP-TB-003**: Error por fecha de fin anterior a inicio
- **CP-TB-004**: Error por color inválido
- **CP-TB-005**: Error por categoría inválida
- **CP-TB-006**: Error por bloque duplicado
- **CP-TB-007**: Creación con tiempo de enfoque activado
- **CP-TB-008**: Creación con tiempo de enfoque desactivado

---

## CASOS DE PRUEBA DERIVADOS

### **Casos de Prueba de Caja Negra**

Basándose en los grafos académicos, se han identificado los siguientes casos de prueba:

#### **Crear Actividad - Casos de Prueba**

| ID | Descripción | Entrada | Resultado Esperado |
|----|-------------|---------|-------------------|
| CP-A-001 | Creación exitosa | Datos válidos completos | Actividad creada exitosamente |
| CP-A-002 | Título vacío | title: "" | Error: "El título no puede estar vacío" |
| CP-A-003 | Fecha fin anterior | endTime < startTime | Error: "La hora de fin debe ser posterior a la hora de inicio" |
| CP-A-004 | Fecha en el pasado | startTime < DateTime.now() | Error: "No se pueden crear actividades en el pasado" |
| CP-A-005 | Sin recordatorio | sendReminder: false | Actividad creada sin notificación |
| CP-A-006 | Recordatorio personalizado | reminderMinutesBefore: 30 | Notificación programada para 30 min antes |

#### **Crear Hábito - Casos de Prueba**

| ID | Descripción | Entrada | Resultado Esperado |
|----|-------------|---------|-------------------|
| CP-H-001 | Creación exitosa | Datos válidos completos | Hábito creado exitosamente |
| CP-H-002 | Nombre vacío | name: "" | Error: "El nombre no puede estar vacío" |
| CP-H-003 | Descripción vacía | description: "" | Error: "La descripción no puede estar vacía" |
| CP-H-004 | Días inválidos | daysOfWeek: [] | Error: "Debe seleccionar al menos un día" |
| CP-H-005 | Categoría inválida | category: "" | Error: "La categoría no puede estar vacía" |
| CP-H-006 | Hora inválida | time: "25:00" | Error: "Formato de hora inválido" |
| CP-H-007 | Nombre muy largo | name: "A" * 256 | Error: "Nombre demasiado largo" |
| CP-H-008 | Sin recordatorio | reminder: "No" | Hábito creado sin notificación |

#### **Crear Time Block - Casos de Prueba**

| ID | Descripción | Entrada | Resultado Esperado |
|----|-------------|---------|-------------------|
| CP-TB-001 | Creación exitosa | Datos válidos completos | Time Block creado exitosamente |
| CP-TB-002 | Título vacío | title: "" | Error: "El título no puede estar vacío" |
| CP-TB-003 | Fecha fin anterior | endTime < startTime | Error: "La hora de finalización debe ser posterior a la hora de inicio" |
| CP-TB-004 | Color inválido | color: "rojo" | Error: "El color debe estar en formato hexadecimal (#RRGGBB)" |
| CP-TB-005 | Categoría inválida | category: "" | Error: "La categoría no puede estar vacía" |
| CP-TB-006 | Bloque duplicado | Mismos datos que bloque existente | Error: "Ya existe un bloque de tiempo similar" |
| CP-TB-007 | Con tiempo de enfoque | isFocusTime: true | Time Block creado con enfoque activado |
| CP-TB-008 | Sin tiempo de enfoque | isFocusTime: false | Time Block creado sin enfoque |

---

## MATRIZ DE COBERTURA

### **Cobertura de Nodos**

| Método | Nodos Totales | Nodos Cubiertos | Cobertura |
|--------|---------------|-----------------|-----------|
| Crear Actividad | 11 | 11 | 100% |
| Crear Hábito | 13 | 13 | 100% |
| Crear Time Block | 13 | 13 | 100% |

### **Cobertura de Arcos**

| Método | Arcos Totales | Arcos Cubiertos | Cobertura |
|--------|---------------|-----------------|-----------|
| Crear Actividad | 8 | 8 | 100% |
| Crear Hábito | 10 | 10 | 100% |
| Crear Time Block | 10 | 10 | 100% |

### **Cobertura de Caminos**

| Método | Caminos Totales | Caminos Cubiertos | Cobertura |
|--------|-----------------|-------------------|-----------|
| Crear Actividad | 6 | 6 | 100% |
| Crear Hábito | 8 | 8 | 100% |
| Crear Time Block | 8 | 8 | 100% |

---

## CRITERIOS DE ACEPTACIÓN

### **Criterios de Éxito**

1. **Cobertura Completa**: Todos los nodos, arcos y caminos están cubiertos por pruebas
2. **Validación Exhaustiva**: Todos los puntos de validación están probados
3. **Manejo de Errores**: Todos los casos de error están manejados apropiadamente
4. **Integridad de Datos**: Los datos se persisten correctamente
5. **Rendimiento**: Los métodos responden en tiempo razonable (< 2 segundos)

### **Criterios de Fallo**

1. **Cobertura Incompleta**: Nodos, arcos o caminos sin probar
2. **Validaciones Faltantes**: Puntos de validación no cubiertos
3. **Errores No Manejados**: Excepciones no capturadas
4. **Datos Inconsistentes**: Entidades con datos inválidos
5. **Rendimiento Deficiente**: Tiempo de respuesta > 5 segundos

---

## CONCLUSIÓN

Los grafos académicos presentados proporcionan una representación visual completa de los flujos de creación en TempoSageMovil. Estos grafos han sido utilizados para:

- **Identificar** todos los puntos de decisión y validación
- **Mapear** los caminos de ejecución posibles
- **Generar** casos de prueba exhaustivos
- **Asegurar** cobertura completa de código

La implementación de estas pruebas garantiza que los métodos de creación funcionen correctamente bajo todas las condiciones posibles y proporcionen una base sólida para la validación del sistema.

---

**Documento generado**: $(date)  
**Versión**: 1.0  
**Autor**: Sistema de Análisis TempoSageMovil  
**Basado en**: Grafos académicos y pruebas de caja negra existentes
