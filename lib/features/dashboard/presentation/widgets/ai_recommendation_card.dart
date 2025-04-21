import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';

class AIRecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onApply;
  final VoidCallback onDismiss;
  final IconData icon;

  const AIRecommendationCard({
    super.key,
    required this.title,
    required this.description,
    required this.onApply,
    required this.onDismiss,
    required this.icon,
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
              children: [
                Icon(
                  icon,
                  color: AppColors.mauve,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.overlay0,
                  ),
                  child: const Text('Descartar'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onApply,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mauve,
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
