import 'package:flutter/foundation.dart';
import '../../data/models/habit_model.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../../timeblocks/data/models/time_block_model.dart';
import '../../../timeblocks/data/repositories/time_block_repository.dart';
import '../../../../core/utils/error_handler.dart';
import '../entities/habit.dart';
import 'package:uuid/uuid.dart';

/// Servicio que convierte hábitos en bloques de tiempo y mantiene la sincronización entre ellos.
///
/// Responsable de:
/// - Convertir hábitos a bloques de tiempo para fechas específicas
/// - Evitar la creación de bloques duplicados
/// - Mantener la consistencia entre hábitos y sus representaciones como bloques de tiempo
class HabitToTimeBlockService {
  // Dependencias
  final HabitRepository _habitRepository;
  final TimeBlockRepository _timeBlockRepository;

  // Constantes
  static const int _defaultDurationMinutes = 30;
  static const String _habitBlockPrefix = 'Hábito: ';
  static const String _habitGeneratedTag = 'Hábito generado automáticamente';

  // Caché
  final Map<String, TimeBlockModel> _timeBlockCache = {};
  final Map<String, Set<String>> _convertedHabitsCache = {};

  /// Constructor con inyección de dependencias.
  HabitToTimeBlockService(this._habitRepository, this._timeBlockRepository);

  /// Convierte todos los hábitos programados para una fecha específica a bloques de tiempo.
  ///
  /// [date] La fecha para la cual convertir los hábitos.
  ///
  /// Retorna una lista de los bloques de tiempo creados.
  /// Lanza [RepositoryException] si hay un error al acceder al repositorio.
  Future<List<TimeBlockModel>> convertHabitsToTimeBlocks(DateTime date) async {
    try {
      // Normalizar fecha para consistencia (año, mes, día sin tiempo)
      final normalizedDate = _normalizeDate(date);
      final dateKey = _getDateKey(normalizedDate);
      final currentDay = _getCurrentDayName(normalizedDate);

      // Inicializar caché para esta fecha si no existe
      _convertedHabitsCache[dateKey] ??= {};

      // Obtener hábitos relevantes para esta fecha
      final habits = await _habitRepository.getHabitsByDayOfWeek(currentDay);
      final habitModels = habits.map(_mapEntityToModel).toList();

      debugPrint(
          'Evaluando ${habitModels.length} hábitos para conversión en $dateKey');

      // Verificar timeblocks existentes para evitar duplicados
      final existingTimeBlocks =
          await _timeBlockRepository.getTimeBlocksByDate(normalizedDate);
      final existingHabitIds =
          _extractHabitIdsFromTimeBlocks(existingTimeBlocks);

      debugPrint(
          'Encontrados ${existingHabitIds.length} timeblocks de hábitos existentes');

      // Filtrar solo hábitos que necesitan ser convertidos
      final habitsToConvert =
          _filterHabitsToConvert(habitModels, existingHabitIds, dateKey);
      debugPrint(
          'Se convertirán ${habitsToConvert.length} hábitos a timeblocks');

      if (habitsToConvert.isEmpty) {
        return [];
      }

      // Crear y guardar timeblocks en paralelo
      return await _createAndSaveTimeBlocks(
          habitsToConvert, normalizedDate, dateKey);
    } catch (e) {
      final errorMsg = 'Error al convertir hábitos a timeblocks';
      ErrorHandler.logError(errorMsg, e, null);
      throw RepositoryException(errorMsg, originalError: e);
    }
  }

  String _getCurrentDayName(DateTime date) {
    final weekday = date.weekday;
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return days[weekday - 1];
  }

  /// Extrae los IDs de hábitos desde timeblocks que fueron creados desde hábitos.
  Set<String> _extractHabitIdsFromTimeBlocks(List<TimeBlockModel> timeBlocks) {
    return timeBlocks
        .where((block) => block.description.contains(_habitGeneratedTag))
        .map((block) => _extractHabitIdFromDescription(block.description))
        .where((id) => id != null)
        .map((id) => id!)
        .toSet();
  }

  /// Filtra los hábitos que necesitan ser convertidos a timeblocks.
  List<HabitModel> _filterHabitsToConvert(
      List<HabitModel> habits, Set<String> existingHabitIds, String dateKey) {
    return habits.where((habit) {
      // Verificar si ya fue convertido según la caché
      final alreadyConverted =
          _convertedHabitsCache[dateKey]!.contains(habit.id);

      // Verificar si ya existe un timeblock para este hábito
      final hasExistingTimeBlock = existingHabitIds.contains(habit.id);

      final shouldConvert = !alreadyConverted && !hasExistingTimeBlock;

      if (kDebugMode) {
        _logHabitConversionStatus(
            habit, alreadyConverted, hasExistingTimeBlock, shouldConvert);
      }

      return shouldConvert;
    }).toList();
  }

  void _logHabitConversionStatus(HabitModel habit, bool alreadyConverted,
      bool hasExistingTimeBlock, bool shouldConvert) {
    debugPrint('Hábito ${habit.id} (${habit.title}):');
    debugPrint(' - Ya convertido: $alreadyConverted');
    debugPrint(' - Tiene timeblock existente: $hasExistingTimeBlock');
    debugPrint(' - Se convertirá: $shouldConvert');
  }

  /// Crea y guarda timeblocks para los hábitos especificados.
  Future<List<TimeBlockModel>> _createAndSaveTimeBlocks(
      List<HabitModel> habits, DateTime date, String dateKey) async {
    final timeBlocks = <TimeBlockModel>[];
    final saveOperations = <Future<void>>[];

    // Crear y preparar todos los timeblocks
    for (final habit in habits) {
      final timeBlock = _createTimeBlockFromHabit(habit);
      timeBlocks.add(timeBlock);

      // Acumular operaciones de guardado
      saveOperations.add(_timeBlockRepository.addTimeBlock(timeBlock));

      // Actualizar caché
      _updateCache(habit, timeBlock, dateKey);
    }

    // Ejecutar todas las operaciones de guardado en paralelo
    if (saveOperations.isNotEmpty) {
      await Future.wait(saveOperations);
      debugPrint('Guardados ${timeBlocks.length} timeblocks para hábitos');
    }

    return timeBlocks;
  }

  /// Actualiza la caché con el nuevo timeblock creado.
  void _updateCache(
      HabitModel habit, TimeBlockModel timeBlock, String dateKey) {
    // Guardar en caché de tiempo/bloque
    final cacheKey = '${habit.id}_$dateKey';
    _timeBlockCache[cacheKey] = timeBlock;

    // Marcar hábito como convertido para esta fecha
    _convertedHabitsCache[dateKey]!.add(habit.id);
  }

  /// Convierte un solo hábito a un timeblock para una fecha específica.
  ///
  /// [habit] El hábito a convertir.
  /// [date] La fecha para la cual crear el timeblock.
  ///
  /// Retorna el timeblock creado o `null` si el hábito no debe ejecutarse ese día.
  Future<TimeBlockModel?> convertSingleHabitToTimeBlock(
      HabitModel habit) async {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final currentDay = _getCurrentDayName(today);

    // Verificar si el hábito debe ejecutarse hoy
    if (!habit.daysOfWeek.contains(currentDay)) {
      return null;
    }

    // Verificar si ya existe en caché
    final cacheKey = '${habit.id}_${_getDateKey(today)}';
    if (_timeBlockCache.containsKey(cacheKey)) {
      return _timeBlockCache[cacheKey];
    }

    // Crear el timeblock
    final timeBlock = _createTimeBlockFromHabit(habit);

    // Actualizar caché
    _timeBlockCache[cacheKey] = timeBlock;

    return timeBlock;
  }

  /// Sincroniza un timeblock para un hábito específico.
  ///
  /// Actualiza o crea un timeblock según el estado actual del hábito.
  /// [habit] El hábito a sincronizar.
  Future<void> syncTimeBlocksForHabit(HabitModel habit) async {
    try {
      final today = _normalizeDate(DateTime.now());
      final currentDay = _getCurrentDayName(today);

      // Si el hábito no corresponde a hoy, eliminar cualquier timeblock existente
      if (!habit.daysOfWeek.contains(currentDay)) {
        await _removeTimeBlocksForHabit(habit, today);
        return;
      }

      // Crear/actualizar timeblock para este hábito
      final timeBlock = _createTimeBlockFromHabit(habit);
      await _saveTimeBlockWithReplacement(habit, timeBlock, today);

      // Actualizar caché
      final dateKey = _getDateKey(today);
      _updateCache(habit, timeBlock, dateKey);
    } catch (e) {
      ErrorHandler.logError(
          'Error al sincronizar timeblock para hábito', e, null);
      throw RepositoryException('Error al sincronizar timeblock para hábito',
          originalError: e);
    }
  }

  /// Busca y elimina timeblocks existentes para un hábito.
  Future<void> _removeTimeBlocksForHabit(
      HabitModel habit, DateTime date) async {
    final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(date);

    // Encontrar bloque por título o ID en descripción
    final existingBlock = timeBlocks.firstWhere(
      (block) =>
          block.title == habit.title ||
          (block.title == '$_habitBlockPrefix${habit.title}' &&
              block.description.contains('ID del hábito: ${habit.id}')),
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
      debugPrint('Eliminado timeblock para hábito ${habit.id}');
    }
  }

  /// Guarda un timeblock, reemplazando uno existente si es necesario.
  Future<void> _saveTimeBlockWithReplacement(
      HabitModel habit, TimeBlockModel newTimeBlock, DateTime date) async {
    final timeBlocks = await _timeBlockRepository.getTimeBlocksByDate(date);

    // Buscar si ya existe un timeblock para este hábito
    final existingBlock = timeBlocks.firstWhere(
      (block) =>
          block.title == '$_habitBlockPrefix${habit.title}' ||
          (block.description.contains('ID del hábito: ${habit.id}')),
      orElse: () => TimeBlockModel.create(
        title: '',
        description: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        category: '',
        color: '',
      ),
    );

    // Eliminar el existente si lo hay
    if (existingBlock.title.isNotEmpty) {
      await _timeBlockRepository.deleteTimeBlock(existingBlock.id);
    }

    // Guardar el nuevo
    await _timeBlockRepository.addTimeBlock(newTimeBlock);
  }

  /// Elimina todos los timeblocks asociados a un hábito.
  Future<void> deleteTimeBlocksForHabit(HabitModel habit) async {
    try {
      final today = _normalizeDate(DateTime.now());
      await _removeTimeBlocksForHabit(habit, today);

      // Limpiar caché relacionada con este hábito
      final habitCacheKeys = _timeBlockCache.keys
          .where((key) => key.startsWith('${habit.id}_'))
          .toList();

      for (final key in habitCacheKeys) {
        _timeBlockCache.remove(key);
      }

      // Actualizar caché de hábitos convertidos
      for (final dateKey in _convertedHabitsCache.keys) {
        _convertedHabitsCache[dateKey]?.remove(habit.id);
      }

      debugPrint('Eliminados timeblocks y caché para hábito ${habit.id}');
    } catch (e) {
      ErrorHandler.logError(
          'Error al eliminar timeblocks para hábito', e, null);
      throw RepositoryException('Error al eliminar timeblocks para hábito',
          originalError: e);
    }
  }

  /// Crea un TimeBlockModel a partir de un hábito.
  TimeBlockModel _createTimeBlockFromHabit(HabitModel habit) {
    final now = DateTime.now();

    // Extraer hora y minuto del string de tiempo (formato HH:mm)
    final timeParts = habit.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Crear datetime con la fecha actual y la hora del hábito
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Determinar la hora de finalización (30 minutos por defecto)
    final endDateTime =
        startDateTime.add(Duration(minutes: _defaultDurationMinutes));

    return TimeBlockModel(
      id: const Uuid().v4(),
      title: '$_habitBlockPrefix${habit.title}',
      description:
          '${habit.description}\n\n$_habitGeneratedTag\nID del hábito: ${habit.id}',
      startTime: startDateTime,
      endTime: endDateTime,
      category: habit.category,
      isFocusTime: true,
      color: _getCategoryColor(habit.category),
      isCompleted: habit.isCompleted,
    );
  }

  /// Extrae el ID del hábito de la descripción de un timeblock.
  String? _extractHabitIdFromDescription(String description) {
    final match =
        RegExp(r'ID del hábito: ([a-zA-Z0-9-]+)').firstMatch(description);
    return match?.group(1);
  }

  /// Obtiene una clave de caché para una fecha.
  String _getDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Normaliza una fecha eliminando la componente de tiempo.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Determina un color para un timeblock basado en su categoría.
  String _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trabajo':
        return '#7AA2F7'; // Azul
      case 'personal':
        return '#9ECE6A'; // Verde
      case 'estudio':
        return '#9D7CD8'; // Púrpura
      case 'otro':
        return '#E0AF68'; // Amarillo
      default:
        return '#9D7CD8'; // Púrpura por defecto
    }
  }

  // Función para mapear Habit a HabitModel
  HabitModel _mapEntityToModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      title: entity.name,
      description: entity.description,
      daysOfWeek: entity.daysOfWeek,
      category: entity.category,
      reminder: entity.reminder,
      time: entity.time,
      isCompleted: entity.isDone,
      dateCreation: entity.dateCreation,
      lastCompleted: null,
      streak: 0,
      totalCompletions: 0,
    );
  }

  /// Verifica si estamos en modo de depuración.
  bool get debugMode => !kReleaseMode;
}

/// Excepción para errores de repositorio.
class RepositoryException implements Exception {
  final String message;
  final Object? originalError;

  RepositoryException(this.message, {this.originalError});

  @override
  String toString() =>
      'RepositoryException: $message${originalError != null ? ' ($originalError)' : ''}';
}
