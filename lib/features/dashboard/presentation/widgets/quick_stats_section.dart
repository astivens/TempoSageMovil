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
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.text;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas rápidas',
            style: AppStyles.titleMedium.copyWith(
              color: textColor,
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
                  icon: Icons.task_alt,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Hábitos',
                  value: '$completedHabits/$totalHabits',
                  subtitle: 'completados',
                  icon: Icons.auto_awesome,
                  color: secondaryColor,
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
                  icon: Icons.timer,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Tiempo restante',
                  value: _formatDuration(remainingTime),
                  subtitle: 'del día',
                  icon: Icons.hourglass_empty,
                  color: Theme.of(context).colorScheme.secondary.withGreen(180),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MetricCard(
            title: 'Puntuación de enfoque',
            value: '${focusScore.toStringAsFixed(1)}%',
            subtitle: 'de productividad',
            icon: Icons.trending_up,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.mocha.green
                : AppColors.latte.green,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
