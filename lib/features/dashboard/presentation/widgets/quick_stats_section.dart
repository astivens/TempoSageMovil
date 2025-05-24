import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import 'metric_card.dart';

class QuickStatsSection extends StatefulWidget {
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
  State<QuickStatsSection> createState() => _QuickStatsSectionState();
}

class _QuickStatsSectionState extends State<QuickStatsSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.text;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor.withOpacity(0.95),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.activityQuickStats,
                              style: AppStyles.titleMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildProgressIndicator(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: l10n.activities,
                              value:
                                  '${widget.completedActivities}/${widget.totalActivities}',
                              subtitle: l10n.activityCompleted,
                              icon: Icons.task_alt,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: l10n.habits,
                              value:
                                  '${widget.completedHabits}/${widget.totalHabits}',
                              subtitle: l10n.habitsCompleted,
                              icon: Icons.auto_awesome,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: l10n.dashboardTotalTimeShort,
                              value: _formatDuration(widget.totalActivityTime),
                              subtitle: l10n.dashboardTotalTimeSubtitle,
                              icon: Icons.timer,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: l10n.dashboardRemainingTimeShort,
                              value: _formatDuration(widget.remainingTime),
                              subtitle: l10n.dashboardRemainingTimeSubtitle,
                              icon: Icons.hourglass_empty,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withGreen(180),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MetricCard(
                        title: l10n.dashboardFocusScoreShort,
                        value: '${widget.focusScore.toStringAsFixed(1)}%',
                        subtitle: l10n.dashboardFocusScoreSubtitle,
                        icon: Icons.trending_up,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.mocha.green
                            : AppColors.latte.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    final totalTasks = widget.totalActivities + widget.totalHabits;
    final completedTasks = widget.completedActivities + widget.completedHabits;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 0.8
                  ? Colors.green
                  : progress >= 0.5
                      ? Colors.orange
                      : Theme.of(context).colorScheme.primary,
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
