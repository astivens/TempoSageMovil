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
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
          onPressed: () {
            controller.loadData();
            controller.predictProductivity();
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Mostrar indicador de carga si está cargando datos de la API
    if (controller.isApiLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mostrar error si hay alguno
    if (controller.apiError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Error: ${controller.apiError}',
            style: TextStyle(color: AppColors.red),
          ),
        ),
      );
    }

    // Verificar si hay recomendaciones
    final hasProductivity = controller.productivityPrediction != null;
    final hasSuggestions = controller.timeSuggestions != null &&
        controller.timeSuggestions!.isNotEmpty;
    final hasPatterns = controller.activityPatterns != null &&
        controller.activityPatterns!.isNotEmpty;

    // Loguear para depuración
    debugPrint('Estado de recomendaciones:');
    debugPrint('- Productividad: ${controller.productivityPrediction}');
    debugPrint(
        '- Tiene sugerencias: $hasSuggestions (${controller.timeSuggestions?.length ?? 0})');
    debugPrint(
        '- Tiene patrones: $hasPatterns (${controller.activityPatterns?.length ?? 0})');

    // Si no hay recomendaciones, mostrar el estado vacío
    if (!hasProductivity && !hasSuggestions && !hasPatterns) {
      return _buildEmptyState();
    }

    // Si hay recomendaciones, mostrarlas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar predicción de productividad si está disponible
        if (hasProductivity)
          AIRecommendationCard(
            icon: Icons.insights,
            accentColor:
                _getProductivityColor(controller.productivityPrediction!),
            title: 'Predicción de Productividad',
            description: controller.productivityExplanation ??
                'Tu productividad estimada para hoy es de ${controller.productivityPrediction!.toStringAsFixed(1)}/10.',
            actionText: 'Ver Detalles',
            onApply: () {
              showDialog(
                context: parentContext,
                builder: (context) => AlertDialog(
                  title: const Text('Detalles de Productividad'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Productividad: ${controller.productivityPrediction!.toStringAsFixed(1)}/10'),
                      const SizedBox(height: 8),
                      Text(controller.productivityExplanation ??
                          'Sin detalles disponibles'),
                    ],
                  ),
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

        // Mostrar sugerencias de horarios óptimos si están disponibles
        if (hasSuggestions)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: AIRecommendationCard(
              icon: Icons.schedule,
              accentColor: AppColors.mauve,
              title: 'Horario Óptimo',
              description:
                  _formatTimeSuggestion(controller.timeSuggestions!.first),
              actionText: 'Ver Todas las Sugerencias',
              onApply: () {
                showDialog(
                  context: parentContext,
                  builder: (context) => AlertDialog(
                    title: const Text('Horarios Sugeridos'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.timeSuggestions!.map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(_formatTimeSuggestion(suggestion)),
                          );
                        }).toList(),
                      ),
                    ),
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
          ),

        // Mostrar patrones de actividad si están disponibles
        if (hasPatterns)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: AIRecommendationCard(
              icon: Icons.trending_up,
              accentColor: AppColors.green,
              title: 'Patrones Detectados',
              description:
                  _formatActivityPattern(controller.activityPatterns!.first),
              actionText: 'Ver Todos los Patrones',
              onApply: () {
                showDialog(
                  context: parentContext,
                  builder: (context) => AlertDialog(
                    title: const Text('Patrones Detectados'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.activityPatterns!.map((pattern) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(_formatActivityPattern(pattern)),
                          );
                        }).toList(),
                      ),
                    ),
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
          ),
      ],
    );
  }

  // Estado vacío cuando no hay recomendaciones
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: AppColors.yellow,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no hay sugerencias inteligentes',
              style: AppStyles.titleSmall.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Conforme utilices más la aplicación, iremos generando recomendaciones personalizadas para ti.',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.text.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                controller.predictProductivity();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar recomendaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para obtener color según nivel de productividad
  Color _getProductivityColor(double productivity) {
    if (productivity >= 7.5) {
      return AppColors.green;
    } else if (productivity >= 5) {
      return AppColors.yellow;
    } else {
      return AppColors.red;
    }
  }

  // Formato para mostrar sugerencias de horario
  String _formatTimeSuggestion(Map<String, dynamic> suggestion) {
    try {
      final startTimeStr = suggestion['start_time'];
      final endTimeStr = suggestion['end_time'];
      final confidenceValue = suggestion['confidence'];

      if (startTimeStr == null ||
          endTimeStr == null ||
          confidenceValue == null) {
        return 'Horario sugerido no disponible';
      }

      final startTime = DateTime.parse(startTimeStr);
      final endTime = DateTime.parse(endTimeStr);
      final confidence = (confidenceValue as double) * 100;

      final formattedStart =
          '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
      final formattedEnd =
          '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';

      return 'De $formattedStart a $formattedEnd (${confidence.toStringAsFixed(0)}% de confianza)';
    } catch (e) {
      debugPrint('Error al formatear sugerencia de horario: $e');
      return 'Horario sugerido (formato no disponible)';
    }
  }

  // Formato para mostrar patrones de actividad
  String _formatActivityPattern(Map<String, dynamic> pattern) {
    try {
      final category = pattern['category'] ?? 'No disponible';

      double completionRate = 0.0;
      if (pattern['completion_rate'] != null) {
        completionRate = (pattern['completion_rate'] as double) * 100;
      }

      final preferredTime = pattern['preferred_time'] ?? 'No disponible';
      final daysOfWeek = pattern['days_of_week'];

      // Verificar si daysOfWeek es null o no es una lista
      final formattedDays =
          daysOfWeek is List ? daysOfWeek.join(', ') : 'No disponible';

      return 'Categoría: $category\nCompletado: ${completionRate.toStringAsFixed(0)}%\nHorario preferido: $preferredTime\nDías: $formattedDays';
    } catch (e) {
      debugPrint('Error al formatear patrón de actividad: $e');
      return 'Patrón detectado (formato no disponible)';
    }
  }
}
