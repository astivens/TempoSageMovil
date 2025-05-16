import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../activities/presentation/screens/edit_activity_screen.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../habits/presentation/widgets/edit_habit_sheet.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/day_overview_section.dart';
import '../widgets/ai_assistant_sheet.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/activities_section.dart';
import '../widgets/ai_recommendations.dart';
import '../widgets/activity_recommendations_section.dart';
import '../../../../core/services/voice_command_service.dart';
import '../../domain/voice_command_handler.dart';
import '../../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final VoiceCommandHandler _voiceCommandHandler;
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<DashboardController>(context, listen: false);
    _voiceCommandHandler = VoiceCommandHandler(
      context: context,
      controller: _controller,
    );

    // Cargar los datos básicos de la aplicación
    _controller.loadData().then((_) {
      // Realizamos las llamadas a la API en segundo plano para no bloquear la UI
      _loadAIRecommendations();
    });
  }

  // Método para cargar las recomendaciones de la IA en segundo plano
  Future<void> _loadAIRecommendations() async {
    try {
      // Si no hay actividades, no tiene sentido hacer llamadas a la API
      if (_controller.activities.isEmpty) {
        debugPrint('No hay actividades para generar recomendaciones.');
        return;
      }

      // Cargamos las predicciones de productividad
      await _controller.predictProductivity();

      // Si hay actividades, intentamos obtener sugerencias de horarios
      final categories =
          _controller.activities.map((a) => a.category).toSet().toList();

      if (categories.isNotEmpty) {
        await _controller.suggestOptimalTimes(
          activityCategory: categories.first,
        );
      }

      // Analizamos patrones de actividades solo si hay suficientes
      if (_controller.activities.length >= 3) {
        await _controller.analyzePatterns();
      } else {
        debugPrint(
            'Insuficientes actividades para análisis de patrones (${_controller.activities.length})');
      }
    } catch (e) {
      // Solo registramos el error, no interrumpimos la experiencia del usuario
      debugPrint('Error al cargar recomendaciones de IA: $e');
    } finally {
      // Forzar una reconstrucción para asegurarnos de que la UI se actualice
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _handleVoiceCommand(VoiceCommand command) async {
    await _voiceCommandHandler.handleCommand(command);
  }

  void _showAIAssistant() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => AIAssistantSheet(
        onCommandRecognized: _handleVoiceCommand,
      ),
    );
  }

  void _showEditActivityModal(ActivityModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditActivityScreen(
          activity: activity,
        ),
      ),
    ).then((_) => _controller.loadData());
  }

  void _showEditHabitModal(HabitModel habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => EditHabitSheet(habit: habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<DashboardController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                const DashboardAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildQuickStats(controller),
                        const SizedBox(height: 24),
                        _buildDayOverview(controller),
                        const SizedBox(height: 24),
                        ActivitiesSection(
                          controller: controller,
                          onEditActivity: _showEditActivityModal,
                          onDeleteActivity: (activity) =>
                              controller.deleteActivity(activity.id),
                          onToggleActivity: (activity) =>
                              controller.toggleActivityCompletion(activity.id),
                          onEditHabit: _showEditHabitModal,
                          onDeleteHabit: (habit) =>
                              controller.deleteHabit(habit),
                          onToggleHabit: (habit) =>
                              controller.toggleHabitCompletion(habit),
                        ),
                        const SizedBox(height: 24),
                        AIRecommendations(
                          controller: controller,
                          parentContext: context,
                        ),
                        const SizedBox(height: 24),
                        ActivityRecommendationsSection(
                          parentContext: context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAIAssistant,
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.mic, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildQuickStats(DashboardController controller) {
    final completedActivities =
        controller.activities.where((a) => a.isCompleted).length;
    final completedHabits =
        controller.habits.where((h) => h.isCompleted).length;
    final totalActivities = controller.activities.length;
    final totalHabits = controller.habits.length;

    final totalActivityTime = controller.activities.fold<Duration>(
      Duration.zero,
      (sum, activity) => sum + activity.endTime.difference(activity.startTime),
    );

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final remainingTime = endOfDay.difference(now);

    final focusScore = (totalActivities + totalHabits) > 0
        ? ((completedActivities + completedHabits) /
                (totalActivities + totalHabits)) *
            100
        : 0.0;

    return QuickStatsSection(
      completedActivities: completedActivities,
      completedHabits: completedHabits,
      totalActivities: totalActivities,
      totalHabits: totalHabits,
      totalActivityTime: totalActivityTime,
      remainingTime: remainingTime,
      focusScore: focusScore,
    );
  }

  Widget _buildDayOverview(DashboardController controller) {
    final now = DateTime.now();
    final hour = now.hour;

    return DayOverviewSection(
      morningActivities: controller.getMorningActivities(),
      afternoonActivities: controller.getAfternoonActivities(),
      eveningActivities: controller.getEveningActivities(),
      morningHabits: hour >= 6 && hour < 12 ? controller.habits : [],
      afternoonHabits: hour >= 12 && hour < 18 ? controller.habits : [],
      eveningHabits: hour >= 18 || hour < 6 ? controller.habits : [],
    );
  }
}
