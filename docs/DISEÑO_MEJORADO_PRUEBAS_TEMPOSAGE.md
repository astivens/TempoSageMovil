# DISEÑO MEJORADO DE PRUEBAS - TEMPOSAGE

## 1. INTRODUCCIÓN

Este documento presenta el diseño mejorado de pruebas para la aplicación TempoSage, siguiendo la metodología sistemática de testing descrita en el documento de referencia. El objetivo es garantizar la calidad, confiabilidad y cumplimiento de los requisitos del software mediante una estrategia integral de pruebas.

## 2. PLANIFICACIÓN DE LAS PRUEBAS

### 2.1 Objetivos de las Pruebas

#### Objetivo General:
Garantizar la excelencia y fiabilidad del software TempoSage mediante una estrategia integral de pruebas.

#### Objetivos Específicos:
- Identificar y corregir defectos y errores en el software
- Validar que el software cumple con los requisitos funcionales y no funcionales definidos
- Garantizar que el software funcione de manera adecuada y eficiente
- Evaluar la seguridad, usabilidad y rendimiento del software
- Verificar la integración correcta entre módulos del sistema

### 2.2 Módulos del Sistema a Probar

| **Módulo** | **Objetivos de las Pruebas** |
| :-: | :-: |
| **Autenticación** | Validar que los datos ingresados por el usuario sean correctos para el acceso |
| **Gestión de Actividades** | Verificar creación, modificación, eliminación y consulta de actividades |
| **Gestión de Hábitos** | Validar seguimiento y análisis de progreso de hábitos |
| **Time Blocks** | Verificar creación y gestión de bloques de tiempo productivo |
| **Sistema de Recomendaciones** | Validar generación de sugerencias inteligentes |
| **Dashboard** | Verificar visualización correcta de métricas y estadísticas |
| **Importación/Exportación** | Validar manejo correcto de archivos CSV |

### 2.3 Ambiente de Pruebas

#### Configuración Hardware:
- **Dispositivo Principal**: Acer Nitro 5 - Intel Core i5, 8GB RAM, Windows 11 PRO
- **Dispositivo Secundario**: Computadora de escritorio - AMD Ryzen 5 5600G, 16GB RAM, Windows 11 Pro

#### Software:
- **IDE**: Visual Studio Code / Android Studio
- **Framework**: Flutter 3.2.3+
- **Testing**: flutter_test, integration_test
- **Base de Datos**: Hive (Local Storage)

## 3. PRUEBAS UNITARIAS

### 3.1 Análisis de Pruebas por Módulo

#### 3.1.1 Módulo de Autenticación

**Clases de Equivalencia:**

| **CONDICIÓN DE ENTRADA** | **CLASE VÁLIDA** | **CLASE INVÁLIDA** |
| :-: | :-: | :-: |
| **Email** (formato válido, entre 5 y 100 caracteres) | 5 ≤ caracteres ≤ 100, formato email válido | caracteres < 5, caracteres > 100, formato inválido, null |
| **Nombre** (entre 2 y 50 caracteres, solo letras) | 2 ≤ caracteres ≤ 50, solo letras | caracteres < 2, caracteres > 50, números, caracteres especiales, null |
| **Contraseña** (entre 8 y 50 caracteres) | 8 ≤ caracteres ≤ 50 | caracteres < 8, caracteres > 50, null |

**Casos de Prueba:**

| **DATO DE ENTRADA** | **VALOR** | **ESCENARIO** |
| :-: | :-: | :-: |
| **Email** | test@example.com, usuario@gmail.com | **CORRECTO** |
| **Email** | test@, a@b.c, usuario123456789...@gmail.com | **INCORRECTO** |
| **Nombre** | Juan Pérez, María González | **CORRECTO** |
| **Nombre** | J, Juan123, Juan@Pérez, Juan Pérez García de la Cruz y Martínez | **INCORRECTO** |
| **Contraseña** | password123, MiContraseña123! | **CORRECTO** |
| **Contraseña** | pass, Contraseña123456789... | **INCORRECTO** |

**Valores Límite:**

| **CONDICIÓN DE ENTRADA** | **DESCRIPCIÓN DE LOS CASOS** |
| :-: | :-: |
| **Email** (entre 5 y 100 caracteres) | a@b.c, usuario@dominio.com, usuario123456789...@dominio.com |
| **Nombre** (entre 2 y 50 caracteres) | Jo, Juan Pérez, Juan Pérez García de la Cruz y Martínez |
| **Contraseña** (entre 8 y 50 caracteres) | password, MiContraseña123!, Contraseña123456789... |

#### 3.1.2 Módulo de Actividades

**Clases de Equivalencia:**

| **CONDICIÓN DE ENTRADA** | **CLASE VÁLIDA** | **CLASE INVÁLIDA** |
| :-: | :-: | :-: |
| **Título** (entre 1 y 100 caracteres) | 1 ≤ caracteres ≤ 100 | caracteres < 1, caracteres > 100, null |
| **Descripción** (entre 0 y 500 caracteres) | 0 ≤ caracteres ≤ 500 | caracteres > 500 |
| **Fecha** (formato fecha válido) | Formato dd/mm/yyyy | Formato inválido, fecha pasada para eventos futuros |
| **Prioridad** (valores 1-5) | 1 ≤ valor ≤ 5 | valor < 1, valor > 5, null |
| **Categoría** (valores predefinidos) | Valores válidos del enum | Valores no definidos, null |

#### 3.1.3 Módulo de Hábitos

**Clases de Equivalencia:**

| **CONDICIÓN DE ENTRADA** | **CLASE VÁLIDA** | **CLASE INVÁLIDA** |
| :-: | :-: | :-: |
| **Nombre** (entre 1 y 50 caracteres) | 1 ≤ caracteres ≤ 50 | caracteres < 1, caracteres > 50, null |
| **Frecuencia** (valores válidos) | daily, weekly, monthly | Valores no válidos, null |
| **Meta** (entre 1 y 365) | 1 ≤ valor ≤ 365 | valor < 1, valor > 365, null |

#### 3.1.4 Módulo de Time Blocks

**Clases de Equivalencia:**

| **CONDICIÓN DE ENTRADA** | **CLASE VÁLIDA** | **CLASE INVÁLIDA** |
| :-: | :-: | :-: |
| **Hora Inicio** (formato HH:mm) | Formato válido, hora entre 00:00-23:59 | Formato inválido, hora fuera de rango |
| **Hora Fin** (formato HH:mm) | Formato válido, hora > hora inicio | Formato inválido, hora ≤ hora inicio |
| **Duración** (entre 15 y 480 minutos) | 15 ≤ minutos ≤ 480 | minutos < 15, minutos > 480 |
| **Tipo** (valores predefinidos) | work, study, exercise, rest | Valores no válidos, null |

### 3.2 Pruebas del Camino Básico

**Fórmula de Complejidad Ciclomática:**
- V(g) = nodos - vértices + 2
- V(g) = número de regiones cerradas + 1
- V(g) = número de nodos de condición + 1

**Ejemplo - Función de Autenticación:**
```
V(g) = 6 - 6 + 2 = 2
V(g) = 1 + 1 = 2
V(g) = 1 + 1 = 2

Caminos:
- Camino 1: 1-2-4-6 (credenciales válidas)
- Camino 2: 1-2-3-5-6 (credenciales inválidas)
```

## 4. PRUEBAS DE INTEGRACIÓN

### 4.1 Estrategias de Integración

#### 4.1.1 Integración Ascendente (Bottom-Up)
**Orden de Pruebas:**
1. Pruebas Unitarias: F, G, H
2. Integración: (C-F), (D-G), (E-H), (B-C), (B-D), (B-E), (A-B)

#### 4.1.2 Integración Descendente (Top-Down)
**Profundidad:**
- (A-B), (B-C), (C-F)
- (A-B), (B-D), (D-G)
- (A-B), (B-E), (E-H)

**Anchura:**
- (A-B)
- (B-C), (B-D), (B-E)
- (C-F), (D-G), (E-H)

### 4.2 Pruebas Basadas en Hilos

| **Elemento** | **Estado** |
| :-: | :-: |
| **Interfaz de Usuario** | Activa, inactiva, en carga |
| **Base de Datos Local** | Disponible, con problemas, llena |
| **Servicios de IA** | Disponible, no disponible, error |
| **Sistema de Notificaciones** | Habilitado, deshabilitado, error |

### 4.3 Casos de Prueba de Integración

| **Número** | **Componente** | **Descripción** | **Prerrequisito** |
| :- | :- | :- | :- |
| **1** | Autenticación + Base de Datos | Verificar que el login persista la sesión | Usuario registrado en BD |
| **2** | Actividades + Notificaciones | Verificar que se generen recordatorios | Actividad con fecha futura |
| **3** | Hábitos + Análisis | Verificar cálculo de progreso | Hábito con seguimiento |
| **4** | Time Blocks + Recomendaciones | Verificar sugerencias basadas en bloques | Historial de bloques |

## 5. PRUEBAS DE SISTEMA

### 5.1 Pruebas de Funcionalidad

**Objetivo:** Verificar que todas las funcionalidades del sistema operen correctamente según los requisitos.

**Casos de Prueba:**

| **Funcionalidad** | **Caso de Prueba** | **Resultado Esperado** |
| :- | :- | :- |
| **Registro de Usuario** | Crear cuenta con datos válidos | Usuario creado exitosamente |
| **Inicio de Sesión** | Autenticarse con credenciales válidas | Acceso al dashboard |
| **Creación de Actividad** | Agregar nueva actividad | Actividad visible en lista |
| **Seguimiento de Hábito** | Marcar hábito como completado | Progreso actualizado |

### 5.2 Pruebas de Rendimiento

| **Métrica** | **Objetivo** | **Herramienta** |
| :- | :- | :- |
| **Tiempo de Carga** | < 2 segundos | Flutter Performance |
| **Uso de Memoria** | < 100MB | DevTools |
| **Fluidez de UI** | > 60 FPS | Flutter Inspector |
| **Tiempo de Respuesta** | < 500ms | Custom Timer |

### 5.3 Pruebas de Seguridad

| **Aspecto** | **Prueba** | **Resultado Esperado** |
| :- | :- | :- |
| **Almacenamiento** | Verificar encriptación de datos | Datos no legibles en texto plano |
| **Autenticación** | Intentar acceso sin credenciales | Acceso denegado |
| **Validación de Entrada** | Enviar datos maliciosos | Datos rechazados/sanitizados |

### 5.4 Pruebas de Usabilidad

| **Criterio** | **Prueba** | **Métrica** |
| :- | :- | :- |
| **Facilidad de Uso** | Tiempo para completar tarea principal | < 3 pasos |
| **Navegación** | Acceso a funciones principales | < 2 taps |
| **Comprensión** | Claridad de mensajes y errores | 100% comprensión |

## 6. PRUEBAS DE ACEPTACIÓN

### 6.1 Pruebas de Usabilidad

**Metodología:** Moderated Usability Testing

**Objetivo:** Evaluar la experiencia del usuario final con la aplicación.

**Escenarios de Prueba:**

| **Escenario** | **Tarea** | **Criterio de Éxito** |
| :- | :- | :- |
| **Onboarding** | Registrarse y configurar perfil inicial | Completado en < 5 minutos |
| **Gestión Diaria** | Crear actividad y bloque de tiempo | Completado en < 2 minutos |
| **Seguimiento** | Revisar progreso de hábitos | Información clara y accesible |
| **Análisis** | Generar reporte de productividad | Datos comprensibles |

### 6.2 Criterios de Aceptación

1. **Funcionalidad Completa:** Todas las características implementadas funcionan según especificación
2. **Rendimiento Aceptable:** Aplicación responde en tiempos esperados
3. **Usabilidad Satisfactoria:** Usuarios pueden completar tareas sin dificultad
4. **Estabilidad:** Aplicación no presenta crashes durante uso normal
5. **Compatibilidad:** Funciona en dispositivos objetivo especificados

## 7. MÉTRICAS DE PRUEBAS

### 7.1 Cobertura de Código

| **Tipo** | **Objetivo** | **Métrica Actual** |
| :- | :- | :- |
| **Líneas de Código** | > 80% | Por medir |
| **Ramas** | > 70% | Por medir |
| **Funciones** | > 90% | Por medir |

### 7.2 Métricas de Calidad

| **Métrica** | **Objetivo** | **Herramienta** |
| :- | :- | :- |
| **Densidad de Defectos** | < 1 defecto/KLOC | Manual |
| **Tiempo de Detección** | < 24 horas | Tracking |
| **Tasa de Éxito** | > 95% | Automated Tests |

## 8. PLAN DE EJECUCIÓN

### 8.1 Cronograma de Pruebas

| **Fase** | **Duración** | **Responsable** |
| :- | :- | :- |
| **Preparación** | 1 semana | Equipo de Desarrollo |
| **Pruebas Unitarias** | 2 semanas | Desarrolladores |
| **Pruebas de Integración** | 1 semana | QA Team |
| **Pruebas de Sistema** | 1 semana | QA Team |
| **Pruebas de Aceptación** | 1 semana | Stakeholders |

### 8.2 Criterios de Salida

- Todas las pruebas críticas pasan exitosamente
- Cobertura de código alcanza objetivos definidos
- Pruebas de aceptación completadas con éxito
- Documentación de pruebas actualizada
- Reportes de defectos cerrados

## 9. DISEÑO DETALLADO DE CASOS DE PRUEBA

### 9.1 Casos de Prueba Unitarias - ProductiveBlock

| Número del caso de prueba | Componente | Descripción de lo que se probará | Prerrequisito |
| :-: | :-: | :-: | :-: |
| 1 | Creación de ProductiveBlock | El sistema debe crear un bloque productivo válido | Datos válidos proporcionados |
| 2 | Validación de hora inicio | El sistema debe validar formato de hora de inicio | Hora en formato HH:mm |
| 3 | Validación de duración | El sistema debe validar duración entre 15-480 minutos | Duración en minutos |
| 4 | Filtrado por categoría | El sistema debe filtrar bloques por categoría específica | Bloques con categorías definidas |

#### Caso de Prueba 1: Creación de ProductiveBlock

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear ProductiveBlock con datos válidos | weekday: 1, hour: 9, duration: 60, category: "work" | ProductiveBlock creado exitosamente | Verificar creación correcta del objeto |
| 2 | Verificar propiedades del objeto | - | Todas las propiedades asignadas correctamente | Validar que los datos se almacenen correctamente |
| 3 | Verificar método toString | - | String con formato: "Martes 09:00 - 10:00 (work)" | Comprobar representación textual |

#### Caso de Prueba 2: Validación de Hora Inicio

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear bloque con hora válida | hour: 9 | ProductiveBlock creado | Hora dentro del rango válido |
| 2 | Crear bloque con hora límite inferior | hour: 0 | ProductiveBlock creado | Hora mínima válida |
| 3 | Crear bloque con hora límite superior | hour: 23 | ProductiveBlock creado | Hora máxima válida |

#### Caso de Prueba 3: Validación de Duración

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear bloque con duración mínima | duration: 15 | ProductiveBlock creado | Duración mínima válida |
| 2 | Crear bloque con duración máxima | duration: 480 | ProductiveBlock creado | Duración máxima válida |
| 3 | Crear bloque con duración típica | duration: 60 | ProductiveBlock creado | Duración estándar |

### 9.2 Casos de Prueba de Integración

| Número del caso de prueba | Componente | Descripción de lo que se probará | Prerrequisito |
| :-: | :-: | :-: | :-: | :-: |
| 1 | ProductiveBlock + CSV Export | El sistema debe exportar bloques a formato CSV | Bloques creados en memoria |
| 2 | Bottom-Up Integration | El sistema debe integrar componentes de abajo hacia arriba | Componentes individuales probados |
| 3 | Thread-Based Integration | El sistema debe manejar operaciones concurrentes | Múltiples operaciones simultáneas |

#### Caso de Prueba 1: ProductiveBlock + CSV Export

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear lista de ProductiveBlocks | 3 bloques con datos diferentes | Lista de bloques en memoria | Verificar creación de datos de prueba |
| 2 | Convertir a formato CSV | Lista de ProductiveBlocks | String CSV con headers y datos | Validar formato correcto del CSV |
| 3 | Verificar contenido del CSV | - | CSV contiene: weekday,hour,duration,category,completion_rate | Comprobar headers y datos exportados |

### 9.3 Casos de Prueba de Sistema

| Número del caso de prueba | Componente | Descripción de lo que se probará | Prerrequisito |
| :-: | :-: | :-: | :-: |
| 1 | Funcionalidad de ProductiveBlock | El sistema debe manejar operaciones completas de bloques | Sistema inicializado |
| 2 | Rendimiento con datasets grandes | El sistema debe procesar eficientemente grandes volúmenes | Dataset de 1000+ elementos |
| 3 | Usabilidad del sistema | El sistema debe responder rápidamente a las acciones | Sistema en funcionamiento normal |

#### Caso de Prueba 1: Funcionalidad de ProductiveBlock

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear múltiples bloques productivos | 5 bloques con diferentes categorías | Todos los bloques creados exitosamente | Verificar creación masiva |
| 2 | Filtrar por categoría específica | Filtro por categoría "work" | Solo bloques de trabajo retornados | Validar filtrado correcto |
| 3 | Exportar datos a CSV | Lista de bloques filtrados | CSV generado con datos correctos | Comprobar exportación exitosa |

#### Caso de Prueba 2: Rendimiento con Datasets Grandes

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear dataset grande | 1000 bloques productivos | Todos los bloques creados | Medir tiempo de creación |
| 2 | Procesar dataset completo | 1000 bloques | Procesamiento completado en < 500ms | Verificar rendimiento |
| 3 | Filtrar dataset grande | Filtro por categoría | Filtrado completado rápidamente | Validar eficiencia del filtrado |

### 9.4 Casos de Prueba de Aceptación

| Número del caso de prueba | Componente | Descripción de lo que se probará | Prerrequisito |
| :-: | :-: | :-: | :-: |
| 1 | Seguimiento de Progreso | El usuario debe poder revisar y analizar su productividad | Historial de bloques disponible |
| 2 | Consistencia de Datos | Los datos deben mantenerse consistentes durante las operaciones | Sistema funcionando correctamente |

#### Caso de Prueba 1: Seguimiento de Progreso

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Generar historial de bloques | 150 bloques históricos (30 días) | Historial generado exitosamente | Simular 30 días de datos |
| 2 | Filtrar por categorías | Filtros por "work" y "study" | Bloques filtrados correctamente | Validar análisis por categoría |
| 3 | Calcular métricas de rendimiento | Bloques filtrados | Métricas calculadas (promedios, top performers) | Verificar cálculos estadísticos |
| 4 | Exportar análisis a CSV | Métricas calculadas | CSV con análisis de productividad | Comprobar exportación de análisis |

#### Caso de Prueba 2: Consistencia de Datos

| Paso | Descripción de paso a seguir | Datos entrada | Salida Esperada | Observación |
| :-: | :-: | :-: | :-: | :-: |
| 1 | Crear bloques originales | 3 bloques con datos específicos | Bloques creados con datos exactos | Verificar datos iniciales |
| 2 | Ordenar bloques por hora | Lista de bloques | Bloques ordenados cronológicamente | Validar ordenamiento |
| 3 | Filtrar por categorías | Ordenamiento por "work" y "study" | Bloques agrupados correctamente | Verificar agrupación |
| 4 | Verificar suma de completion rates | Bloques filtrados | Suma total igual a la original | Validar integridad de datos |

## 10. CONCLUSIONES

Este diseño de pruebas mejorado proporciona una estrategia integral para garantizar la calidad del software TempoSage. La implementación de estas pruebas seguirá las mejores prácticas de testing y asegurará que la aplicación cumpla con todos los requisitos funcionales y no funcionales establecidos.

La metodología propuesta incluye:
- Análisis sistemático de clases de equivalencia y valores límite
- Pruebas de integración estructuradas
- Evaluación completa de rendimiento, seguridad y usabilidad
- Validación de aceptación por parte de usuarios finales
- Diseño detallado de casos de prueba con pasos específicos

La ejecución de este plan de pruebas resultará en una aplicación robusta, confiable y que cumple con las expectativas de calidad del proyecto.
