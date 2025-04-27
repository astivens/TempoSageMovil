import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../widgets/ai_recommendation_card.dart';
import '../../controllers/dashboard_controller.dart';

class AIRecommendations extends StatelessWidget {
  final DashboardController controller;
  final BuildContext parentContext;

  const AIRecommendations({
    super.key,
    required this.controller,
    required this.parentContext,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sugerencias Inteligentes',
                    style: AppStyles.titleMedium.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.text.withValues(alpha: 179),
                ),
                onPressed: controller.loadData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AIRecommendationCard(
            icon: Icons.psychology,
            accentColor: AppColors.mauve,
            title: 'Optimiza tu enfoque',
            description:
                'Tu productividad es mayor entre las 10:00 y 12:00. Programa tus tareas importantes en este horario.',
            actionText: 'Reorganizar tareas',
            onApply: () {
              final morningActivities = controller.activities.where((a) {
                final hour = a.startTime.hour;
                return hour >= 10 && hour < 12;
              }).toList();

              if (morningActivities.isEmpty) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                      content: Text('No hay tareas para reorganizar')),
                );
              } else {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                      content: Text('Tareas reorganizadas con éxito')),
                );
              }
            },
            onDismiss: () {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('Recomendación descartada')),
              );
            },
          ),
          const SizedBox(height: 12),
          AIRecommendationCard(
            icon: Icons.battery_charging_full,
            accentColor: AppColors.peach,
            title: 'Momento de descanso',
            description:
                'Has estado trabajando por 2 horas seguidas. Toma un descanso de 15 minutos.',
            actionText: 'Iniciar descanso',
            onApply: () {
              showDialog(
                context: parentContext,
                builder: (context) => AlertDialog(
                  title: const Text('Tiempo de descanso'),
                  content: const Text('Toma un descanso de 15 minutos'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
            onDismiss: () {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('Recomendación descartada')),
              );
            },
          ),
          const SizedBox(height: 12),
          AIRecommendationCard(
            icon: Icons.insights,
            accentColor: AppColors.green,
            title: 'Análisis de productividad',
            description:
                'Has completado más tareas que ayer a esta hora. ¡Mantén el ritmo!',
            actionText: 'Ver estadísticas',
            onApply: () {
              Navigator.pushNamed(parentContext, '/statistics');
            },
            onDismiss: () {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('Recomendación descartada')),
              );
            },
          ),
        ],
      ),
    );
  }
}
