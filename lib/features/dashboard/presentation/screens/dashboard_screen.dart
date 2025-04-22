// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
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
import '../../../habits/data/models/habit_model.dart';
import '../../../habits/presentation/widgets/edit_habit_sheet.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/day_overview_section.dart';
import '../widgets/ai_recommendation_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _activityRepository = ServiceLocator.instance.activityRepository;
  final _habitRepository = ServiceLocator.instance.habitRepository;
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  List<HabitModel> _habits = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar actividades
      debugPrint('Cargando actividades...');
      final today = DateTime.now();
      final activities = await _activityRepository.getActivitiesByDate(today);
      debugPrint('Actividades encontradas: ${activities.length}');

      // Cargar hábitos
      debugPrint('Cargando hábitos...');
      final habits = await _habitRepository.getHabitsForToday();
      debugPrint('Hábitos encontrados: ${habits.length}');

      // Debug de hábitos
      if (mounted) {
        for (var habit in habits) {
          debugPrint(
              'Hábito: ${habit.title}, hora: ${habit.time.format(context)}');
        }
      }

      if (!mounted) return;

      setState(() {
        _activities = activities;
        _habits = habits;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error cargando datos: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
  }

  Future<void> _deleteActivity(String id) async {
    try {
      await _activityRepository.deleteActivity(id);
      await _loadData();
    } catch (e) {
      debugPrint('Error eliminando actividad: $e');
    }
  }

  Future<void> _toggleActivityCompletion(String id) async {
    try {
      await _activityRepository.toggleActivityCompletion(id);
      await _loadData();
    } catch (e) {
      debugPrint('Error cambiando estado de actividad: $e');
    }
  }

  Future<void> _deleteHabit(HabitModel habit) async {
    try {
      await _habitRepository.deleteHabit(habit.id);
      _loadData();
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
                ).then((_) => _loadData());
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
                ).then((_) => _loadData());
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
      backgroundColor: AppColors.transparent,
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
    ).then((_) => _loadData());
  }

  void _navigateToEditActivity(ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityScreen(
          activity: activity,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _showEditHabitModal(HabitModel habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => EditHabitSheet(habit: habit),
    );
  }

  void _navigateToEditHabit(HabitModel habit) {
    Navigator.pushNamed(
      context,
      '/edit-habit',
      arguments: habit,
    );
  }

  Future<void> _toggleHabitCompletion(String habitId) async {
    try {
      await _habitRepository.markHabitAsCompleted(habitId);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado del hábito: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildDayOverview(),
                    const SizedBox(height: 24),
                    _buildActivitiesSection(),
                    const SizedBox(height: 24),
                    _buildAIRecommendations(),
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
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.base,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
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
                color: AppColors.text.withValues(alpha: 179), // 0.7 * 255 ≈ 179
              ),
            ),
          ],
        ),
        background: const SizedBox(),
      ),
    );
  }

  Widget _buildQuickStats() {
    final completedActivities = _activities.where((a) => a.isCompleted).length;
    final completedHabits = _habits.where((h) => h.isCompleted).length;
    final totalActivities = _activities.length;
    final totalHabits = _habits.length;

    final totalActivityTime = _activities.fold<Duration>(
      Duration.zero,
      (sum, activity) => sum + activity.endTime.difference(activity.startTime),
    );

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final remainingTime = endOfDay.difference(now);

    final focusScore = (totalActivities + totalHabits) > 0
        ? ((completedActivities + completedHabits) /
                (totalActivities + totalHabits)) *
            100
        : 0.0;

    return QuickStatsSection(
      completedActivities: completedActivities,
      completedHabits: completedHabits,
      totalActivities: totalActivities,
      totalHabits: totalHabits,
      totalActivityTime: totalActivityTime,
      remainingTime: remainingTime,
      focusScore: focusScore,
    );
  }

  Widget _buildDayOverview() {
    final morningActivities = _activities.where((a) {
      final hour = a.startTime.hour;
      return hour >= 6 && hour < 12;
    }).toList();

    final afternoonActivities = _activities.where((a) {
      final hour = a.startTime.hour;
      return hour >= 12 && hour < 18;
    }).toList();

    final eveningActivities = _activities.where((a) {
      final hour = a.startTime.hour;
      return hour >= 18 || hour < 6;
    }).toList();

    final now = DateTime.now();
    final hour = now.hour;

    final morningHabits = hour >= 6 && hour < 12 ? _habits : [];
    final afternoonHabits = hour >= 12 && hour < 18 ? _habits : [];
    final eveningHabits = hour >= 18 || hour < 6 ? _habits : [];

    return DayOverviewSection(
      morningActivities: morningActivities,
      afternoonActivities: afternoonActivities,
      eveningActivities: eveningActivities,
      morningHabits: morningHabits,
      afternoonHabits: afternoonHabits,
      eveningHabits: eveningHabits,
    );
  }

  Widget _buildActivitiesSection() {
    final allItems = [..._activities, ..._habits];
    allItems.sort((a, b) {
      final aTime = a is ActivityModel
          ? a.startTime
          : DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              (a as HabitModel).time.hour,
              (a as HabitModel).time.minute,
            );
      final bTime = b is ActivityModel
          ? b.startTime
          : DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              (b as HabitModel).time.hour,
              (b as HabitModel).time.minute,
            );
      return aTime.compareTo(bTime);
    });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.list_alt,
                    color: AppColors.text,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Actividades y Hábitos',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.text),
                onPressed: _loadData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (allItems.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 48,
                    color: AppColors.text
                        .withValues(alpha: 153), // 0.6 * 255 ≈ 153
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay actividades ni hábitos programados',
                    style: TextStyle(
                      color: AppColors.text
                          .withValues(alpha: 153), // 0.6 * 255 ≈ 153
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                if (item is ActivityModel) {
                  return ActivityCard(
                    activity: item,
                    onTap: () => _showEditActivityModal(item),
                    onDelete: () => _deleteActivity(item.id),
                    onEdit: () => _navigateToEditActivity(item),
                    onToggleComplete: () => _toggleActivityCompletion(item.id),
                    isHabit: false,
                  );
                } else if (item is HabitModel) {
                  final startTime = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    item.time.hour,
                    item.time.minute,
                  );
                  final endTime = startTime.add(const Duration(minutes: 30));

                  return ActivityCard(
                    activity: ActivityModel(
                      id: item.id,
                      title: item.title,
                      description: item.description,
                      isCompleted: item.isCompleted,
                      startTime: startTime,
                      endTime: endTime,
                      category: item.category,
                      priority: 'Medium',
                    ),
                    onTap: () => _showEditHabitModal(item),
                    onDelete: () => _deleteHabit(item),
                    onEdit: () => _navigateToEditHabit(item),
                    onToggleComplete: () => _toggleHabitCompletion(item.id),
                    isHabit: true,
                  );
                }
                return const SizedBox.shrink();
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
                  color:
                      AppColors.text.withValues(alpha: 179), // 0.7 * 255 ≈ 179
                ),
                onPressed: () {
                  _loadData();
                },
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
              // Reorganizar tareas según la recomendación
              final morningActivities = _activities.where((a) {
                final hour = a.startTime.hour;
                return hour >= 10 && hour < 12;
              }).toList();

              if (morningActivities.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No hay tareas para reorganizar')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tareas reorganizadas con éxito')),
                );
              }
            },
            onDismiss: () {
              ScaffoldMessenger.of(context).showSnackBar(
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
                context: context,
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
              ScaffoldMessenger.of(context).showSnackBar(
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
              Navigator.pushNamed(context, '/statistics');
            },
            onDismiss: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recomendación descartada')),
              );
            },
          ),
        ],
      ),
    );
  }
}
