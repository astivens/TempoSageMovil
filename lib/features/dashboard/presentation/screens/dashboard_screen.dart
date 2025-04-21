import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../activities/presentation/screens/edit_activity_screen.dart';
import '../../../../core/services/service_locator.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/presentation/widgets/activity_card.dart';
import '../widgets/ai_assistant_sheet.dart';
import '../../../../core/services/voice_command_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../habits/presentation/widgets/dashboard_habits.dart';
import '../../../habits/cubit/habit_cubit.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../habits/data/repositories/habit_repository_impl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _activityRepository = ServiceLocator.instance.activityRepository;
  final _habitRepository = HabitRepositoryImpl();
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  List<HabitModel> _habits = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _loadActivities();
    _loadHabits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      debugPrint('Cargando actividades...');
      final today = DateTime.now();
      final activities = await _activityRepository.getActivitiesByDate(today);
      debugPrint('Actividades encontradas: ${activities.length}');

      if (!mounted) return;

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando actividades: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHabits() async {
    try {
      final habits = await context.read<HabitCubit>().getHabitsForToday();
      setState(() {
        _habits = habits;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar hábitos: $e')),
        );
      }
    }
  }

  Future<void> _deleteActivity(String id) async {
    try {
      await _activityRepository.deleteActivity(id);
      await _loadActivities();
    } catch (e) {
      debugPrint('Error eliminando actividad: $e');
    }
  }

  Future<void> _toggleActivityCompletion(String id) async {
    try {
      await _activityRepository.toggleActivityCompletion(id);
      await _loadActivities();
    } catch (e) {
      debugPrint('Error cambiando estado de actividad: $e');
    }
  }

  Future<void> _completeHabit(HabitModel habit) async {
    try {
      await context.read<HabitCubit>().completeHabit(habit);
      _loadHabits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al completar hábito: $e')),
        );
      }
    }
  }

  Future<void> _deleteHabit(HabitModel habit) async {
    try {
      await context.read<HabitCubit>().deleteHabit(habit);
      _loadHabits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar hábito: $e')),
        );
      }
    }
  }

  void _handleVoiceCommand(VoiceCommand command) async {
    debugPrint('Manejando comando: ${command.type}');

    switch (command.type) {
      case VoiceCommandType.createActivity:
        final title = command.parameters['title'] as String;
        final category = command.parameters['category'] as String;

        if (title.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Por favor, especifica un título para la actividad'),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creando actividad: $title'),
            action: SnackBarAction(
              label: 'Ir',
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/create-activity',
                  arguments: {
                    'title': title,
                    'category': category,
                  },
                ).then((_) => _loadActivities());
              },
            ),
          ),
        );
        break;

      case VoiceCommandType.createTimeBlock:
        final title = command.parameters['title'] as String;
        final category = command.parameters['category'] as String;
        final time = command.parameters['time'] as String;

        if (title.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Por favor, especifica un título para el bloque de tiempo'),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creando bloque: $title'),
            action: SnackBarAction(
              label: 'Ir',
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/create-timeblock',
                  arguments: {
                    'title': title,
                    'category': category,
                    'time': time,
                  },
                ).then((_) => _loadActivities());
              },
            ),
          ),
        );
        break;

      case VoiceCommandType.navigate:
        final destination = command.parameters['destination'] as String;
        debugPrint('Navegando a: $destination');

        switch (destination) {
          case 'activities':
            Navigator.of(context).pushNamed('/activities');
            break;
          case 'calendar':
            Navigator.of(context).pushNamed('/calendar');
            break;
          case 'timeblocks':
            Navigator.of(context).pushNamed('/timeblocks');
            break;
          case 'dashboard':
            // Ya estamos en el dashboard
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Destino no reconocido'),
              ),
            );
        }
        break;

      case VoiceCommandType.markComplete:
        final title = command.parameters['title'] as String;
        if (title.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, especifica el título de la actividad'),
            ),
          );
          return;
        }

        // Buscar la actividad por título
        final matchingActivity = _activities.firstWhere(
          (activity) =>
              activity.title.toLowerCase().contains(title.toLowerCase()),
          orElse: () => ActivityModel(
            id: '',
            title: '',
            description: '',
            isCompleted: false,
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            category: '',
            priority: '',
          ),
        );

        if (matchingActivity.id.isNotEmpty) {
          await _toggleActivityCompletion(matchingActivity.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Actividad "${matchingActivity.title}" marcada como completada'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontró la actividad "$title"'),
              action: SnackBarAction(
                label: 'Ver todas',
                onPressed: () => Navigator.of(context).pushNamed('/activities'),
              ),
            ),
          );
        }
        break;

      case VoiceCommandType.delete:
        final title = command.parameters['title'] as String;
        if (title.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, especifica el título de la actividad'),
            ),
          );
          return;
        }

        // Buscar la actividad por título
        final activityToDelete = _activities.firstWhere(
          (activity) =>
              activity.title.toLowerCase().contains(title.toLowerCase()),
          orElse: () => ActivityModel(
            id: '',
            title: '',
            description: '',
            isCompleted: false,
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            category: '',
            priority: '',
          ),
        );

        if (activityToDelete.id.isNotEmpty) {
          await _deleteActivity(activityToDelete.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Actividad "${activityToDelete.title}" eliminada'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontró la actividad "$title"'),
              action: SnackBarAction(
                label: 'Ver todas',
                onPressed: () => Navigator.of(context).pushNamed('/activities'),
              ),
            ),
          );
        }
        break;

      case VoiceCommandType.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pude entender ese comando. ¿Podrías intentarlo de nuevo?',
            ),
          ),
        );
        break;
    }
  }

  void _showAIAssistant() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AIAssistantSheet(
        onCommandRecognized: _handleVoiceCommand,
      ),
    );
  }

  void _showEditActivityModal(ActivityModel activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
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
    ).then((_) => _loadActivities());
  }

  void _navigateToEditActivity(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityScreen(
          activity: activity,
        ),
      ),
    ).then((_) => _loadActivities());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitCubit(_habitRepository),
      child: Scaffold(
        backgroundColor: AppColors.base,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.base,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  title: Row(
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
                          color: AppColors.text.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  background:
                      const SizedBox(), // Eliminamos el background ya que no lo necesitamos
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      _buildTodayOverview(),
                      const SizedBox(height: 24),
                      _buildActivitiesSection(),
                      const SizedBox(height: 24),
                      _buildAIRecommendations(),
                      const SizedBox(height: 24),
                      DashboardHabits(
                        habits: _habits,
                        onComplete: _completeHabit,
                        onDelete: _deleteHabit,
                        onViewAll: () =>
                            Navigator.pushNamed(context, '/habits'),
                        onAddNew: () =>
                            Navigator.pushNamed(context, '/habits/create'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAIAssistant,
          backgroundColor: AppColors.blue,
          child: const Icon(Icons.mic),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Puntuación',
                  value: '85',
                  icon: Icons.star,
                  color: AppColors.yellow,
                  progress: 0.85,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Tiempo Restante',
                  value: '2h 30m',
                  icon: Icons.timer,
                  color: AppColors.blue,
                  progress: 0.65,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Tareas Completadas',
                  value: '5/8',
                  icon: Icons.check_circle,
                  color: AppColors.green,
                  progress: 5 / 8,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Enfoque Diario',
                  value: '70%',
                  icon: Icons.psychology,
                  color: AppColors.mauve,
                  progress: 0.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.text.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              style: AppStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOverview() {
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
                child: _buildTimeBlock(
                  title: 'Mañana',
                  time: '8:00 - 12:00',
                  tasks: 3,
                  completed: 2,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeBlock(
                  title: 'Tarde',
                  time: '13:00 - 18:00',
                  tasks: 4,
                  completed: 1,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFocusTime(),
        ],
      ),
    );
  }

  Widget _buildTimeBlock({
    required String title,
    required String time,
    required int tasks,
    required int completed,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completed / tasks,
            backgroundColor: AppColors.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            '$completed/$tasks tareas completadas',
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.text.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTime() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mauve.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: AppColors.mauve,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tiempo de Enfoque',
                style: AppStyles.titleSmall.copyWith(
                  color: AppColors.mauve,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: AppColors.surface2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mauve),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3h 30m / 5h',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.text.withOpacity(0.8),
                ),
              ),
              Text(
                '70% Completado',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surface2,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividades',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_activities.isEmpty)
            Center(
              child: Text(
                'No hay actividades programadas',
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ActivityCard(
                  activity: activity,
                  onTap: () => _showEditActivityModal(activity),
                  onDelete: () => _deleteActivity(activity.id),
                  onEdit: () => _navigateToEditActivity(activity),
                  onToggleComplete: () =>
                      _toggleActivityCompletion(activity.id),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendations() {
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
                  color: AppColors.text.withOpacity(0.7),
                ),
                onPressed: () {
                  // TODO: Implementar actualización de recomendaciones
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(
            icon: Icons.psychology,
            color: AppColors.mauve,
            title: 'Optimiza tu enfoque',
            description:
                'Tu productividad es mayor entre las 10:00 y 12:00. Programa tus tareas importantes en este horario.',
            actionText: 'Reorganizar tareas',
            onAction: () {
              // TODO: Implementar reorganización de tareas
            },
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            icon: Icons.battery_charging_full,
            color: AppColors.peach,
            title: 'Momento de descanso',
            description:
                'Has estado trabajando por 2 horas seguidas. Toma un descanso de 15 minutos.',
            actionText: 'Iniciar descanso',
            onAction: () {
              // TODO: Implementar timer de descanso
            },
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            icon: Icons.insights,
            color: AppColors.green,
            title: 'Análisis de productividad',
            description:
                'Has completado más tareas que ayer a esta hora. ¡Mantén el ritmo!',
            actionText: 'Ver estadísticas',
            onAction: () {
              // TODO: Navegar a estadísticas
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyles.titleSmall.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.text.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionText,
                            style: AppStyles.bodySmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: color,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
