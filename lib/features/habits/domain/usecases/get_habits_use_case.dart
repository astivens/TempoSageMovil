import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Caso de uso para obtener hábitos según diferentes criterios.
///
/// Sigue el principio de responsabilidad única, encapsulando la lógica
/// de negocio relacionada con la obtención de hábitos.
class GetHabitsUseCase {
  final HabitRepository _repository;
  final Logger _logger = Logger.instance;

  GetHabitsUseCase(this._repository);

  /// Obtiene todos los hábitos disponibles.
  Future<List<Habit>> getAllHabits() async {
    try {
      _logger.d('Obteniendo todos los hábitos', tag: 'GetHabitsUseCase');
      return await _repository.getAllHabits();
    } catch (e, stackTrace) {
      _logger.e(
        'Error al obtener hábitos',
        tag: 'GetHabitsUseCase',
        error: e,
        stackTrace: stackTrace,
      );

      throw ServiceException(
        message: 'No se pudieron cargar los hábitos',
        originalError: e,
      );
    }
  }

  /// Obtiene los hábitos para un día específico de la semana.
  ///
  /// [dayOfWeek] debe ser una cadena que represente el día ('Lunes', 'Martes', etc.)
  Future<List<Habit>> getHabitsByDay(String dayOfWeek) async {
    try {
      _logger.d(
        'Obteniendo hábitos para el día: $dayOfWeek',
        tag: 'GetHabitsUseCase',
      );
      return await _repository.getHabitsByDayOfWeek(dayOfWeek);
    } catch (e, stackTrace) {
      _logger.e(
        'Error al obtener hábitos para el día: $dayOfWeek',
        tag: 'GetHabitsUseCase',
        error: e,
        stackTrace: stackTrace,
      );

      throw ServiceException(
        message: 'No se pudieron cargar los hábitos para $dayOfWeek',
        originalError: e,
      );
    }
  }

  /// Obtiene un hábito específico por su ID.
  Future<Habit> getHabitById(String id) async {
    try {
      _logger.d('Obteniendo hábito con ID: $id', tag: 'GetHabitsUseCase');
      return await _repository.getHabitById(id);
    } catch (e, stackTrace) {
      _logger.e(
        'Error al obtener hábito con ID: $id',
        tag: 'GetHabitsUseCase',
        error: e,
        stackTrace: stackTrace,
      );

      throw ServiceException(
        message: 'No se pudo encontrar el hábito',
        code: 'habit_not_found',
        originalError: e,
      );
    }
  }
}
