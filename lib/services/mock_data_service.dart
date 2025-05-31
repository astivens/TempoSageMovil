import 'dart:math';
import '../features/timeblocks/data/models/time_block_model.dart';
import '../features/timeblocks/data/repositories/time_block_repository.dart';
import '../core/utils/logger.dart';

/// Servicio para generar datos simulados para pruebas de machine learning
class MockDataService {
  final Random _random = Random();
  final TimeBlockRepository _repository;
  final Logger _logger = Logger.instance;

  /// Lista de categorías comunes para bloques de tiempo
  static const List<String> _categories = [
    'Trabajo',
    'Estudio',
    'Ejercicio',
    'Ocio',
    'Familia',
    'Proyectos',
    'Descanso',
    'Tareas domésticas',
    'Transporte',
    'Socializar',
    'Desarrollo personal',
    'Comidas',
  ];

  /// Lista de posibles títulos para cada categoría
  static const Map<String, List<String>> _categoryTitles = {
    'Trabajo': [
      'Reunión de equipo',
      'Desarrollo de proyecto',
      'Llamada con cliente',
      'Revisión de código',
      'Planificación semanal',
      'Responder emails',
      'Informe mensual',
    ],
    'Estudio': [
      'Curso de Flutter',
      'Lectura de documentación',
      'Práctica de algoritmos',
      'Preparación para examen',
      'Investigación',
      'Tutoría',
      'Clase en línea',
    ],
    'Ejercicio': [
      'Cardio',
      'Entrenamiento de fuerza',
      'Yoga',
      'Caminar',
      'Correr',
      'Natación',
      'Estiramientos',
    ],
    'Ocio': [
      'Ver película',
      'Leer libro',
      'Jugar videojuegos',
      'Escuchar música',
      'Pasatiempo',
      'Navegación web',
      'Redes sociales',
    ],
    'Familia': [
      'Cena familiar',
      'Ayudar con tareas',
      'Juegos en familia',
      'Paseo con hijos',
      'Visita a familiares',
      'Actividad con niños',
    ],
    'Proyectos': [
      'Proyecto personal',
      'Programación',
      'Diseño',
      'Investigación',
      'Planificación',
      'Revisión de avances',
    ],
    'Descanso': [
      'Siesta',
      'Meditación',
      'Relajación',
      'Descanso mental',
      'Dormir',
    ],
    'Tareas domésticas': [
      'Limpieza',
      'Lavandería',
      'Cocinar',
      'Compras',
      'Reparaciones',
      'Organización',
    ],
    'Transporte': [
      'Trayecto al trabajo',
      'Conducir',
      'Transporte público',
      'Viaje en bicicleta',
      'Caminar',
    ],
    'Socializar': [
      'Café con amigos',
      'Fiesta',
      'Videollamada',
      'Cena social',
      'Evento social',
      'Reunión casual',
    ],
    'Desarrollo personal': [
      'Meditación',
      'Diario personal',
      'Establecimiento de metas',
      'Autorreflexión',
      'Aprendizaje de habilidades',
      'Lectura de crecimiento personal',
    ],
    'Comidas': [
      'Desayuno',
      'Almuerzo',
      'Cena',
      'Merienda',
      'Preparación de comida',
      'Comida fuera',
    ],
  };

  /// Constructor que recibe el repositorio
  MockDataService(this._repository);

  /// Genera datos para un mes (30 días)
  Future<void> generateMonthData() async {
    // Limpiar datos existentes
    await _deleteAllTimeBlocks();

    // Generar datos para 30 días
    final startDate = DateTime.now().subtract(Duration(days: 30));

    for (int i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final blocks = _generateDayBlocks(date);
      await _saveMultipleTimeBlocks(blocks);
    }
  }

  /// Elimina todos los bloques de tiempo existentes
  Future<void> _deleteAllTimeBlocks() async {
    final timeBlocks = await _repository.getAllTimeBlocks();
    for (final block in timeBlocks) {
      await _repository.deleteTimeBlock(block.id);
    }
  }

  /// Guarda múltiples bloques de tiempo
  Future<void> _saveMultipleTimeBlocks(List<TimeBlockModel> blocks) async {
    for (final block in blocks) {
      await _repository.addTimeBlock(block);
    }
  }

  /// Genera bloques de tiempo para un día específico
  List<TimeBlockModel> _generateDayBlocks(DateTime date) {
    // Número aleatorio de bloques para el día (entre 3 y 8)
    final numBlocks = _random.nextInt(6) + 3;
    final blocks = <TimeBlockModel>[];

    // Horas disponibles (generalmente de 8 AM a 10 PM)
    final startHour = 8;
    final endHour = 22;

    // Lista de horas ya ocupadas
    final occupiedSlots = <int>[];

    for (int i = 0; i < numBlocks; i++) {
      // Seleccionar una hora de inicio que no esté ocupada
      int startTimeHour;
      do {
        startTimeHour = _random.nextInt(endHour - startHour) + startHour;
      } while (occupiedSlots.contains(startTimeHour));

      // Marcar esta hora como ocupada
      occupiedSlots.add(startTimeHour);

      // Crear el bloque
      final block = _generateRandomTimeBlock(date, startTimeHour);
      blocks.add(block);
    }

    return blocks;
  }

  /// Genera un bloque de tiempo aleatorio
  TimeBlockModel _generateRandomTimeBlock(DateTime date, int startHour) {
    // Seleccionar una categoría aleatoria
    final category = _categories[_random.nextInt(_categories.length)];

    // Seleccionar un título aleatorio para la categoría
    final titles = _categoryTitles[category] ?? const ['Actividad'];
    final title = titles[_random.nextInt(titles.length)];

    // Generar hora de inicio
    final startMinute = _random.nextInt(4) * 15; // Minutos en intervalos de 15
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      startHour,
      startMinute,
    );

    // Duración aleatoria entre 15 minutos y 3 horas (en incrementos de 15 minutos)
    final durationMinutes = (_random.nextInt(12) + 1) * 15;
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    // Estado de completado basado en si la fecha es pasada
    final isCompleted = date.isBefore(DateTime.now());

    // Generar ID único
    final id = _generateTimeBasedId();

    // Generar un color aleatorio
    final color = _generateRandomColor();

    return TimeBlockModel(
      id: id,
      title: title,
      description:
          "Bloque de tiempo generado automáticamente para pruebas de ML",
      startTime: startTime,
      endTime: endTime,
      category: category,
      isFocusTime: _random.nextBool(),
      color: color,
      isCompleted: isCompleted,
    );
  }

  /// Genera un ID basado en tiempo
  String _generateTimeBasedId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  /// Genera un color aleatorio en formato hexadecimal
  String _generateRandomColor() {
    const letters = '0123456789ABCDEF';
    String color = '#';
    for (int i = 0; i < 6; i++) {
      color += letters[_random.nextInt(16)];
    }
    return color;
  }

  /// Carga un conjunto de datos para testing de ML
  Future<void> loadMockDataForML() async {
    await generateMonthData();
    final timeBlocks = await _repository.getAllTimeBlocks();
    _logger.i(
        'Datos simulados generados correctamente: ${timeBlocks.length} bloques de tiempo',
        tag: 'MockDataService');
  }
}
