import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../data/models/time_block_model.dart';

class TimeBlockCard extends StatelessWidget {
  final TimeBlockModel timeBlock;
  final VoidCallback? onTap;

  const TimeBlockCard({
    super.key,
    required this.timeBlock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extraer el color de la cadena hexadecimal
    final Color blockColor = Color(
      int.parse(timeBlock.color.replaceAll('#', '0xFF')),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.mantle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: blockColor.withValues(alpha: 128),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: blockColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeBlock.title,
                            style: AppStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_formatTime(timeBlock.startTime)} - ${_formatTime(timeBlock.endTime)}',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.subtext0,
                    ),
                  ),
                ],
              ),
              if (timeBlock.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  timeBlock.description,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.subtext0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface0,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      timeBlock.category,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.subtext0,
                      ),
                    ),
                  ),
                  if (timeBlock.isFocusTime)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface0,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 14,
                            color: AppColors.mauve,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tiempo de enfoque',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.subtext0,
                            ),
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
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
