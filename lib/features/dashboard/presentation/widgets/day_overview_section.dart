import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del día',
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPeriodSection(
          title: 'Mañana',
          timeRange: '5:00 AM - 11:59 AM',
          activities: morningActivities,
          habits: morningHabits,
          color: AppColors.peach,
        ),
        const SizedBox(height: 12),
        _buildPeriodSection(
          title: 'Tarde',
          timeRange: '12:00 PM - 5:59 PM',
          activities: afternoonActivities,
          habits: afternoonHabits,
          color: AppColors.yellow,
        ),
        const SizedBox(height: 12),
        _buildPeriodSection(
          title: 'Noche',
          timeRange: '6:00 PM - 4:59 AM',
          activities: eveningActivities,
          habits: eveningHabits,
          color: AppColors.blue,
        ),
      ],
    );
  }

  Widget _buildPeriodSection({
    required String title,
    required String timeRange,
    required List<ActivityModel> activities,
    required List<HabitModel> habits,
    required Color color,
  }) {
    final totalItems = activities.length + habits.length;
    final completedItems = activities.where((a) => a.isCompleted).length +
        habits.where((h) => h.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surface2,
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
                    style: AppStyles.titleSmall.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                timeRange,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.text.withValues(alpha: 179),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$completedItems/$totalItems completados',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 179),
            ),
          ),
          if (totalItems > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalItems > 0 ? completedItems / totalItems : 0,
                backgroundColor: AppColors.surface2,
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
