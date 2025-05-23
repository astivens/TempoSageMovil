# Guía de Uso Híbrido para el Modelo TFLite en TempoSageMovil

Esta guía explica cómo se plantea **usar el modelo multitarea (`.tflite`) de forma híbrida** (combinar Machine Learning on-device con reglas basadas en estadísticas y calendario) dentro de la aplicación TempoSageMovil. Aunque ya se tiene el modelo entrenado, aquí se detalla el flujo, las entradas y salidas, las reglas de negocio y cómo interactúan para ofrecer recomendaciones de programación de tareas inteligentes.

---

## 1. Objetivos del Enfoque Híbrido

1. **Clasificar la categoría de la tarea** a partir de su descripción, de modo que la app entienda rápidamente si es “Trabajo”, “Personal”, “Estudio”, “Formación”, “Ejercicio”, etc.  
2. **Predecir la duración real** de la tarea (en minutos), usando descripción y características contextuales.  
3. **Sugerir el bloque horario óptimo** para programar la tarea, combinando:
   - Predicción de categoría y duración (Machine Learning on-device).  
   - Estadísticas de productividad histórica por día y hora (calculadas offline en Colab).  
   - Disponibilidad real del usuario (consultada en su calendario local).  
   - Características dinámicas del usuario (prioridad, nivel de energía, estado de ánimo).

El resultado es una **recomendación integrada**: “Esta tarea es de categoría X, tardará aproximadamente Y minutos, y el mejor momento para hacerla es el día D a la hora H, según tu historial y tu calendario actual”.

---

## 2. Estructura General del Flujo de Trabajo

1. **Entrada de datos**  
   - El usuario ingresa la descripción textual de la nueva tarea y provee (o sugiere) una duración estimada.  
   - La app obtiene automáticamente la fecha/hora actual, el día de la semana y, si existe, una categoría manual previa u otra información de contexto (prioridad, energía, estado de ánimo).

2. **Inferencia On-Device con TFLite**  
   - El modelo recibe como entradas:
     1. **Descripción de la tarea** (cadena).  
     2. **Duración estimada** (float).  
     3. **Hora actual** (float).  
     4. **Día de la semana actual** (float).  
     5. **Vector One-Hot de categorías manuales** (por si la tarea ya estaba previamente categorizada o para proporcionar contexto adicional).  
   - Produce dos salidas:
     1. **`category_out`**: vector de logits—la categoría predicha.  
     2. **`duration_out`**: valor float que estima la duración real en minutos.

3. **Cálculos y Lectura de Estadísticas**  
   - La app lee un CSV (previamente generado en Colab) llamado `top3_productive_blocks.csv` que contiene las 3 tuplas `(weekday, hour, completion_rate)` con mayor tasa de tareas completadas.  
   - Opcionalmente, se puede leer un CSV completo llamado `productive_blocks_stats.csv` si se requiere un análisis más fino.

4. **Reglas Basadas en Calendario y Contexto**  
   - Se consulta el calendario local del usuario (mediante el plugin `device_calendar`) para saber qué horas ya están ocupadas en el bloque referido.  
   - Se aplica una serie de reglas híbridas que pueden incluir:
     - **Prioridad alta**: si la tarea es urgente, se sugiere el primer bloque disponible dentro del Top 3, ignorando otras restricciones menores.  
     - **Nivel de energía bajo**: si el usuario reporta energía baja (< 0.3), se eligen solo bloques con `completion_rate ≥ 0.8`.  
     - **Estado de ánimo**: si la tarea es de “Formación” y el estado de ánimo es bajo (< 0.4), se omite el bloque peor valorado.  
     - **Evitar bloques postergados**: si en un bloque habitual las tareas se postergan frecuentemente, se salta a la siguiente opción viable.

5. **Salida de Recomendación**  
   - La app muestra al usuario:
     1. **Categoría predicha** (p. ej. “Estudio”).  
     2. **Duración estimada real** (p. ej. 45 min).  
     3. **Bloque horario sugerido** (p. ej. “Martes a las 10:00”).  
   - El usuario puede aceptar la sugerencia, editarla manualmente o volver a intentar con distinta configuración.

---

## 3. Detalle de Entradas y Salidas del Modelo

### 3.1. Entradas

1. **`task_description` (String)**  
   - Texto libre ingresado por el usuario.  
   - Se normaliza a minúsculas y espacios recortados antes de alimentar la capa `TextVectorization`.  

2. **`estimated_duration_minutes` (Float)**  
   - La duración que el usuario cree que tomará la tarea (en minutos).  
   - Se envía tal cual al modelo como característica numérica.

3. **`start_hour` (Float)**  
   - Hora del día en que se ingresa la tarea (0–23).  
   - Adicionalmente, el modelo puede aprender patrones de productividad según la hora de ingreso.

4. **`start_weekday` (Float)**  
   - Día de la semana en que se ingresa la tarea (0 = lunes … 6 = domingo).  

5. **Vector One-Hot de Categorías Manuales (`List<Float>`)**  
   - Longitud = número de categorías manuales definidas.  
   - Representa información contextual si la tarea ya existía con una categoría asignada (opcional).  
   - Si es tarea nueva sin categoría manual previa, suele pasarse un vector de ceros.  

### 3.2. Salidas

1. **`category_out` (Float [num_classes])**  
   - Vector de logits (o probabilidades) sobre todas las categorías posibles.  
   - Se toma el índice de la categoría con mayor valor (“argmax”).  

2. **`duration_out` (Float [1])**  
   - Escalar que estima cuántos minutos realmente tomará la tarea.  
   - Permite ajustar la duración en UI (mostrar “duración real esperada: XX min” en lugar de la estimada inicial.

---

## 4. Flujo de Inferencia y Reglas Híbridas

A continuación se describe en detalle cada paso que realiza la aplicación al procesar una tarea nueva.

### 4.1. Lectura de Inputs

1. **Descripción textual**:  
   - Usuario ingresa “Preparar informe de ventas”.

2. **Duración estimada**:  
   - Usuario indica “60” en el campo “Duración estimada (min)”.

3. **Contexto temporal actual**:  
   - `DateTime now = DateTime.now();`  
   - `double startHour = now.hour.toDouble();`  
   - `double startWeekday = (now.weekday – 1).toDouble(); // 0–6`

4. **Vector OHE (opcional)**:  
   - Si el usuario selecciona manualmente una categoría antigua (por ejemplo, “Trabajo”), se construye un vector con 1 en la posición de “Trabajo” y 0 en resto.  
   - Si es tarea nueva, se envía un vector de todos ceros.

### 4.2. Inferencia On-Device (TFLite)

- Se llama a `TFLiteService.runInference(...)` con los cinco tipos de inputs.  
- Internamente:  
  1. **TextBuffer**: el string “Preparar informe de ventas” se carga como tensor `'tf.string'`.  
  2. **FloatBuffers**: se cargan `60.0`, `startHour`, `startWeekday`.  
  3. **Buffers OHE**: se crean N tensores `'tf.float32'` (uno por categoría manual).  
  4. Se ensamblan en una lista `[text, estimatedDuration, startHour, startWeekday, ohe1, ohe2, …]`.  
  5. El intérprete TFLite produce dos tensores de salida:
     - **Logits de categorías** (`[1, num_classes]`).  
     - **Duración real estimada** (`[1]`).
  6. Se interpretan los logits con `argmax` para obtener la **categoría predicha**, y el valor único para la **duración**.

### 4.3. Lectura de Bloques Productivos

- Se utiliza un servicio `CSVService.loadTop3Blocks()` para leer `top3_productive_blocks.csv`.  
- Formato de cada fila: `[start_weekday, start_hour, completion_rate]`.
- Por ejemplo:
2, 10, 0.88
1, 14, 0.85
4, 09, 0.83

markdown
Copiar
Editar
donde `start_weekday = 2` (miércoles), `start_hour = 10` (10 AM), y `completion_rate = 0.88`.

### 4.4. Reglas de Negocio Híbridas

1. **Obtener Eventos Ocupados**  
 - Se usa `device_calendar` para descargar eventos del calendario local entre 00:00 y 23:59 del día actual.  
 - Cada evento genera un `TimeRange(start, end)`.

2. **Iterar sobre Top 3 Bloques** (ordenados de mayor a menor `completion_rate`):
 - Para cada bloque `(weekday, hour, rate)`:
   1. Calcular la próxima fecha ≥ hoy con el mismo `weekday`:  
      ```dart
      int currentWeekday = now.weekday - 1; // 0–6
      int daysAhead = (block.weekday - currentWeekday) % 7;
      DateTime candidateDate = now.add(Duration(days: daysAhead));
      ```
   2. Verificar si el bloque `(candidateDate, block.hour)` está libre:  
      - Construir `DateTime slotStart = DateTime(candidateDate.year, candidateDate.month, candidateDate.day, block.hour, 0);`  
      - `DateTime slotEnd = slotStart.add(Duration(hours: 1));`  
      - Comparar con cada `TimeRange` de eventos; si hay solapamiento, descartar y probar siguiente bloque.
   3. **Reglas adicionales**:
      - Si la tarea tiene **prioridad ≥ 4**, aceptar este bloque sin más restricciones.
      - Si la categoría predicha es **“Formacion”** y el **moodLevel < 0.4**, descartar este bloque (buscar siguiente).
      - Si el **energyLevel < 0.3** y `block.completion_rate < 0.8`, descartar (buscar siguiente).
      - Cualquier otro caso, aceptar el bloque.
 - Si un bloque pasa todas las pruebas, se retorna como `suggestedBlock`.
 - Si ninguno de los Top 3 está libre/apto, se puede:
   - Retornar `null`.  
   - (Opcional) Leer `productive_blocks_stats.csv`, filtrar bloques con `completion_rate ≥ 0.7` y volver a aplicar la misma lógica.

### 4.5. Resultado Final

- La app presenta al usuario:
1. **Categoría predicha**: muestra texto como “Categoría: Estudio”.  
2. **Duración real estimada**: muestra “Duración estimada: 45 min”.  
3. **Bloque horario sugerido**: si hay bloque válido, muestra “Sugerencia: Miércoles a las 10:00 AM”.  
   - Si no hay bloque libre en TOP 3, muestra “No hay bloque productivo libre en Top 3; revisa tu calendario o vuelve a intentar más tarde”.

---

## 5. Componentes y Archivos Implicados

1. **`multitask_model_fp16.tflite`**  
 - El modelo multitarea con dos heads (clasificación y regresión).

2. **`labels.txt`**  
 - Lista de categorías, una línea por categoría, en el orden concordante con el modelo.

3. **`top3_productive_blocks.csv`**  
 - CSV con 3 filas: `[weekday, hour, completion_rate]` de los bloques más productivos.

4. **`productive_blocks_stats.csv`** (opcional)  
 - CSV completo de todos los bloques y sus métricas:  
   ```
   start_weekday, start_hour, total_tasks, completed_tasks, completion_rate, is_productive
   ```

5. **Servicio TFLite** (`tflite_service.dart`)  
 - Carga el modelo `.tflite`, las `labels.txt` y ejecuta inferencia con inputs combinados.

6. **Servicio CSV** (`csv_service.dart`)  
 - Lee los archivos CSV desde `assets/stats/` y construye listas de objetos `ProductiveBlock`.

7. **Servicio de Reglas** (`schedule_rule_service.dart`)  
 - Combina Top 3 bloques con disponibilidad de calendario (`device_calendar`) y reglas de contexto (prioridad, energía, humor, categoría).

8. **Página UI** (`HomePage` en `main.dart`)  
 - El usuario ingresa descripción y duración, se llama a TFLiteService para inferencia, luego a ScheduleRuleService para obtener bloque sugerido, y se muestra en pantalla.

---

## 6. Variables de Contexto Dinámico

Para que la recomendación híbrida sea personalizada, se puede usar información adicional del usuario:

- **`priority` (int 1–5)**  
- La app puede permitir que el usuario asigne prioridad manualmente o inferirlo de datos previos.

- **`energyLevel` (double 0.0–1.0)**  
- Puede almacenarse como parte del perfil del usuario (auto-reportado al iniciar la app) o deducirse de hábitos.

- **`moodLevel` (double 0.0–1.0)**  
- Similar a `energyLevel`; puede influir en si se sugiere un bloque más productivo o uno más relajado.

- **`oheValues` (List<double>)**  
- Si el usuario elige manualmente una categoría al crear la tarea, se transmite al modelo en forma de vector One-Hot.  
- Si la tarea es nueva sin categoría previa, se envían todos ceros.

---

## 7. Consideraciones y Recomendaciones

1. **El modelo TFLite ya incluye TextVectorization**  
 - No es necesario procesar texto con bibliotecas externas en Flutter; basta con pasar el String directamente al tensor `'TfLiteType.STRING'`.

2. **Orden de Inputs y Names**  
 - El modelo espera los tensores en un orden muy específico:  
   1. `task_description` (String)  
   2. `estimated_duration_minutes` (Float)  
   3. `start_hour` (Float)  
   4. `start_weekday` (Float)  
   5. Cada valor OHE en el mismo orden en que fueron definidos (`input_<Categoria1>`, `input_<Categoria2>`, …)

3. **Voltaje de Batería y Performance**  
 - Como el modelo es ligero (quantized float16) y `TextVectorization` está embebido, la inferencia on-device es rápida y no impacta significativamente la batería.

4. **Seguridad y Privacidad**  
 - Todas las predicciones de ML se hacen localmente en el dispositivo; **no se envía texto ni datos a la nube**.  
 - Los CSV de estadísticas (`top3_productive_blocks.csv`) pueden actualizarse periódicamente sin exponer datos sensibles, pues solo contienen métricas agregadas (weekday, hour, rate).

5. **Actualización de Estadísticas y Modelo**  
 - Cada cierto intervalo (p. ej. semanal), se podría volver a entrenar el modelo en Colab usando datos nuevos del usuario (si dichos datos fueron sincronizados o agregados a un backend seguro) y generar un nuevo `.tflite` y nuevos CSVs.  
 - La app podría descargar OTA (over-the-air) estos artefactos actualizados para mejorar la precisión con el tiempo.

6. **Manejo de Errores y Caídas**  
 - Validar en Flutter:
   - Que el modelo y labels se carguen correctamente al iniciar.  
   - Que el CSV de Top 3 exista y tenga 3 filas válidas.  
 - Si falla la inferencia (por falla en archivos o nombres mismatched), informar al usuario y sugerir lógica por defecto (p. ej. “Revisa tu conexión o reinstala la app”).

---

## 8. Ejemplo de Flujo de Uso (Resumen Rápido)

1. Usuario abre la app y ve campos para “Descripción” y “Duración estimada”.  
2. Ingresa “Preparar informe de ventas” y “60”.  
3. La app obtiene hora y día actuales.  
4. Llama a **TFLiteService**:
 - Inicia tensores de texto y floats → ejecuta `runInference(...)`.  
 - Recibe `predCategory = "Trabajo"` y `predDuration = 55.2 min`.  
5. Lee `top3_productive_blocks.csv` → obtiene, por ejemplo:
2, 10, 0.88 ← Miércoles 10 AM (88% completado)
1, 14, 0.85 ← Martes 14 PM (85% completado)
4, 09, 0.82 ← Jueves 09 AM (82% completado)

markdown
Copiar
Editar
6. Llama a **ScheduleRuleService.suggestBlock(...)** con:
- `referenceDate = hoy`.
- `priority = 3`, `energyLevel = 0.6`, `moodLevel = 0.7`, `predictedCategory = "Trabajo"`.
- Verifica disponibilidad en calendario para Miércoles 10 AM. Si libre, sugiere ese bloque.  
7. La UI muestra:
Categoría predicha: Trabajo
Duración estimada real: 55 min
Bloque sugerido: Miércoles a las 10:00

yaml
Copiar
Editar
8. Usuario acepta la sugerencia y la tarea se programa en el calendario local.  
9. Cuando el usuario completa o postergue, la app registra `status = "Completada"` o `"Postergada"`.  
10. Offline, se actualizan estadísticas de bloques y, eventualmente, se reentrena el modelo para futuras predicciones.

---

---

**Fin de la Guía Híbrida**  
Este documento en un solo archivo `.md` contiene toda la información necesaria para que otra IA (o un desarrollador) implemente el consumo del modelo TFLite junto con la lógica de reglas en Flutter, sin requerir más contexto ni entrenamiento adicional.  