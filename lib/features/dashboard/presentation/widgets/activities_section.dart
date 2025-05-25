import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/unified_display_card.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../controllers/dashboard_controller.dart';

class ActivitiesSection extends StatefulWidget {
  final DashboardController controller;
  final Function(ActivityModel) onEditActivity;
  final Function(ActivityModel) onDeleteActivity;
  final Function(ActivityModel) onToggleActivity;
  final Function(HabitModel) onEditHabit;
  final Function(HabitModel) onDeleteHabit;
  final Function(HabitModel) onToggleHabit;

  const ActivitiesSection({
    super.key,
    required this.controller,
    required this.onEditActivity,
    required this.onDeleteActivity,
    required this.onToggleActivity,
    required this.onEditHabit,
    required this.onDeleteHabit,
    required this.onToggleHabit,
  });

  @override
  State<ActivitiesSection> createState() => _ActivitiesSectionState();
}

class _ActivitiesSectionState extends State<ActivitiesSection>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  // Función auxiliar para formatear DateTime a HH:mm
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.controller.isLoading) {
      return Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando actividades...',
              style: TextStyle(
                color: context.subtextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Separar actividades y hábitos
    final activities = widget.controller.activities;
    final habits = widget.controller.habits;

    debugPrint('=== ACTIVITIES SECTION DEBUG ===');
    debugPrint('Actividades: ${activities.length}');
    debugPrint('Hábitos: ${habits.length}');

    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(0, _headerSlideAnimation.value),
              child: Opacity(
                opacity: _headerFadeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.textColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.view_agenda,
                        color: context.textColor.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.dashboardActivitiesAndHabits,
                          style: AppStyles.titleMedium.copyWith(
                            color: context.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildSummaryChip(activities.length + habits.length),
                    ],
                  ),
                ),
              ),
            ),

            // Mostrar actividades si las hay
            if (activities.isNotEmpty) ...[
              _buildAnimatedSectionHeader(context, l10n.activities,
                  Icons.task_alt, activities.length, 0),
              ...activities.asMap().entries.map((entry) =>
                  _buildAnimatedActivityWidget(
                      entry.value, context, entry.key)),
              const SizedBox(height: 12),
            ],

            // Mostrar hábitos si los hay
            if (habits.isNotEmpty) ...[
              _buildAnimatedSectionHeader(context, l10n.habits,
                  Icons.auto_awesome, habits.length, activities.length),
              ...habits.asMap().entries.map((entry) =>
                  _buildAnimatedHabitWidget(
                      entry.value, context, activities.length + entry.key)),
              const SizedBox(height: 12),
            ],

            // Mensaje si no hay elementos
            if (activities.isEmpty && habits.isEmpty)
              _buildEmptyState(context, l10n),
          ],
        );
      },
    );
  }

  Widget _buildSummaryChip(int totalItems) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$totalItems',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnimatedSectionHeader(
      BuildContext context, String title, IconData icon, int count, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (delay * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: context.textColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$title ($count)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.textColor.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedActivityWidget(
      ActivityModel activity, BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: _buildActivityWidget(activity, context),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHabitWidget(
      HabitModel habit, BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: _buildHabitWidget(habit, context),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.subtextColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.event_note,
                        size: 48,
                        color: context.subtextColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dashboardNoItems,
                      style: TextStyle(
                        color: context.subtextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usa el botón + para agregar nuevos elementos',
                      style: TextStyle(
                        color: context.subtextColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityWidget(ActivityModel activity, BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: UnifiedDisplayCard(
        key: ValueKey('activity_${activity.id}'),
        title: activity.title,
        description: activity.description,
        category: activity.category,
        timeRange:
            '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}',
        isFocusTime: activity.priority == 'High',
        itemColor: theme.colorScheme.primary,
        isCompleted: activity.isCompleted,
        onTap: () => widget.onEditActivity(activity),
        onEdit: () => widget.onEditActivity(activity),
        onDelete: () => widget.onDeleteActivity(activity),
        onToggleComplete: () => widget.onToggleActivity(activity),
      ),
    );
  }

  Widget _buildHabitWidget(HabitModel habit, BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: UnifiedDisplayCard(
        key: ValueKey('habit_${habit.id}'),
        title: habit.title,
        prefix: "Hábito: ",
        description: habit.description,
        category: habit.category,
        timeRange: habit.time,
        isFocusTime: true,
        itemColor: theme.colorScheme.secondary,
        isCompleted: habit.isCompleted,
        onTap: () => widget.onEditHabit(habit),
        onDelete: () => widget.onDeleteHabit(habit),
        onToggleComplete: () => widget.onToggleHabit(habit),
      ),
    );
  }
}
