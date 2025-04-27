import '../../data/models/habit_model.dart';
import '../../data/repositories/habit_repository.dart';
import '../../../timeblocks/data/models/time_block_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';
import 'package:flutter/foundation.dart';

class HabitToTimeBlockService {
  final HabitRepository _habitRepository;
  final TimeBlockRepository _timeBlockRepository;

  // Cache para evitar operaciones repetidas
  final Map<String, TimeBlockModel> _habitTimeBlockCache = {};

  // Caché para trackear qué hábitos ya han sido convertidos a timeblocks para cada fecha
  final Map<String, Set<String>> _convertedHabitsCache = {};

  HabitToTimeBlockService(this._habitRepository, this._timeBlockRepository);

  // Convertir un hábito individual a un timeblock (versión optimizada)
  Future<TimeBlockModel?> convertSingleHabitToTimeBlock(
      HabitModel habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Verificar si el hábito debe ejecutarse hoy (día de la semana)
    if (!habit.daysOfWeek.contains(today.weekday)) {
      return null;
    }

    // Verificar si ya tenemos este timeblock en caché
    final cacheKey = '${habit.id}_${today.toIso8601String()}';
    if (_habitTimeBlockCache.containsKey(cacheKey)) {
      return _habitTimeBlockCache[cacheKey];
    }

    // Crear la fecha de inicio con la hora del hábito pero la fecha de hoy
    final startTime = DateTime(
      today.year,
      today.month,
      today.day,
      habit.time.hour,
      habit.time.minute,
    );

    final endTime = startTime.add(const Duration(minutes: 30));

    // Crear el timeblock con la información del hábito
    final timeBlock = TimeBlockModel.create(
      title: habit.title,
      description: habit.description,
      startTime: startTime,
      endTime: endTime,
      category: habit.category,
      isFocusTime: true,
      color: _getCategoryColor(habit.category),
      isCompleted: habit.isCompleted,
    );

    // Guardar en caché
    _habitTimeBlockCache[cacheKey] = timeBlock;

    return timeBlock;
  }

  // Convertir todos los hábitos programados para una fecha específica a timeblocks
  Future<List<TimeBlockModel>> convertHabitsToTimeBlocks(DateTime date) async {
    try {
      // Normalizar fecha para consistencia
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateKey = normalizedDate.toIso8601String().split('T')[0];

      // Inicializar el conjunto de hábitos convertidos para esta fecha si no existe
      _convertedHabitsCache[dateKey] ??= {};

      // Obtener todos los hábitos para esta fecha
      final habits = await _habitRepository.getHabitsForDate(normalizedDate);
      debugPrint(
          'Evaluando ${habits.length} hábitos para conversión en $dateKey');

      // Verificar timeblocks existentes para esta fecha
      final existingTimeBlocks =
          await _timeBlockRepository.getTimeBlocksByDate(normalizedDate);
      final existingHabitIds = existingTimeBlocks
          .where((block) =>
              block.description.contains('Hábito generado automáticamente'))
          .map((block) => _extractHabitIdFromDescription(block.description))
          .where((id) => id != null)
          .toSet();

      debugPrint(
          'Encontrados ${existingHabitIds.length} timeblocks de hábitos existentes');

      // Filtrar solo hábitos que:
      // 1. No han sido ya convertidos (según caché)
      // 2. No tienen timeblocks existentes
      final habitsToConvert = habits.where((habit) {
        // Verificar si el hábito ya ha sido convertido según la caché
        final alreadyConverted =
            _convertedHabitsCache[dateKey]!.contains(habit.id);

        // Verificar si ya existe un timeblock para este hábito
        final hasExistingTimeBlock = existingHabitIds.contains(habit.id);

        final shouldConvert = !alreadyConverted && !hasExistingTimeBlock;

        debugPrint('Hábito ${habit.id} (${habit.title}): '
            'ya convertido=$alreadyConverted, '
            'timeblock existente=$hasExistingTimeBlock, '
            'se convertirá=$shouldConvert');

        return shouldConvert;
      }).toList();

      debugPrint(
          'Se convertirán ${habitsToConvert.length} hábitos a timeblocks');

      // Convertir y crear timeblocks para estos hábitos
      final timeBlocks = <TimeBlockModel>[];
      final saveOperations = <Future<void>>[];

      for (final habit in habitsToConvert) {
        final timeBlock = _createTimeBlockFromHabit(habit, normalizedDate);
        timeBlocks.add(timeBlock);

        // Acumular operaciones de guardado
        saveOperations.add(_timeBlockRepository.addTimeBlock(timeBlock));

        // Agregar a la caché de convertidos para evitar duplicados
        _convertedHabitsCache[dateKey]!.add(habit.id);
      }

      // Ejecutar todas las operaciones de guardado en paralelo
      if (saveOperations.isNotEmpty) {
        await Future.wait(saveOperations);
      }

      debugPrint(
          'Convertidos ${habitsToConvert.length} hábitos a timeblocks con éxito');
      return timeBlocks;
    } catch (e) {
      debugPrint('Error en convertHabitsToTimeBlocks: $e');
      rethrow;
    }
  }

  // Extraer el ID del hábito de la descripción del timeblock
  String? _extractHabitIdFromDescription(String description) {
    // Buscar el patrón "ID del hábito: [id]" en la descripción
    final match =
        RegExp(r'ID del hábito: ([a-zA-Z0-9-]+)').firstMatch(description);
    return match?.group(1);
  }

  // Crear un timeblock a partir de un hábito
  TimeBlockModel _createTimeBlockFromHabit(HabitModel habit, DateTime date) {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      habit.time.hour,
      habit.time.minute,
    );

    final endDateTime = startDateTime.add(const Duration(minutes: 30));

    final timeBlock = TimeBlockModel.create(
      title: 'Hábito: ${habit.title}',
      description:
          '${habit.description}\n\nHábito generado automáticamente\nID del hábito: ${habit.id}',
      startTime: startDateTime,
      endTime: endDateTime,
      category: habit.category,
      isFocusTime: true,
      color: _getCategoryColor(habit.category),
      isCompleted: habit.isCompleted,
    );

    debugPrint('Creado timeblock para hábito ${habit.id} (${habit.title})');
    return timeBlock;
  }

  // Limpiar la caché para forzar una regeneración de timeblocks
  void clearCache() {
    _convertedHabitsCache.clear();
    debugPrint('Caché de conversión de hábitos limpiada');
  }

  // Método auxiliar para sincronizar timeblocks para un hábito específico
  Future<void> syncTimeBlocksForHabit(HabitModel habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Verificar si el hábito debe ejecutarse hoy
    if (!habit.daysOfWeek.contains(today.weekday)) {
      // Eliminar timeblocks existentes para este hábito ya que no corresponde al día actual
      final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(today);
      final existingBlock = timeBlocks.firstWhere(
        (block) => block.title == habit.title,
        orElse: () => TimeBlockModel.create(
          title: '',
          description: '',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          category: '',
          color: '',
        ),
      );

      if (existingBlock.title.isNotEmpty) {
        await _timeBlockRepository.deleteTimeBlock(existingBlock.id);
      }

      return;
    }

    // Crear nuevo timeblock
    final startTime = DateTime(
        today.year, today.month, today.day, habit.time.hour, habit.time.minute);
    final endTime = startTime.add(const Duration(minutes: 30));

    final updatedTimeBlock = TimeBlockModel.create(
      title: habit.title,
      description: habit.description,
      startTime: startTime,
      endTime: endTime,
      category: habit.category,
      isFocusTime: true,
      color: _getCategoryColor(habit.category),
      isCompleted: habit.isCompleted,
    );

    // Buscar timeblock existente
    final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(today);
    final existingBlock = timeBlocks.firstWhere(
      (block) => block.title == habit.title,
      orElse: () => TimeBlockModel.create(
        title: '',
        description: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        color: '',
      ),
    );

    // Actualizar o crear según corresponda
    if (existingBlock.title.isNotEmpty) {
      await _timeBlockRepository.deleteTimeBlock(existingBlock.id);
    }

    await _timeBlockRepository.addTimeBlock(updatedTimeBlock);

    // Actualizar caché
    final cacheKey = '${habit.id}_${today.toIso8601String()}';
    _habitTimeBlockCache[cacheKey] = updatedTimeBlock;
  }

  // Método auxiliar para eliminar timeblocks asociados a un hábito
  Future<void> deleteTimeBlocksForHabit(HabitModel habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(today);

    // Encontrar y eliminar el timeblock correspondiente
    for (final block in timeBlocks) {
      if (block.title == habit.title) {
        await _timeBlockRepository.deleteTimeBlock(block.id);
      }
    }

    // Limpiar caché
    _habitTimeBlockCache
        .removeWhere((key, _) => key.startsWith('${habit.id}_'));
  }

  // Método auxiliar para determinar color basado en categoría
  String _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trabajo':
        return '#7AA2F7'; // Blue
      case 'personal':
        return '#9ECE6A'; // Green
      case 'estudio':
        return '#9D7CD8'; // Purple
      case 'otro':
        return '#E0AF68'; // Yellow
      default:
        return '#9D7CD8'; // Default purple
    }
  }
}
