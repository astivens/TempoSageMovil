import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../../../core/widgets/hover_scale.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/time_block_model.dart';

class TimeBlockTimeline extends StatefulWidget {
  final List<TimeBlockModel> timeBlocks;
  final Function(TimeBlockModel) onTimeBlockTap;
  final Function(TimeBlockModel) onTimeBlockDelete;

  const TimeBlockTimeline({
    super.key,
    required this.timeBlocks,
    required this.onTimeBlockTap,
    required this.onTimeBlockDelete,
  });

  @override
  State<TimeBlockTimeline> createState() => _TimeBlockTimelineState();
}

class _TimeBlockTimelineState extends State<TimeBlockTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _timelineAnimation;
  final _timeFormat = DateFormat('HH:mm');
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _timelineAnimation = AppAnimations.fadeIn(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _timelineAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _timelineAnimation.value,
          child: child,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.timeBlocks.length,
        itemBuilder: (context, index) {
          final timeBlock = widget.timeBlocks[index];
          return AnimatedListItem(
            index: index,
            child: HoverScale(
              child: _buildTimeBlockCard(timeBlock, theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeBlockCard(TimeBlockModel timeBlock, ThemeData theme) {
    final now = DateTime.now();
    final isCurrent =
        timeBlock.startTime.isBefore(now) && timeBlock.endTime.isAfter(now);
    final isPast = timeBlock.endTime.isBefore(now);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeIndicator(timeBlock, isCurrent, isPast, theme),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBlockContent(timeBlock, isCurrent, isPast, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator(
      TimeBlockModel timeBlock, bool isCurrent, bool isPast, ThemeData theme) {
    return Column(
      children: [
        Text(
          _timeFormat.format(timeBlock.startTime),
          style: TextStyle(
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.onBackground.withOpacity(0.6),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 2,
          height: 40,
          color: isCurrent
              ? theme.colorScheme.primary
              : isPast
                  ? theme.colorScheme.onBackground.withOpacity(0.3)
                  : theme.colorScheme.onBackground.withOpacity(0.6),
        ),
        const SizedBox(height: 4),
        Text(
          _timeFormat.format(timeBlock.endTime),
          style: TextStyle(
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.onBackground.withOpacity(0.6),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockContent(
      TimeBlockModel timeBlock, bool isCurrent, bool isPast, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    String getUserDescription(String description) {
      final lines = description.split('\n');
      final filtered = lines.where((line) =>
          !line.contains('[ACTIVITY_GENERATED]') &&
          !line.trim().startsWith('ID:'));
      return filtered.join('\n').trim();
    }

    return GestureDetector(
      onTap: () => widget.onTimeBlockTap(timeBlock),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isCurrent
              ? _getBlockColor(timeBlock, theme).withOpacity(0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? _getBlockColor(timeBlock, theme)
                : _getBlockColor(timeBlock, theme).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: _getBlockColor(timeBlock, theme).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      timeBlock.title,
                      style: TextStyle(
                        color: isCurrent
                            ? _getBlockColor(timeBlock, theme)
                            : theme.colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: theme.colorScheme.primary,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.timeBlockInProgress,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                getUserDescription(timeBlock.description),
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: _getBlockColor(timeBlock, theme),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeBlock.category,
                        style: TextStyle(
                          color: _getBlockColor(timeBlock, theme),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBlockColor(TimeBlockModel block, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    try {
      if (block.isFocusTime) {
        return theme.colorScheme.secondary;
      }

      switch (block.category.toLowerCase()) {
        case 'work':
          return theme.colorScheme.primary;
        case 'study':
          return isDarkMode ? AppColors.mocha.green : AppColors.latte.green;
        case 'personal':
          return theme.colorScheme.secondary;
        case 'lunch':
        case 'break':
          return isDarkMode ? AppColors.mocha.peach : AppColors.latte.peach;
        case 'meeting':
          return isDarkMode ? AppColors.mocha.yellow : AppColors.latte.yellow;
        default:
          return theme.colorScheme.primary;
      }
    } catch (e) {
      return theme.colorScheme.surface;
    }
  }
}

class TimelineLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  TimelineLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * progress);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TimelineLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
