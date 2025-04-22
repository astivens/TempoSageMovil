import 'package:flutter/material.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';
import 'time_block_card.dart';

class DayOverviewSection extends StatelessWidget {
  final List<dynamic> morningActivities;
  final List<dynamic> afternoonActivities;
  final List<dynamic> eveningActivities;
  final List<dynamic> morningHabits;
  final List<dynamic> afternoonHabits;
  final List<dynamic> eveningHabits;

  const DayOverviewSection({
    super.key,
    required this.morningActivities,
    required this.afternoonActivities,
    required this.eveningActivities,
    required this.morningHabits,
    required this.afternoonHabits,
    required this.eveningHabits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Día',
            style: AppStyles.titleMedium.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TimeBlockCard(
                  title: 'Mañana',
                  time: '6:00 - 12:00',
                  tasks: morningActivities.length + morningHabits.length,
                  completed:
                      morningActivities.where((a) => a.isCompleted).length +
                          morningHabits.where((h) => h.isCompleted).length,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TimeBlockCard(
                  title: 'Tarde',
                  time: '12:00 - 18:00',
                  tasks: afternoonActivities.length + afternoonHabits.length,
                  completed:
                      afternoonActivities.where((a) => a.isCompleted).length +
                          afternoonHabits.where((h) => h.isCompleted).length,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TimeBlockCard(
            title: 'Noche',
            time: '18:00 - 6:00',
            tasks: eveningActivities.length + eveningHabits.length,
            completed: eveningActivities.where((a) => a.isCompleted).length +
                eveningHabits.where((h) => h.isCompleted).length,
            color: AppColors.peach,
          ),
        ],
      ),
    );
  }
}
