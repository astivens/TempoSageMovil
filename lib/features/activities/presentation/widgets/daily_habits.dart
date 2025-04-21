import 'package:flutter/material.dart';
import 'package:temposage/core/constants/app_colors.dart';
import 'package:temposage/core/constants/app_styles.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';

class DailyHabits extends StatefulWidget {
  const DailyHabits({super.key});

  @override
  State<DailyHabits> createState() => _DailyHabitsState();
}

class _DailyHabitsState extends State<DailyHabits> {
  final _repository = ServiceLocator.instance.habitRepository;
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    try {
      final habits = await _repository.getHabitsForToday();
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleHabit(HabitModel habit) async {
    if (!habit.isCompleted) {
      await _repository.completeHabit(habit);
      _loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.mauve, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Hábitos de Hoy',
                  style: AppStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ..._habits.map((habit) => ListTile(
                dense: true,
                title: Text(
                  habit.title,
                  style: AppStyles.bodyMedium.copyWith(
                    color:
                        habit.isCompleted ? AppColors.overlay0 : Colors.white,
                    decoration:
                        habit.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                leading: Checkbox(
                  value: habit.isCompleted,
                  onChanged: (value) => _toggleHabit(habit),
                  activeColor: AppColors.mauve,
                ),
                trailing: Text(
                  habit.time.format(context),
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.overlay0,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
