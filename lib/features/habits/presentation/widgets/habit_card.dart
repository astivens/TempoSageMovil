import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (_) => onComplete(),
        ),
        title: Text(
          habit.title,
          style: theme.textTheme.titleSmall?.copyWith(
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          habit.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
