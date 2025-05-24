import 'dart:async';
import '../../../../core/services/recommendation_service.dart';
import '../../data/models/habit_model.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/habit.dart';

class HabitRecommendationService {
  final RecommendationService _recommendationService;
  final HabitRepository _habitRepository;
  final Logger _logger = Logger.instance;

  HabitRecommendationService({
    required RecommendationService recommendationService,
    required HabitRepository habitRepository,
  })  : _recommendationService = recommendationService,
        _habitRepository = habitRepository;

  Future<List<HabitModel>> getHabitRecommendations() async {
    try {
      // Obtener el historial de hábitos del usuario
      final habits = await _habitRepository.getAllHabits();

      // Convertir hábitos a eventos de interacción
      final interactionEvents = habits
          .map((habit) => InteractionEvent(
                itemId: 'habit_${habit.category}',
                timestamp: habit.dateCreation.millisecondsSinceEpoch ~/ 1000,
                eventType: habit.isDone ? 'completed' : 'created',
                type: 'habit',
              ))
          .toList();

      // Obtener recomendaciones del modelo
      final recommendations = await _recommendationService.getRecommendations(
        interactionEvents: interactionEvents,
        type: 'habit',
      );

      // Lista de hábitos recomendados a devolver
      List<HabitModel> recommendedHabits = [];

      if (recommendations.isEmpty) {
        // Proporcionar recomendaciones predeterminadas si no hay ninguna
        return _getDefaultHabitRecommendations();
      }

      // Procesar cada recomendación, manejando diferentes tipos de respuesta
      for (var rec in recommendations) {
        try {
          if (rec is Map<String, dynamic>) {
            // Caso 1: La recomendación ya es un mapa
            recommendedHabits.add(_createHabitFromMap(rec));
          } else if (rec is String) {
            // Caso 2: La recomendación es una cadena (probablemente una categoría)
            recommendedHabits.add(_createHabitFromCategory(rec));
          } else {
            // Caso 3: Otro tipo no esperado
            _logger.w(
                'Formato de recomendación no reconocido: ${rec.runtimeType}',
                tag: 'HabitRecommendationService');
          }
        } catch (e) {
          _logger.e('Error al procesar recomendación individual',
              tag: 'HabitRecommendationService', error: e);
          // Continuamos con la siguiente recomendación
        }
      }

      // Si no se pudo procesar ninguna recomendación, devolver recomendaciones predeterminadas
      if (recommendedHabits.isEmpty) {
        return _getDefaultHabitRecommendations();
      }

      return recommendedHabits;
    } catch (e, stackTrace) {
      _logger.e('Error al obtener recomendaciones de hábitos',
          tag: 'HabitRecommendationService', error: e, stackTrace: stackTrace);

      // En caso de error, devolver recomendaciones predeterminadas
      return _getDefaultHabitRecommendations();
    }
  }

  // Método auxiliar para crear un hábito a partir de un mapa
  HabitModel _createHabitFromMap(Map<String, dynamic> recommendation) {
    return HabitModel.create(
      title: recommendation['title'] as String? ?? 'Hábito recomendado',
      description: recommendation['description'] as String? ??
          'Recomendación basada en tus hábitos existentes',
      daysOfWeek: recommendation['daysOfWeek'] is List
          ? List<String>.from(recommendation['daysOfWeek'] as List)
          : ['Lunes', 'Miércoles', 'Viernes'],
      category: recommendation['category'] as String? ?? 'General',
      reminder: recommendation['reminder'] as String? ?? 'Diaria',
      time: recommendation['time'] as String? ?? '08:00',
    );
  }

  // Método auxiliar para crear un hábito a partir de una categoría
  HabitModel _createHabitFromCategory(String category) {
    return HabitModel.create(
      title: 'Nuevo hábito de $category',
      description: 'Un hábito recomendado basado en tu historial',
      daysOfWeek: ['Lunes', 'Miércoles', 'Viernes'],
      category: category,
      reminder: 'Diaria',
      time: '08:00',
    );
  }

  // Método auxiliar para obtener recomendaciones predeterminadas
  List<HabitModel> _getDefaultHabitRecommendations() {
    return [
      HabitModel.create(
        title: 'Meditación matutina',
        description:
            'Dedica 10 minutos cada mañana a meditar para comenzar el día con calma',
        daysOfWeek: ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'],
        category: 'Bienestar',
        reminder: 'Diaria',
        time: '07:00',
      ),
      HabitModel.create(
        title: 'Ejercicio físico',
        description:
            'Realiza 30 minutos de actividad física para mantenerte saludable',
        daysOfWeek: ['Lunes', 'Miércoles', 'Viernes'],
        category: 'Salud',
        reminder: 'Diaria',
        time: '18:00',
      ),
      HabitModel.create(
        title: 'Lectura diaria',
        description: 'Lee al menos 20 páginas para mejorar tu conocimiento',
        daysOfWeek: [
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
          'Sábado',
          'Domingo'
        ],
        category: 'Desarrollo personal',
        reminder: 'Diaria',
        time: '21:00',
      ),
    ];
  }

  Future<void> suggestOptimalTime(HabitModel habitModel) async {
    try {
      // Convertir HabitModel a Habit para usar el repositorio
      final habit = Habit(
        id: habitModel.id,
        name: habitModel.title,
        description: habitModel.description,
        daysOfWeek: habitModel.daysOfWeek,
        category: habitModel.category,
        reminder: habitModel.reminder,
        time: habitModel.time,
        isDone: habitModel.isCompleted,
        dateCreation: habitModel.dateCreation,
      );

      // Obtener hábitos similares
      final habits = await _habitRepository.getAllHabits();
      final similarHabits = habits
          .where((h) =>
              h.category == habit.category &&
              h.daysOfWeek.any((day) => habit.daysOfWeek.contains(day)))
          .toList();

      if (similarHabits.isEmpty) return;

      // Analizar patrones de tiempo exitosos
      final successfulTimes =
          similarHabits.where((h) => h.isDone).map((h) => h.time).toList();

      if (successfulTimes.isEmpty) return;

      // Encontrar el tiempo más común
      final timeCounts = <String, int>{};
      for (final time in successfulTimes) {
        timeCounts[time] = (timeCounts[time] ?? 0) + 1;
      }

      final optimalTime =
          timeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      // Actualizar el hábito con el tiempo óptimo
      final updatedHabit = habit.copyWith(time: optimalTime);
      await _habitRepository.updateHabit(updatedHabit);
    } catch (e, stackTrace) {
      _logger.e('Error al sugerir tiempo óptimo para hábito',
          tag: 'HabitRecommendationService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
