import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../habits/data/models/habit_model.dart';

class DayOverviewSection extends StatelessWidget {
  final List<ActivityModel> morningActivities;
  final List<ActivityModel> afternoonActivities;
  final List<ActivityModel> eveningActivities;
  final List<HabitModel> morningHabits;
  final List<HabitModel> afternoonHabits;
  final List<HabitModel> eveningHabits;

  const DayOverviewSection({
    super.key,
    required this.morningActivities,
    required this.afternoonActivities,
    required this.eveningActivities,
    required this.morningHabits,
    required this.afternoonHabits,
    required this.eveningHabits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del día',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildPeriodSection(
          context: context,
          title: 'Mañana',
          timeRange: '5:00 AM - 11:59 AM',
          activities: morningActivities,
          habits: morningHabits,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(height: 12),
        _buildPeriodSection(
          context: context,
          title: 'Tarde',
          timeRange: '12:00 PM - 5:59 PM',
          activities: afternoonActivities,
          habits: afternoonHabits,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(height: 12),
        _buildPeriodSection(
          context: context,
          title: 'Noche',
          timeRange: '6:00 PM - 4:59 AM',
          activities: eveningActivities,
          habits: eveningHabits,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildPeriodSection({
    required BuildContext context,
    required String title,
    required String timeRange,
    required List<ActivityModel> activities,
    required List<HabitModel> habits,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final totalItems = activities.length + habits.length;
    final completedItems = activities.where((a) => a.isCompleted).length +
        habits.where((h) => h.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                timeRange,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$completedItems/$totalItems completados',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          if (totalItems > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalItems > 0 ? completedItems / totalItems : 0,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
