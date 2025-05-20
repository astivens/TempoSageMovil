import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../controllers/activity_recommendation_controller.dart';
import '../widgets/ai_recommendation_card.dart';

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
  final _activityRepository = ServiceLocator.instance.activityRepository;

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
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ActivityRecommendationController>(
        builder: (context, controller, child) {
          if (!controller.isModelInitialized) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Inicializando modelo de recomendaciones...'),
                  ],
                ),
              ),
            );
          }

          if (controller.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando recomendaciones...'),
                  ],
                ),
              ),
            );
          }

          if (controller.error != null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _initializeController,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final activities = controller.recommendedActivities;
          if (activities.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No hay recomendaciones disponibles en este momento.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recomendaciones para ti',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ...activities.take(3).map((activity) => _buildRecommendationCard(
                    context,
                    activity,
                    activities.indexOf(activity),
                  )),
              if (activities.length > 3)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => _showAllRecommendations(context),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver todas las recomendaciones'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.mocha.blue
                                : AppColors.latte.blue,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, ActivityModel activity, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Color> accentColors = isDarkMode
        ? [AppColors.mocha.blue, AppColors.mocha.mauve, AppColors.mocha.green]
        : [AppColors.latte.blue, AppColors.latte.mauve, AppColors.latte.green];

    final accentColor = accentColors[index % accentColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AIRecommendationCard(
        icon: Icons.stars,
        accentColor: accentColor,
        title: activity.title,
        description: '${activity.category}\n${activity.description}',
        actionText: 'Crear actividad',
        onApply: () => _showCreateActivityDialog(context, activity),
        onDismiss: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recomendación descartada'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showAllRecommendations(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todas las Recomendaciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _controller.recommendedActivities.map((activity) {
              return ListTile(
                title: Text(activity.title),
                subtitle: Text(activity.category),
                leading: const Icon(Icons.check_circle_outline),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateActivityDialog(widget.parentContext, activity);
                },
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

  void _showCreateActivityDialog(BuildContext context, ActivityModel activity) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBackgroundColor =
        isDarkMode ? AppColors.mocha.base : AppColors.latte.base;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBackgroundColor,
        title: Text('Crear Actividad: ${activity.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Categoría'),
                subtitle: Text(activity.category),
                leading: const Icon(Icons.category),
              ),
              ListTile(
                title: const Text('Descripción'),
                subtitle: Text(activity.description),
                leading: const Icon(Icons.description),
              ),
              ListTile(
                title: const Text('Hora de inicio sugerida'),
                subtitle: Text(
                    '${activity.startTime.hour}:${activity.startTime.minute.toString().padLeft(2, '0')}'),
                leading: const Icon(Icons.access_time),
              ),
              ListTile(
                title: const Text('Duración sugerida'),
                subtitle: Text(
                    '${activity.endTime.difference(activity.startTime).inHours} horas'),
                leading: const Icon(Icons.timer),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showProgressDialog(context);

              try {
                await _activityRepository.addActivity(activity);
                if (context.mounted) {
                  Navigator.pop(context); // Cerrar diálogo de progreso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Actividad creada exitosamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Cerrar diálogo de progreso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear la actividad: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text('Crear Actividad'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creando actividad...'),
          ],
        ),
      ),
    );
  }
}
