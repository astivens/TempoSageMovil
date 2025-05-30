import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../screens/create_activity_screen.dart';
import '../screens/edit_activity_screen.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final ActivityRepository _repository =
      ServiceLocator.instance.activityRepository;
  final TextEditingController _searchController = TextEditingController();
  List<ActivityModel> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _repository.getAllActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendationController =
          ServiceLocator.instance.activityRecommendationController;
      await recommendationController.loadRecommendations();

      // No actualizar el estado aquí, solo queremos tener las recomendaciones listas
    } catch (e) {
      // Manejar error silenciosamente
    }
  }

  Future<void> _editActivity(ActivityModel activity) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDarkMode ? AppColors.mocha.surface0 : AppColors.latte.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditActivityScreen(
          activity: activity,
        ),
      ),
    );
    await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Actividades',
        showBackButton: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administra todas tus actividades y tareas programadas',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar actividades...',
                    hintStyle: AppStyles.bodyMedium.copyWith(
                      color: isDarkMode
                          ? AppColors.mocha.overlay0
                          : AppColors.latte.overlay0,
                    ),
                    prefixIcon: Icon(Icons.search,
                        color: isDarkMode
                            ? AppColors.mocha.overlay0
                            : AppColors.latte.overlay0),
                    filled: true,
                    fillColor: isDarkMode
                        ? AppColors.mocha.surface0
                        : AppColors.latte.surface0,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: AppStyles.bodyMedium,
                  onChanged: (value) {
                    // Implementar búsqueda de actividades
                    setState(() {});
                  },
                ),

                // Sección de recomendaciones
                const SizedBox(height: 16),
                _buildRecommendationsSection(context),
              ],
            ),
          ),
          // Activities List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _activities.isEmpty
                    ? Center(
                        child: Text(
                          'No hay actividades',
                          style: AppStyles.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          final activity = _activities[index];
                          // Filtra solo por texto de búsqueda
                          if (_searchController.text.isEmpty ||
                              activity.title.toLowerCase().contains(
                                  _searchController.text.toLowerCase())) {
                            return _buildActivityCard(activity);
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateActivityScreen(),
            ),
          );
          // Recargar siempre las actividades al volver
          await _loadActivities();

          // Si la actividad se creó con éxito, mostrar mensaje
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Actividad creada con éxito'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final recommendationController =
        ServiceLocator.instance.activityRecommendationController;
    final recommendedActivities =
        recommendationController.recommendedActivities;

    if (recommendedActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, size: 18),
            const SizedBox(width: 8),
            Text(
              'Actividades Recomendadas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basado en tu historial de actividades, te recomendamos:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedActivities.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final recommendation = recommendedActivities[index];
                    return Card(
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () async {
                          try {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateActivityScreen(
                                  activity: recommendation,
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              _loadActivities();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al crear actividad: $e'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation.title,
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recommendation.category,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Añadir',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.mocha.surface0 : AppColors.latte.surface0,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _getPriorityColor(activity.priority),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          activity.title,
          style: AppStyles.bodyLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Today, ${TimeOfDay.fromDateTime(activity.startTime).format(context)} - ${TimeOfDay.fromDateTime(activity.endTime).format(context)}',
              style: AppStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag(
                    activity.category, Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _buildTag(
                    activity.priority, _getPriorityColor(activity.priority)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: isDarkMode
                      ? AppColors.mocha.overlay0
                      : AppColors.latte.overlay0),
              onPressed: () => _editActivity(activity),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: isDarkMode
                      ? AppColors.mocha.overlay0
                      : AppColors.latte.overlay0),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar actividad'),
                    content: Text(
                        '¿Estás seguro de que quieres eliminar "${activity.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Eliminar',
                            style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.mocha.red
                                    : AppColors.latte.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _repository.deleteActivity(activity.id);
                  await _loadActivities();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.mocha.surface1 : AppColors.latte.surface1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppStyles.bodySmall.copyWith(color: color),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    switch (priority.toLowerCase()) {
      case 'alta':
        return isDarkMode ? AppColors.mocha.red : AppColors.latte.red;
      case 'media':
        return isDarkMode ? AppColors.mocha.yellow : AppColors.latte.yellow;
      case 'baja':
        return isDarkMode ? AppColors.mocha.green : AppColors.latte.green;
      default:
        return isDarkMode ? AppColors.mocha.overlay0 : AppColors.latte.overlay0;
    }
  }
}
