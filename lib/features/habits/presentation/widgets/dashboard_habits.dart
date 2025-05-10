import 'package:flutter/material.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/models/habit_model.dart';
import 'habit_card.dart';

class DashboardHabits extends StatelessWidget {
  final List<HabitModel> habits;
  final Function(HabitModel) onComplete;
  final Function(HabitModel) onDelete;
  final VoidCallback onViewAll;
  final VoidCallback onAddNew;

  const DashboardHabits({
    super.key,
    required this.habits,
    required this.onComplete,
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
                'Hábitos de Hoy',
                style: AppStyles.titleMedium.copyWith(
                  color: context.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'Ver Todos',
                      style: TextStyle(color: context.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add, color: context.primaryColor),
                    onPressed: onAddNew,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (habits.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No hay hábitos para hoy',
                style: TextStyle(
                  fontSize: 16,
                  color: context.subtextColor,
                ),
              ),
            ),
          )
        else
          Container(
            color: context.backgroundColor,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitCard(
                  habit: habit,
                  onComplete: () => onComplete(habit),
                  onDelete: () => onDelete(habit),
                );
              },
            ),
          ),
      ],
    );
  }
}
