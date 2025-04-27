import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import 'metric_card.dart';

class QuickStatsSection extends StatelessWidget {
  final int completedActivities;
  final int completedHabits;
  final int totalActivities;
  final int totalHabits;
  final Duration totalActivityTime;
  final Duration remainingTime;
  final double focusScore;

  const QuickStatsSection({
    super.key,
    required this.completedActivities,
    required this.completedHabits,
    required this.totalActivities,
    required this.totalHabits,
    required this.totalActivityTime,
    required this.remainingTime,
    required this.focusScore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas rápidas',
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Actividades',
                value: '$completedActivities/$totalActivities',
                subtitle: 'completadas',
                icon: const Icon(Icons.task_alt, color: AppColors.blue),
                progress: totalActivities > 0
                    ? completedActivities / totalActivities
                    : 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Hábitos',
                value: '$completedHabits/$totalHabits',
                subtitle: 'completados',
                icon: const Icon(Icons.auto_awesome, color: AppColors.mauve),
                progress: totalHabits > 0 ? completedHabits / totalHabits : 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Tiempo total',
                value: _formatDuration(totalActivityTime),
                subtitle: 'de actividades',
                icon: const Icon(Icons.timer, color: AppColors.peach),
                showProgress: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Tiempo restante',
                value: _formatDuration(remainingTime),
                subtitle: 'del día',
                icon:
                    const Icon(Icons.hourglass_empty, color: AppColors.yellow),
                showProgress: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Puntuación de enfoque',
          value: '${focusScore.toStringAsFixed(1)}%',
          subtitle: 'de productividad',
          icon: const Icon(Icons.trending_up, color: AppColors.green),
          progress: focusScore / 100,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
