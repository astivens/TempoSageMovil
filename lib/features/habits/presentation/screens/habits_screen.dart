import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:temposage/core/constants/app_colors.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/core/services/event_bus.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/features/habits/presentation/widgets/habit_card.dart';
import 'package:temposage/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:temposage/features/dashboard/controllers/dashboard_controller.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _repository = ServiceLocator.instance.habitRepository;
  List<HabitModel> _habits = [];
  List<HabitModel> _recommendedHabits = [];
  bool _isLoading = true;
  int _todaysCompletedHabits = 0;
  int _longestStreak = 0;
  StreamSubscription<String>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _loadRecommendations();
    _setupEventListener();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _setupEventListener() {
    _eventSubscription = EventBus().events.listen((event) {
      debugPrint('🎧 HabitsScreen recibió evento: $event');
      if (event == AppEvents.habitCreated || event == AppEvents.dataChanged) {
        debugPrint('🔄 Actualizando lista de hábitos...');
        _loadHabits();
      }
    });
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    try {
      final habitsEntities = await _repository.getAllHabits();
      final habitModels =
          habitsEntities.map(_mapEntityToModel).toList().cast<HabitModel>();

      // Calcular estadísticas
      _calculateStatistics(habitModels);

      setState(() {
        _habits = habitModels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendationService =
          ServiceLocator.instance.habitRecommendationService;
      final recommendations =
          await recommendationService.getHabitRecommendations();

      // Guardar las recomendaciones para mostrar más tarde
      setState(() {
        _recommendedHabits = recommendations;
      });
    } catch (e) {
      // Manejar errores silenciosamente
      print('Error cargando recomendaciones de hábitos: $e');
    }
  }

  void _calculateStatistics(List<HabitModel> habits) {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Lunes, 7 = Domingo

    // Contar hábitos completados hoy
    _todaysCompletedHabits = habits
        .where((h) =>
            h.isCompleted &&
            h.daysOfWeek.any((day) {
              switch (day) {
                case 'Lunes':
                  return today == 1;
                case 'Martes':
                  return today == 2;
                case 'Miércoles':
                  return today == 3;
                case 'Jueves':
                  return today == 4;
                case 'Viernes':
                  return today == 5;
                case 'Sábado':
                  return today == 6;
                case 'Domingo':
                  return today == 7;
                default:
                  return false;
              }
            }))
        .length;

    // Calcular racha actual y más larga
    int maxStreak = 0;
    for (final habit in habits) {
      if (habit.streak > maxStreak) {
        maxStreak = habit.streak;
      }
    }
    _longestStreak = maxStreak;
  }

  // Métodos para convertir entre entidad y modelo
  HabitModel _mapEntityToModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      title: entity.name,
      description: entity.description,
      daysOfWeek: entity.daysOfWeek,
      category: entity.category,
      reminder: entity.reminder,
      time: entity.time,
      isCompleted: entity.isDone,
      dateCreation: entity.dateCreation,
      lastCompleted: null,
      streak: 0,
      totalCompletions: 0,
    );
  }

  Habit _mapModelToEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.title,
      description: model.description,
      daysOfWeek: model.daysOfWeek,
      category: model.category,
      reminder: model.reminder,
      time: model.time,
      isDone: model.isCompleted,
      dateCreation: model.dateCreation,
    );
  }

  Future<void> _showAddHabitDialog() async {
    final result = await showDialog<HabitModel>(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );

    if (result != null) {
      final habitEntity = _mapModelToEntity(result);

      // Guardar el hábito en el repositorio
      await _repository.addHabit(habitEntity);

      // Crear automáticamente bloques de tiempo para este hábito
      try {
        final habitToTimeBlockService =
            ServiceLocator.instance.habitToTimeBlockService;

        // Planificar bloques para el nuevo hábito (30 días por defecto)
        final bloquesPlanificados = await habitToTimeBlockService
            .planificarBloquesParaNuevoHabito(result);

        debugPrint(
            'Creados $bloquesPlanificados bloques de tiempo automáticamente para el hábito ${result.title}');

        // Mostrar confirmación al usuario si se crearon bloques
        if (mounted && bloquesPlanificados > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Se programaron automáticamente $bloquesPlanificados recordatorios'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error al crear bloques de tiempo automáticos: $e');
        // No mostramos error al usuario para no interrumpir la experiencia
      }

      // Recargar la lista de hábitos
      _loadHabits();

      // Intentar refrescar el dashboard también
      try {
        final dashboardController =
            Provider.of<DashboardController>(context, listen: false);
        dashboardController.refreshDashboard();
      } catch (e) {
        debugPrint('No se pudo refrescar el dashboard desde habits_screen: $e');
        // No es crítico si falla, el dashboard se actualizará la próxima vez que se abra
      }
    }
  }

  Future<void> _deleteHabit(HabitModel habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content:
            Text('¿Estás seguro de que quieres eliminar "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteHabit(habit.id);
        _loadHabits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${habit.title} eliminado'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.mocha.red
                  : AppColors.latte.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().weekday;
    final todaysHabits = _habits.where((habit) {
      return habit.daysOfWeek.any((day) {
        switch (day) {
          case 'Lunes':
            return today == 1;
          case 'Martes':
            return today == 2;
          case 'Miércoles':
            return today == 3;
          case 'Jueves':
            return today == 4;
          case 'Viernes':
            return today == 5;
          case 'Sábado':
            return today == 6;
          case 'Domingo':
            return today == 7;
          default:
            return false;
        }
      });
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.habits,
        showBackButton: false,
        titleStyle: TextStyle(
          color: theme.colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _loadHabits,
              color: theme.colorScheme.primary,
              child: _habits.isEmpty
                  ? _buildEmptyState(theme, l10n)
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Sección de estadísticas
                        _buildStatisticsSection(theme),
                        const SizedBox(height: 24),

                        // Sección de recomendaciones (si hay)
                        if (_recommendedHabits.isNotEmpty) ...[
                          _buildRecommendationsSection(theme),
                          const SizedBox(height: 24),
                        ],

                        // Hábitos de hoy
                        if (todaysHabits.isNotEmpty) ...[
                          _buildSectionTitle(theme, 'Hábitos de hoy'),
                          const SizedBox(height: 12),
                          ...todaysHabits.map((habit) => HabitCard(
                                habit: habit,
                                onComplete: () async {
                                  final habitEntity = _mapModelToEntity(habit);
                                  final updatedEntity = habitEntity.copyWith(
                                      isDone: !habit.isCompleted);
                                  await _repository.updateHabit(updatedEntity);
                                  if (mounted) {
                                    _loadHabits();
                                  }
                                },
                                onDelete: () => _deleteHabit(habit),
                              )),
                          const SizedBox(height: 24),
                        ],

                        // Lista de todos los hábitos
                        _buildSectionTitle(theme, 'Todos los hábitos'),
                        const SizedBox(height: 12),

                        ..._habits.map((habit) => HabitCard(
                              habit: habit,
                              onComplete: () async {
                                final habitEntity = _mapModelToEntity(habit);
                                final updatedEntity = habitEntity.copyWith(
                                    isDone: !habit.isCompleted);
                                await _repository.updateHabit(updatedEntity);
                                if (mounted) {
                                  _loadHabits();
                                }
                              },
                              onDelete: () => _deleteHabit(habit),
                            )),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noHabits,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un hábito para empezar a construir rutinas saludables',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddHabitDialog,
            icon: const Icon(Icons.add),
            label: const Text('Crear un hábito'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de hábitos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatisticItem(
                theme,
                'Completados hoy',
                '$_todaysCompletedHabits',
                Icons.check_circle,
              ),
              _buildStatisticItem(
                theme,
                'Racha máxima',
                '$_longestStreak',
                Icons.whatshot,
              ),
              _buildStatisticItem(
                theme,
                'Total hábitos',
                '${_habits.length}',
                Icons.calendar_today,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(
      ThemeData theme, String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onBackground,
      ),
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Hábitos Recomendados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Basado en tus patrones y objetivos, te sugerimos:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedHabits.length.clamp(0, 3),
            itemBuilder: (context, index) {
              final habit = _recommendedHabits[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    HabitCard(
                      habit: habit,
                      onComplete:
                          () {}, // No hay acción para completar un hábito recomendado
                      onDelete:
                          () {}, // No hay acción para eliminar un hábito recomendado
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        heroTag: 'add_habit_${habit.id}',
                        onPressed: () async {
                          // Agregar el hábito recomendado
                          final habitEntity = _mapModelToEntity(habit);
                          await _repository.addHabit(habitEntity);

                          // Remover de las recomendaciones y actualizar la lista
                          setState(() {
                            _recommendedHabits.remove(habit);
                          });
                          _loadHabits();

                          // Mostrar confirmación
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Hábito "${habit.title}" agregado'),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                          }
                        },
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<bool> _selectedDays = List.generate(7, (index) => false);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo Hábito',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Meditar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Meditar 10 minutos por la mañana',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Hora
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hora'),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                  onPressed: _selectTime,
                ),
              ),
              const SizedBox(height: 8),

              // Días de la semana
              const Text('Días de la semana'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < 7; i++)
                    FilterChip(
                      label: Text(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                      selected: _selectedDays[i],
                      onSelected: (selected) {
                        setState(() => _selectedDays[i] = selected);
                      },
                      backgroundColor: theme.scaffoldBackgroundColor,
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _selectedDays[i]
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onBackground,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final selectedDays = <int>[];
                      for (int i = 0; i < 7; i++) {
                        if (_selectedDays[i]) selectedDays.add(i + 1);
                      }

                      if (_titleController.text.isNotEmpty &&
                          selectedDays.isNotEmpty) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);

                        // Convertir los días de la semana de enteros a strings
                        final daysOfWeekStr = selectedDays.map((day) {
                          const days = [
                            'Lunes',
                            'Martes',
                            'Miércoles',
                            'Jueves',
                            'Viernes',
                            'Sábado',
                            'Domingo'
                          ];
                          return days[day - 1];
                        }).toList();

                        // Formatear la hora como string (HH:MM)
                        final timeStr =
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

                        final habit = HabitModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          category: 'Hábito',
                          isCompleted: false,
                          streak: 0,
                          totalCompletions: 0,
                          daysOfWeek: daysOfWeekStr,
                          lastCompleted: null,
                          time: timeStr,
                          dateCreation: today,
                          reminder: 'none',
                        );

                        Navigator.of(context).pop(habit);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor, introduce un título y selecciona al menos un día'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
