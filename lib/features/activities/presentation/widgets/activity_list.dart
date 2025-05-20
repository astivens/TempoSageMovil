import 'package:flutter/material.dart';
import '../../../../core/widgets/mobile_animated_list.dart';
import '../../domain/entities/activity.dart';
import '../../data/models/activity_model.dart';
import 'activity_card.dart';

class ActivityList extends StatelessWidget {
  final List<Activity> activities;
  final Function(Activity) onDelete;
  final Function(Activity) onToggleCompletion;
  final Function(Activity) onEdit;

  const ActivityList({
    super.key,
    required this.activities,
    required this.onDelete,
    required this.onToggleCompletion,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No activities yet. Add some!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MobileAnimatedList(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      onRemove: (index) => onDelete(activities[index]),
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        return ActivityCard(
          key: ValueKey(activity.id),
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
          index: index,
          onTap: () => onEdit(activity),
          onToggleComplete: () => onToggleCompletion(activity),
          onEdit: () => onEdit(activity),
          onDelete: () => onDelete(activity),
        );
      }).toList(),
    );
  }
}
