import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    final totalCompleted = completedActivities + completedHabits;
    final totalTasks = totalActivities + totalHabits;
    final completionRate = totalTasks > 0 ? totalCompleted / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Tareas Completadas',
                  value: '$totalCompleted/$totalTasks',
                  subtitle: 'Progreso diario',
                  icon: Icon(Icons.check_circle, color: AppColors.green),
                  progress: completionRate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Tiempo Restante',
                  value:
                      '${remainingTime.inHours}h ${remainingTime.inMinutes % 60}m',
                  subtitle: 'Hasta el final del día',
                  icon: Icon(Icons.timer, color: AppColors.blue),
                  progress: 1 - (remainingTime.inMinutes / (24 * 60)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Tiempo Activo',
                  value:
                      '${totalActivityTime.inHours}h ${totalActivityTime.inMinutes % 60}m',
                  subtitle: 'Tiempo total en actividades',
                  icon: Icon(Icons.timer_outlined, color: AppColors.mauve),
                  progress: totalActivityTime.inMinutes / (8 * 60),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Enfoque Diario',
                  value: '${focusScore.toStringAsFixed(0)}%',
                  subtitle: 'Nivel de productividad',
                  icon: Icon(Icons.psychology, color: AppColors.yellow),
                  progress: focusScore / 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
