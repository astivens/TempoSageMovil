import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.base,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Hoy',
            style: AppStyles.titleLarge.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('EEEE, d MMMM', 'es').format(DateTime.now()),
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.text.withValues(alpha: 179),
            ),
          ),
        ],
      ),
    );
  }
}
