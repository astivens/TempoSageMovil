import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.text;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activityQuickStats,
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
                    title: l10n.calendarActivities,
                    value: '$completedActivities/$totalActivities',
                    subtitle: l10n.activityCompleted,
                    icon: Icons.task_alt,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MetricCard(
                    title: l10n.calendarActivities,
                    value: '$completedHabits/$totalHabits',
                    subtitle: l10n.habitsCompleted,
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
                    title: l10n.dashboardTotalTime,
                    value: _formatDuration(totalActivityTime),
                    subtitle: l10n.dashboardTotalTimeSubtitle,
                    icon: Icons.timer,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MetricCard(
                    title: l10n.dashboardRemainingTime,
                    value: _formatDuration(remainingTime),
                    subtitle: l10n.dashboardRemainingTimeSubtitle,
                    icon: Icons.hourglass_empty,
                    color:
                        Theme.of(context).colorScheme.secondary.withGreen(180),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: l10n.dashboardFocusScore,
              value: '${focusScore.toStringAsFixed(1)}%',
              subtitle: l10n.dashboardFocusScoreSubtitle,
              icon: Icons.trending_up,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.mocha.green
                  : AppColors.latte.green,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
