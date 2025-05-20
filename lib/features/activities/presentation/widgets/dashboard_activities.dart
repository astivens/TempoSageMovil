import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../domain/entities/activity.dart';
import '../../data/models/activity_model.dart';
import 'activity_card.dart';

class DashboardActivities extends StatelessWidget {
  final List<Activity> activities;
  final Function(Activity) onToggleCompletion;
  final Function(Activity) onEdit;
  final Function(Activity) onDelete;
  final VoidCallback onViewAll;
  final VoidCallback onAddNew;

  const DashboardActivities({
    super.key,
    required this.activities,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
    required this.onViewAll,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Activities',
                style: AppStyles.titleMedium.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onAddNew,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (activities.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No activities for today',
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ActivityCard(
                activity: ActivityModel(
                  id: activity.id,
                  title: activity.name,
                  description: activity.description,
                  isCompleted: activity.isCompleted,
                  startTime: activity.date,
                  endTime: activity.date.add(const Duration(hours: 1)),
                  category: activity.category,
                  priority: 'Medium',
                ),
                onTap: () => onEdit(activity),
                onToggleComplete: () => onToggleCompletion(activity),
                onEdit: () => onEdit(activity),
                onDelete: () => onDelete(activity),
              );
            },
          ),
      ],
    );
  }
}
