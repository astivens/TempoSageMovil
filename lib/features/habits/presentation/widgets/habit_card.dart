import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../data/models/habit_model.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface1,
      child: ListTile(
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (_) => onComplete(),
        ),
        title: Text(
          habit.title,
          style: AppStyles.titleSmall.copyWith(
            color: AppColors.text,
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          habit.description,
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.text.withValues(alpha: 179),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
