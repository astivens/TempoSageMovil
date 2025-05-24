import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
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
    // Solo mostrar si hay recomendaciones relevantes y útiles
    if (!_hasRelevantRecommendations()) {
      return const SizedBox.shrink();
    }

    return _buildDiscreteIndicator(context);
  }

  /// Verifica si hay recomendaciones relevantes que vale la pena mostrar
  bool _hasRelevantRecommendations() {
    if (controller.isApiLoading) return false;
    if (controller.apiError != null) return false;

    // Solo mostrar si hay productividad baja o sugerencias útiles
    final hasLowProductivity = controller.productivityPrediction != null &&
        controller.productivityPrediction! < 6.0;

    final hasUsefulSuggestions = controller.timeSuggestions != null &&
        controller.timeSuggestions!.isNotEmpty;

    final hasPatterns = controller.activityPatterns != null &&
        controller.activityPatterns!.isNotEmpty;

    return hasLowProductivity || hasUsefulSuggestions || hasPatterns;
  }

  /// Construye un indicador discreto flotante
  Widget _buildDiscreteIndicator(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showIntelligentAssistantSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.mocha.blue.withOpacity(0.1)
                  : AppColors.latte.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? AppColors.mocha.blue.withOpacity(0.3)
                    : AppColors.latte.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador animado de IA
                _buildPulsingIcon(isDarkMode),
                const SizedBox(width: 8),

                // Texto contextual y discreto
                Flexible(
                  child: Text(
                    _getContextualMessage(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? AppColors.mocha.blue
                          : AppColors.latte.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 4),

                // Flecha sutil
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: isDarkMode
                      ? AppColors.mocha.blue.withOpacity(0.7)
                      : AppColors.latte.blue.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Crea un ícono con animación sutil
  Widget _buildPulsingIcon(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.5, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 12,
              color: isDarkMode ? AppColors.mocha.base : AppColors.latte.base,
            ),
          ),
        );
      },
      onEnd: () {
        // Reiniciar animación después de un breve delay
      },
    );
  }

  /// Genera un mensaje contextual basado en las recomendaciones disponibles
  String _getContextualMessage() {
    if (controller.productivityPrediction != null &&
        controller.productivityPrediction! < 6.0) {
      return 'Sugerencias para mejorar productividad';
    }

    if (controller.timeSuggestions != null &&
        controller.timeSuggestions!.isNotEmpty) {
      return 'Horarios óptimos disponibles';
    }

    if (controller.activityPatterns != null &&
        controller.activityPatterns!.isNotEmpty) {
      return 'Nuevos patrones detectados';
    }

    return 'Asistente inteligente disponible';
  }

  /// Muestra el panel completo del asistente inteligente
  void _showIntelligentAssistantSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IntelligentAssistantSheet(
        controller: controller,
        parentContext: parentContext,
      ),
    );
  }
}

/// Panel deslizable del asistente inteligente
class _IntelligentAssistantSheet extends StatelessWidget {
  final DashboardController controller;
  final BuildContext parentContext;

  const _IntelligentAssistantSheet({
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.mocha.surface0
                : AppColors.latte.surface0,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle del drag
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.mocha.overlay0
                      : AppColors.latte.overlay0,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: isDarkMode
                          ? AppColors.mocha.blue
                          : AppColors.latte.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Asistente Inteligente',
                        style: AppStyles.titleMedium.copyWith(
                          color: isDarkMode
                              ? AppColors.mocha.text
                              : AppColors.latte.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode
                            ? AppColors.mocha.subtext1
                            : AppColors.latte.subtext1,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildRecommendationCards(context, isDarkMode),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCards(BuildContext context, bool isDarkMode) {
    final cards = <Widget>[];

    // Productividad
    if (controller.productivityPrediction != null &&
        controller.productivityPrediction! < 6.0) {
      cards.add(_buildRecommendationCard(
        context: context,
        isDarkMode: isDarkMode,
        icon: Icons.insights,
        title: 'Mejora tu Productividad',
        description:
            'Tu productividad estimada es ${controller.productivityPrediction!.toStringAsFixed(1)}/10',
        action: 'Ver Sugerencias',
        onTap: () => _showProductivityDetails(context),
      ));
    }

    // Horarios óptimos
    if (controller.timeSuggestions != null &&
        controller.timeSuggestions!.isNotEmpty) {
      cards.add(_buildRecommendationCard(
        context: context,
        isDarkMode: isDarkMode,
        icon: Icons.schedule,
        title: 'Horarios Óptimos',
        description: 'Encuentra los mejores momentos para tus actividades',
        action: 'Ver Horarios',
        onTap: () => _showTimeSuggestions(context),
      ));
    }

    // Patrones
    if (controller.activityPatterns != null &&
        controller.activityPatterns!.isNotEmpty) {
      cards.add(_buildRecommendationCard(
        context: context,
        isDarkMode: isDarkMode,
        icon: Icons.trending_up,
        title: 'Patrones Detectados',
        description: 'Nuevos patrones en tus actividades',
        action: 'Explorar',
        onTap: () => _showPatterns(context),
      ));
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              ))
          .toList(),
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required bool isDarkMode,
    required IconData icon,
    required String title,
    required String description,
    required String action,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.mocha.surface1
                : AppColors.latte.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.mocha.surface2
                  : AppColors.latte.surface2,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.mocha.blue.withOpacity(0.2)
                      : AppColors.latte.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDarkMode
                            ? AppColors.mocha.text
                            : AppColors.latte.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppColors.mocha.subtext1
                            : AppColors.latte.subtext1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                action,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de acción simplificados
  void _showProductivityDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Productividad'),
        content: Text(
            controller.productivityExplanation ?? 'Sin detalles disponibles'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showTimeSuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Horarios Sugeridos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.timeSuggestions!.map((suggestion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
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
  }

  void _showPatterns(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patrones Detectados'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.activityPatterns!.map((pattern) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
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
  }

  String _formatTimeSuggestion(Map<String, dynamic> suggestion) {
    final activity = suggestion['activity'] ?? 'Actividad';
    final time = suggestion['time'] ?? 'Hora no especificada';
    final reason = suggestion['reason'] ?? '';

    String result = '$activity a las $time';
    if (reason.isNotEmpty) {
      result += ' - $reason';
    }
    return result;
  }

  String _formatActivityPattern(Map<String, dynamic> pattern) {
    final category = pattern['category'] ?? 'Categoría';
    final frequency = pattern['frequency'] ?? 'Frecuencia';
    final trend = pattern['trend'] ?? 'Tendencia';

    return '$category: $frequency ($trend)';
  }
}
