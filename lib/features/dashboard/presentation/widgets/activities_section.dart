import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/presentation/widgets/activity_card.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../habits/presentation/widgets/habit_card.dart';
import '../../../timeblocks/data/models/time_block_model.dart';
import '../../../timeblocks/presentation/widgets/time_block_card.dart';
import '../../controllers/dashboard_controller.dart';

class ActivitiesSection extends StatelessWidget {
  final DashboardController controller;
  final Function(ActivityModel) onEditActivity;
  final Function(ActivityModel) onDeleteActivity;
  final Function(ActivityModel) onToggleActivity;
  final Function(HabitModel) onEditHabit;
  final Function(HabitModel) onDeleteHabit;
  final Function(HabitModel) onToggleHabit;

  const ActivitiesSection({
    super.key,
    required this.controller,
    required this.onEditActivity,
    required this.onDeleteActivity,
    required this.onToggleActivity,
    required this.onEditHabit,
    required this.onDeleteHabit,
    required this.onToggleHabit,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Crear una lista combinada evitando duplicaciones - OPTIMIZADA
    final List<dynamic> allItems = [];

    // Preparar conjuntos para verificaciones rápidas
    final habitTitles = controller.habits.map((h) => h.title).toSet();
    final activityTitles = controller.activities.map((a) => a.title).toSet();

    // Agregar actividades que no son hábitos
    allItems.addAll(controller.activities);

    // Agregar hábitos
    allItems.addAll(controller.habits);

    // Agregar timeblocks independientes (evitando duplicados)
    final independentTimeBlocks = controller.timeBlocks.where((timeBlock) {
      return !habitTitles.contains(timeBlock.title) &&
          !activityTitles.contains(timeBlock.title);
    });
    allItems.addAll(independentTimeBlocks);

    debugPrint('Elementos en actividades: ${allItems.length}');

    // Ordenar todos los elementos por hora (ya vienen ordenados de DashboardController)
    allItems.sort((a, b) {
      final DateTime aTime = _getDateTimeFromItem(a);
      final DateTime bTime = _getDateTimeFromItem(b);
      return aTime.compareTo(bTime);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividades y hábitos',
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(12),
          ),
          child: allItems.isEmpty
              ? const Center(
                  child: Text(
                    'No hay elementos para hoy',
                    style: TextStyle(
                      color: AppColors.subtext0,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    return _buildItemWidget(item, context);
                  },
                ),
        ),
      ],
    );
  }

  // Método auxiliar para obtener DateTime de cualquier tipo de elemento
  DateTime _getDateTimeFromItem(dynamic item) {
    if (item is ActivityModel) {
      return item.startTime;
    } else if (item is HabitModel) {
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        item.time.hour,
        item.time.minute,
      );
    } else if (item is TimeBlockModel) {
      return item.startTime;
    }
    return DateTime.now(); // fallback
  }

  // Método para construir el widget apropiado según el tipo de elemento
  Widget _buildItemWidget(dynamic item, BuildContext context) {
    if (item is ActivityModel) {
      return ActivityCard(
        activity: item,
        onTap: () => onEditActivity(item),
        onToggleComplete: () => onToggleActivity(item),
        onEdit: () => onEditActivity(item),
        onDelete: () => onDeleteActivity(item),
      );
    } else if (item is HabitModel) {
      return HabitCard(
        habit: item,
        onComplete: () => onToggleHabit(item),
        onDelete: () => onDeleteHabit(item),
      );
    } else if (item is TimeBlockModel) {
      return TimeBlockCard(
        timeBlock: item,
        onTap: () {}, // Implementar acción de edición si es necesario
      );
    }
    return const SizedBox.shrink();
  }
}
