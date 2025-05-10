import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../widgets/ai_recommendation_card.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../core/constants/app_animations.dart';

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Sugerencias Inteligentes',
              style: AppStyles.titleMedium.copyWith(
                color: isDarkMode ? AppColors.mocha.text : AppColors.latte.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: (isDarkMode ? AppColors.mocha.text : AppColors.latte.text)
                .withValues(alpha: 179),
          ),
          onPressed: () {
            controller.loadData();
            controller.predictProductivity();
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            style: TextStyle(
                color: isDarkMode ? AppColors.mocha.red : AppColors.latte.red),
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
      return _buildEmptyState(context);
    }

    // Si hay recomendaciones, mostrarlas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar predicción de productividad si está disponible
        if (hasProductivity)
          _AIRecommendationCard(
            title: 'Predicción de Productividad',
            description: controller.productivityExplanation ??
                'Tu productividad estimada para hoy es de ${controller.productivityPrediction!.toStringAsFixed(1)}/10.',
            child: AIRecommendationCard(
              icon: Icons.insights,
              accentColor: _getProductivityColor(
                  controller.productivityPrediction!, context),
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
          ),

        // Mostrar sugerencias de horarios óptimos si están disponibles
        if (hasSuggestions)
          _AIRecommendationCard(
            title: 'Horario Óptimo',
            description:
                _formatTimeSuggestion(controller.timeSuggestions!.first),
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: AIRecommendationCard(
                icon: Icons.schedule,
                accentColor:
                    isDarkMode ? AppColors.mocha.mauve : AppColors.latte.mauve,
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
                          children:
                              controller.timeSuggestions!.map((suggestion) {
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
          ),

        // Mostrar patrones de actividad si están disponibles
        if (hasPatterns)
          _AIRecommendationCard(
            title: 'Patrones Detectados',
            description:
                _formatActivityPattern(controller.activityPatterns!.first),
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: AIRecommendationCard(
                icon: Icons.trending_up,
                accentColor:
                    Theme.of(parentContext).brightness == Brightness.dark
                        ? AppColors.mocha.green
                        : AppColors.latte.green,
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
          ),

        // --- NUEVA TARJETA: Predicción de Logro de Metas ---
        _AIRecommendationCard(
          title: 'Predicción de Logro de Meta',
          description:
              'Consulta la probabilidad de lograr una meta a largo plazo y recibe sugerencias personalizadas.',
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _GoalAchievementCard(
                controller: controller, parentContext: parentContext),
          ),
        ),

        // --- NUEVA TARJETA: Predicción de Niveles de Energía ---
        _AIRecommendationCard(
          title: 'Predicción de Energía y Burnout',
          description:
              'Consulta tus niveles de energía estimados y el riesgo de burnout según tus hábitos y actividades recientes.',
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _EnergyPredictionCard(
                controller: controller, parentContext: parentContext),
          ),
        ),

        // --- NUEVA TARJETA: Recomendaciones de Hábitos Personalizados ---
        _AIRecommendationCard(
          title: 'Recomendaciones de Hábitos',
          description:
              'Obtén sugerencias de hábitos personalizadas según tus metas y patrones actuales.',
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _HabitRecommendationCard(
                controller: controller, parentContext: parentContext),
          ),
        ),
      ],
    );
  }

  // Estado vacío cuando no hay recomendaciones
  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.mocha.surface1 : AppColors.latte.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue)
                .withOpacity(0.3),
            width: 2),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color:
                  isDarkMode ? AppColors.mocha.yellow : AppColors.latte.yellow,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no hay sugerencias inteligentes',
              style: AppStyles.titleSmall.copyWith(
                color: isDarkMode ? AppColors.mocha.text : AppColors.latte.text,
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
                  color:
                      (isDarkMode ? AppColors.mocha.text : AppColors.latte.text)
                          .withOpacity(0.7),
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
                backgroundColor:
                    isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
                foregroundColor:
                    isDarkMode ? AppColors.mocha.text : AppColors.latte.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para obtener color según nivel de productividad
  Color _getProductivityColor(double productivity, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (productivity >= 7.5) {
      return isDarkMode ? AppColors.mocha.green : AppColors.latte.green;
    } else if (productivity >= 5) {
      return isDarkMode ? AppColors.mocha.yellow : AppColors.latte.yellow;
    } else {
      return isDarkMode ? AppColors.mocha.red : AppColors.latte.red;
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

class _AIRecommendationCard extends StatefulWidget {
  final String title;
  final String description;
  final Widget child;

  const _AIRecommendationCard({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  State<_AIRecommendationCard> createState() => _AIRecommendationCardState();
}

class _AIRecommendationCardState extends State<_AIRecommendationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.smoothCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: AppStyles.titleMedium.copyWith(
                                color: isDarkMode
                                    ? AppColors.mocha.blue
                                    : AppColors.latte.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: AppStyles.bodyMedium.copyWith(
                                color: isDarkMode
                                    ? AppColors.mocha.subtext1
                                    : AppColors.latte.subtext1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        duration: AppAnimations.normal,
                        turns: _isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkMode
                              ? AppColors.mocha.blue
                              : AppColors.latte.blue,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: widget.child,
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: AppAnimations.normal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para la tarjeta de predicción de logro de metas
class _GoalAchievementCard extends StatefulWidget {
  final DashboardController controller;
  final BuildContext parentContext;
  const _GoalAchievementCard(
      {required this.controller, required this.parentContext});

  @override
  State<_GoalAchievementCard> createState() => _GoalAchievementCardState();
}

class _GoalAchievementCardState extends State<_GoalAchievementCard> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  DateTime? _selectedDate;
  bool _expanded = false;

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _consultarPrediccion() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    await widget.controller.predictGoalAchievement(
      goalDescription: _goalController.text.trim(),
      targetDeadline: _selectedDate!,
    );
    setState(() {
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = widget.controller.isGoalPredictionLoading;
    final error = widget.controller.goalPredictionError;
    final result = widget.controller.goalPredictionResult;

    return AIRecommendationCard(
      icon: Icons.flag,
      accentColor: isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
      title: 'Predicción de Logro de Meta',
      description: _expanded && result != null
          ? _buildResultDescription(result)
          : 'Consulta la probabilidad de lograr una meta a largo plazo y recibe sugerencias personalizadas.',
      actionText: _expanded ? 'Nueva Consulta' : 'Consultar',
      onApply: () {
        setState(() {
          _expanded = !_expanded;
        });
        if (!_expanded) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Predicción de Logro de Meta'),
            content: SizedBox(
              width: 320,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                        labelText: 'Describe tu meta',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Ingresa una meta'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_selectedDate == null
                              ? 'Selecciona fecha objetivo'
                              : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: _consultarPrediccion,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Consultar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppColors.mocha.blue
                              : AppColors.latte.blue,
                          foregroundColor: isDarkMode
                              ? AppColors.mocha.text
                              : AppColors.latte.text,
                        ),
                      ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Error: $error',
                          style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.mocha.red
                                  : AppColors.latte.red),
                        ),
                      ),
                  ],
                ),
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
        setState(() {
          _expanded = false;
          _goalController.clear();
          _selectedDate = null;
        });
      },
    );
  }

  String _buildResultDescription(Map<String, dynamic> result) {
    final probability = result['probability'] != null
        ? (result['probability'] * 100).toStringAsFixed(1)
        : 'N/A';
    final suggestions = result['suggestions'] as List<dynamic>?;
    return 'Probabilidad de logro: $probability%\n' +
        (suggestions != null && suggestions.isNotEmpty
            ? 'Sugerencias: ${suggestions.join(", ")}'
            : '');
  }
}

// Widget para la tarjeta de predicción de energía
class _EnergyPredictionCard extends StatefulWidget {
  final DashboardController controller;
  final BuildContext parentContext;
  const _EnergyPredictionCard(
      {required this.controller, required this.parentContext});

  @override
  State<_EnergyPredictionCard> createState() => _EnergyPredictionCardState();
}

class _EnergyPredictionCardState extends State<_EnergyPredictionCard> {
  bool _expanded = false;

  void _consultarPrediccion() async {
    await widget.controller.predictEnergyLevels();
    setState(() {
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = widget.controller.isEnergyPredictionLoading;
    final error = widget.controller.energyPredictionError;
    final result = widget.controller.energyPredictionResult;

    return AIRecommendationCard(
      icon: Icons.bolt,
      accentColor: isDarkMode ? AppColors.mocha.yellow : AppColors.latte.yellow,
      title: 'Predicción de Energía y Burnout',
      description: _expanded && result != null
          ? _buildResultDescription(result)
          : 'Consulta tus niveles de energía estimados y el riesgo de burnout según tus hábitos y actividades recientes.',
      actionText: _expanded ? 'Nueva Consulta' : 'Consultar',
      onApply: () {
        setState(() {
          _expanded = !_expanded;
        });
        if (!_expanded) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Predicción de Energía y Burnout'),
            content: SizedBox(
              width: 320,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : result != null
                      ? Text(_buildResultDescription(result))
                      : error != null
                          ? Text('Error: $error',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.mocha.red
                                      : AppColors.latte.red))
                          : ElevatedButton.icon(
                              onPressed: _consultarPrediccion,
                              icon: const Icon(Icons.analytics),
                              label: const Text('Consultar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? AppColors.mocha.yellow
                                    : AppColors.latte.yellow,
                                foregroundColor: isDarkMode
                                    ? AppColors.mocha.text
                                    : AppColors.latte.text,
                              ),
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
        setState(() {
          _expanded = false;
        });
      },
    );
  }

  String _buildResultDescription(Map<String, dynamic> result) {
    final energy = result['energy_level'] != null
        ? (result['energy_level'] * 100).toStringAsFixed(1)
        : 'N/A';
    final burnout = result['burnout_risk'] != null
        ? (result['burnout_risk'] * 100).toStringAsFixed(1)
        : 'N/A';
    final advice = result['advice'] ?? '';
    return 'Nivel de energía: $energy%\nRiesgo de burnout: $burnout%\n' +
        (advice.isNotEmpty ? 'Consejo: $advice' : '');
  }
}

// Widget para la tarjeta de recomendación de hábitos
class _HabitRecommendationCard extends StatefulWidget {
  final DashboardController controller;
  final BuildContext parentContext;
  const _HabitRecommendationCard(
      {required this.controller, required this.parentContext});

  @override
  State<_HabitRecommendationCard> createState() =>
      _HabitRecommendationCardState();
}

class _HabitRecommendationCardState extends State<_HabitRecommendationCard> {
  final _formKey = GlobalKey<FormState>();
  final _goalsController = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _goalsController.dispose();
    super.dispose();
  }

  void _consultarRecomendacion() async {
    if (!_formKey.currentState!.validate()) return;
    final goals = _goalsController.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
    await widget.controller.recommendHabits(userGoals: goals);
    setState(() {
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = widget.controller.isHabitRecommendationLoading;
    final error = widget.controller.habitRecommendationError;
    final result = widget.controller.habitRecommendationResult;

    return AIRecommendationCard(
      icon: Icons.auto_fix_high,
      accentColor: isDarkMode ? AppColors.mocha.mauve : AppColors.latte.mauve,
      title: 'Recomendaciones de Hábitos',
      description: _expanded && result != null
          ? _buildResultDescription(result)
          : 'Obtén sugerencias de hábitos personalizadas según tus metas y patrones actuales.',
      actionText: _expanded ? 'Nueva Consulta' : 'Consultar',
      onApply: () {
        setState(() {
          _expanded = !_expanded;
        });
        if (!_expanded) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Recomendaciones de Hábitos'),
            content: SizedBox(
              width: 320,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _goalsController,
                      decoration: const InputDecoration(
                        labelText: 'Tus metas (separadas por coma)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Ingresa al menos una meta'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: _consultarRecomendacion,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Consultar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppColors.mocha.mauve
                              : AppColors.latte.mauve,
                          foregroundColor: isDarkMode
                              ? AppColors.mocha.text
                              : AppColors.latte.text,
                        ),
                      ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Error: $error',
                          style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.mocha.red
                                  : AppColors.latte.red),
                        ),
                      ),
                  ],
                ),
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
        setState(() {
          _expanded = false;
          _goalsController.clear();
        });
      },
    );
  }

  String _buildResultDescription(Map<String, dynamic> result) {
    final habits = result['recommended_habits'] as List<dynamic>?;
    if (habits == null || habits.isEmpty) {
      return 'No se encontraron recomendaciones de hábitos.';
    }
    return 'Hábitos recomendados:\n- ${habits.map((h) => h.toString()).join('\n- ')}';
  }
}
