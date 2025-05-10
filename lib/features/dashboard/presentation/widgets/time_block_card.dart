import 'package:flutter/material.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';

class TimeBlockCard extends StatefulWidget {
  final String title;
  final String timeRange;
  final IconData icon;
  final Color? color;
  final String? description;
  final bool isCompleted;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TimeBlockCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.icon,
    this.color,
    this.description,
    this.isCompleted = false,
    this.isLoading = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<TimeBlockCard> createState() => _TimeBlockCardState();
}

class _TimeBlockCardState extends State<TimeBlockCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.mocha.surface0
                  : AppColors.latte.surface0,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.color ?? primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: AppStyles.titleSmall.copyWith(
                                color: widget.color ?? primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.timeRange,
                              style: AppStyles.bodyMedium.copyWith(
                                color: isDarkMode
                                    ? AppColors.mocha.subtext1
                                    : AppColors.latte.subtext1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: isDarkMode
                              ? AppColors.mocha.green
                              : AppColors.latte.green,
                          size: 24,
                        ),
                    ],
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.description!,
                      style: AppStyles.bodySmall.copyWith(
                        color: isDarkMode
                            ? AppColors.mocha.subtext1
                            : AppColors.latte.subtext1,
                      ),
                    ),
                  ],
                  if (widget.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
