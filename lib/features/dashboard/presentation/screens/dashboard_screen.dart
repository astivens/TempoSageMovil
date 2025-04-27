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
    _controller.loadData();
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
    return Scaffold(
      backgroundColor: AppColors.base,
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
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.mic),
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
