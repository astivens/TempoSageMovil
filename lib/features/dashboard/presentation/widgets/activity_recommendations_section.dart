import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controllers/activity_recommendation_controller.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../presentation/pages/task_recommendation_page.dart';

class ActivityRecommendationsSection extends StatefulWidget {
  final BuildContext parentContext;

  const ActivityRecommendationsSection({
    super.key,
    required this.parentContext,
  });

  @override
  State<ActivityRecommendationsSection> createState() =>
      _ActivityRecommendationsSectionState();
}

class _ActivityRecommendationsSectionState
    extends State<ActivityRecommendationsSection> {
  late final ActivityRecommendationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActivityRecommendationController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      if (mounted) {
        await _controller.loadRecommendations();
      }
    } catch (e) {
      debugPrint('Error al inicializar el controlador de recomendaciones: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.mocha.surface0 : AppColors.latte.surface0,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: isDarkMode ? AppColors.mocha.green : AppColors.latte.green,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gestión Inteligente de Tareas',
              style: AppStyles.titleMedium.copyWith(
                color: isDarkMode ? AppColors.mocha.text : AppColors.latte.text,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aprovecha la inteligencia artificial para organizar tus tareas de manera óptima y mejorar tu productividad.',
          style: AppStyles.bodyMedium.copyWith(
            color: isDarkMode
                ? AppColors.mocha.text.withOpacity(0.8)
                : AppColors.latte.text.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.category,
          title: 'Categorización de Tareas',
          description:
              'Clasifica automáticamente tus tareas y estima su duración',
          color: colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context: context,
          icon: Icons.schedule,
          title: 'Sugerencia de Horarios',
          description:
              'Encuentra los mejores momentos para realizar cada tipo de tarea',
          color: colorScheme.secondary,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskRecommendationPage(),
                ),
              );
            },
            icon: Icon(
              Icons.add_task,
              color: colorScheme.onPrimary,
            ),
            label: const Text('Crear Tarea Inteligente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.mocha.crust
            : AppColors.latte.crust.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.titleSmall.copyWith(
                    color: isDarkMode
                        ? AppColors.mocha.text
                        : AppColors.latte.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.bodySmall.copyWith(
                    color: isDarkMode
                        ? AppColors.mocha.text.withOpacity(0.8)
                        : AppColors.latte.text.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
