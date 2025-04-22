import 'package:flutter/material.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';

class TimeBlockCard extends StatelessWidget {
  final String title;
  final String time;
  final int tasks;
  final int completed;
  final Color color;

  const TimeBlockCard({
    super.key,
    required this.title,
    required this.time,
    required this.tasks,
    required this.completed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = tasks > 0 ? completed / tasks : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 51), // 0.2 * 255 ≈ 51
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 153), // 0.6 * 255 ≈ 153
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '$completed/$tasks tareas completadas',
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.text.withValues(alpha: 204), // 0.8 * 255 ≈ 204
            ),
          ),
        ],
      ),
    );
  }
}
