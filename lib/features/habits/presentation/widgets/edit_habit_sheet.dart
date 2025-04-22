import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../data/models/habit_model.dart';

class EditHabitSheet extends StatelessWidget {
  final HabitModel habit;

  const EditHabitSheet({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Editar Hábito',
            style: AppStyles.titleMedium.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Aquí irían los campos de edición
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar guardado de cambios
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
