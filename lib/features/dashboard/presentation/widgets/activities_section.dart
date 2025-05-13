import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/unified_display_card.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../timeblocks/data/models/time_block_model.dart';
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

  // Función auxiliar para formatear DateTime a HH:mm
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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

    // Agregar actividades
    allItems.addAll(controller.activities);

    // Agregar hábitos
    allItems.addAll(controller.habits);

    // Agregar timeblocks independientes (evitando duplicados)
    final independentTimeBlocks = controller.timeBlocks.where((timeBlock) {
      return !habitTitles.contains(timeBlock.title) &&
          !activityTitles.contains(timeBlock.title);
    });
    allItems.addAll(independentTimeBlocks);

    debugPrint('Elementos en actividades (Unificado): ${allItems.length}');

    // Ordenar todos los elementos por hora
    allItems.sort((a, b) {
      final DateTime aTime = _getDateTimeFromItem(a);
      final DateTime bTime = _getDateTimeFromItem(b);
      return aTime.compareTo(bTime);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.dashboardActivitiesAndHabits,
            style: AppStyles.titleMedium.copyWith(
              color: context.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        allItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    l10n.dashboardNoItems,
                    style: TextStyle(
                      color: context.subtextColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return _buildItemWidget(item, context);
                },
              ),
      ],
    );
  }

  DateTime _getDateTimeFromItem(dynamic item) {
    if (item is ActivityModel) {
      return item.startTime;
    } else if (item is HabitModel) {
      final now = DateTime.now();
      final timeParts = item.time.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      return DateTime(now.year, now.month, now.day, hour, minute);
    } else if (item is TimeBlockModel) {
      return item.startTime;
    }
    return DateTime.now();
  }

  Widget _buildItemWidget(dynamic item, BuildContext context) {
    final theme = Theme.of(context);

    if (item is ActivityModel) {
      return UnifiedDisplayCard(
        key: ValueKey('activity_${item.id}'),
        title: item.title,
        description: item.description,
        category: item.category,
        timeRange:
            '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
        isFocusTime: item.priority == 'High',
        itemColor: theme.colorScheme.primary,
        isCompleted: item.isCompleted,
        onTap: () => onEditActivity(item),
        onEdit: () => onEditActivity(item),
        onDelete: () => onDeleteActivity(item),
        onToggleComplete: () => onToggleActivity(item),
      );
    } else if (item is HabitModel) {
      return UnifiedDisplayCard(
        key: ValueKey('habit_${item.id}'),
        title: item.title,
        prefix: "Hábito: ",
        description: item.description,
        category: item.category,
        timeRange: item.time,
        isFocusTime: true,
        itemColor: theme.colorScheme.secondary,
        isCompleted: item.isCompleted,
        onTap: () => onEditHabit(item),
        onDelete: () => onDeleteHabit(item),
        onToggleComplete: () => onToggleHabit(item),
      );
    } else if (item is TimeBlockModel) {
      return UnifiedDisplayCard(
        key: ValueKey('timeblock_${item.id}'),
        title: item.title,
        description: item.description,
        category: item.category,
        timeRange:
            '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
        isFocusTime: item.isFocusTime,
        itemColor: Color(int.parse(item.color.replaceAll('#', '0xFF'))),
        isCompleted: item.isCompleted,
        onTap: () {
          // Definir acción si se hace tap en un TimeBlock desde aquí,
          // por ejemplo, navegar a una pantalla de detalle/edición de TimeBlock.
          // Si no hay acción, se puede pasar null.
        },
      );
    }
    return const SizedBox.shrink();
  }
}
