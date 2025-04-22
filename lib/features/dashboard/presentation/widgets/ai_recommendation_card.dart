import 'package:flutter/material.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';

class AIRecommendationCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final String actionText;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  const AIRecommendationCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.actionText,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 51), // 0.2 * 255 ≈ 51
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onApply,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            accentColor.withValues(alpha: 26), // 0.1 * 255 ≈ 26
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyles.titleSmall.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.text
                            .withValues(alpha: 153), // 0.6 * 255 ≈ 153
                        size: 20,
                      ),
                      onPressed: onDismiss,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.text
                        .withValues(alpha: 204), // 0.8 * 255 ≈ 204
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onApply,
                      style: TextButton.styleFrom(
                        foregroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionText,
                            style: AppStyles.bodySmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: accentColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
