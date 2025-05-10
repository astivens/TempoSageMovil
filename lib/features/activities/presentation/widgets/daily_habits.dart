import 'package:flutter/material.dart';
import 'package:temposage/core/constants/app_colors.dart';
import 'package:temposage/core/constants/app_styles.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/core/theme/theme_extensions.dart';
import 'package:temposage/core/utils/date_time_helper.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';

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
      final currentDay = DateTimeHelper.getDayOfWeek(DateTime.now());
      final habitEntities = await _repository.getHabitsByDayOfWeek(currentDay);

      setState(() {
        _habits = habitEntities.map(_mapEntityToModel).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleHabit(HabitModel habit) async {
    if (!habit.isCompleted) {
      // Convertir modelo a entidad
      final habitEntity = _mapModelToEntity(habit);
      // Actualizar estado
      final updatedHabit = habitEntity.copyWith(isDone: true);
      // Guardar en repositorio
      await _repository.updateHabit(updatedHabit);
      _loadHabits();
    }
  }

  // Métodos para convertir entre modelo y entidad
  HabitModel _mapEntityToModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      title: entity.name,
      description: entity.description,
      daysOfWeek: entity.daysOfWeek,
      category: entity.category,
      reminder: entity.reminder,
      time: entity.time,
      isCompleted: entity.isDone,
      dateCreation: entity.dateCreation,
    );
  }

  Habit _mapModelToEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.title,
      description: model.description,
      daysOfWeek: model.daysOfWeek,
      category: model.category,
      reminder: model.reminder,
      time: model.time,
      isDone: model.isCompleted,
      dateCreation: model.dateCreation,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_habits.isEmpty) {
      return Center(
        child: Text(
          'No hay hábitos para hoy',
          style: TextStyle(color: context.subtextColor),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];

        // Formatear hora (HH:MM)
        final timeComponents = _parseTimeString(habit.time);
        final formattedTime =
            '${timeComponents[0].toString().padLeft(2, '0')}:${timeComponents[1].toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: habit.isCompleted
                    ? context.isDarkMode
                        ? AppColors.mocha.green.withOpacity(0.5)
                        : AppColors.latte.green.withOpacity(0.5)
                    : context.surfaceColor,
                width: 1,
              ),
            ),
            tileColor: context.surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: habit.isCompleted,
              onChanged: (bool? value) => _toggleHabit(habit),
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return context.isDarkMode
                        ? AppColors.mocha.green
                        : AppColors.latte.green;
                  }
                  return context.subtextColor;
                },
              ),
            ),
            title: Text(
              habit.title,
              style: AppStyles.bodyLarge.copyWith(
                color: context.textColor,
                decoration: habit.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(
              formattedTime,
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.text,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                habit.category,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Parse time string to [hour, minute]
  List<int> _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return [hour, minute];
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return [0, 0]; // Valor por defecto
  }
}
