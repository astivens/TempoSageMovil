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

      // Convertir recomendaciones a hábitos sugeridos
      return recommendations.map((rec) {
        final Map<String, dynamic> recommendation = rec as Map<String, dynamic>;
        return HabitModel.create(
          title: recommendation['title'] as String,
          description: recommendation['description'] as String,
          daysOfWeek: List<String>.from(recommendation['daysOfWeek'] as List),
          category: recommendation['category'] as String,
          reminder: recommendation['reminder'] as String,
          time: recommendation['time'] as String,
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error al obtener recomendaciones de hábitos',
          tag: 'HabitRecommendationService', error: e, stackTrace: stackTrace);
      rethrow;
    }
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
