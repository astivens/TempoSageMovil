import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../../../core/widgets/hover_scale.dart';
import '../../data/models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;
  final bool isHabit;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.index = 0,
    this.isHabit = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      index: index,
      child: HoverScale(
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onEdit(),
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
              ),
              SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface0,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.surface2,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildCheckbox(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: AppStyles.titleSmall.copyWith(
                                  color: AppColors.text,
                                  decoration: activity.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (isHabit)
                              const Icon(
                                Icons.repeat,
                                color: AppColors.mauve,
                                size: 20,
                              ),
                          ],
                        ),
                        if (activity.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            activity.description,
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.subtext0,
                              decoration: activity.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return InkWell(
      onTap: onToggleComplete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: activity.isCompleted ? AppColors.green : Colors.transparent,
          border: Border.all(
            color: activity.isCompleted ? AppColors.green : AppColors.overlay0,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: activity.isCompleted
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        activity.category,
        style: AppStyles.bodySmall.copyWith(
          color: AppColors.subtext0,
        ),
      ),
    );
  }
}
