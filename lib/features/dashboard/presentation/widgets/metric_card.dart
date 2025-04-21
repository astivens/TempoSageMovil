import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Widget? icon;
  final double progress;
  final bool showProgress;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon,
    this.progress = 0.0,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.subtext0,
                  ),
                ),
                if (icon != null) icon!,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodySmall,
            ),
            if (showProgress) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surface1,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.mauve),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
