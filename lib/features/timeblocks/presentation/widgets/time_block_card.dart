import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart'; // Eliminado
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
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
                              color: theme.colorScheme.onSurface,
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
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (timeBlock.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    timeBlock.description,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildChip(
                        context,
                        timeBlock.category,
                        theme.colorScheme.secondaryContainer,
                        theme.colorScheme.onSecondaryContainer),
                    if (timeBlock.isFocusTime)
                      _buildChip(
                        context,
                        'Tiempo de enfoque',
                        theme.colorScheme.tertiaryContainer,
                        theme.colorScheme.onTertiaryContainer,
                        icon: Icons.timer_outlined,
                        iconColor: theme.colorScheme.onTertiaryContainer,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color backgroundColor,
      Color textColor,
      {IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: iconColor ?? textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
