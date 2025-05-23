import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/services/service_locator.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/repositories/activity_repository.dart';
import '../../../activities/presentation/screens/create_activity_screen.dart';
import '../../../activities/presentation/widgets/activity_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ActivityRepository _repository =
      ServiceLocator.instance.activityRepository;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<ActivityModel>> _events = {};
  List<ActivityModel> _selectedEvents = [];
  bool _showCreateForm = false;
  String? _selectedCategory;

  // Lista de categorías disponibles para filtrar
  final List<String> _categories = ['Trabajo', 'Estudio', 'Ejercicio', 'Ocio', 'Otro'];

  // Definir un rango de fechas que incluya el día actual
  late final DateTime kFirstDay;
  late final DateTime kLastDay;

  @override
  void initState() {
    super.initState();
    // Inicializar las fechas
    final now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;

    // Establecer el primer día como el primer día del año anterior
    kFirstDay = DateTime(now.year - 1, 1, 1);
    // Establecer el último día como el último día del próximo año
    kLastDay = DateTime(now.year + 1, 12, 31);

    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await _repository.getAllActivities();
      final events = <DateTime, List<ActivityModel>>{};

      for (final activity in activities) {
        // Normalizar la fecha eliminando la hora
        final date = DateTime(
          activity.startTime.year,
          activity.startTime.month,
          activity.startTime.day,
        );

        events.update(
          date,
          (existingActivities) => [...existingActivities, activity],
          ifAbsent: () => [activity],
        );
      }

      if (mounted) {
        setState(() {
          _events = events;
          _selectedEvents = _getEventsForDay(_selectedDay);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar actividades: $e'),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _loadActivities,
            ),
          ),
        );
      }
      debugPrint('Error loading activities: $e');
    }
  }

  List<ActivityModel> _getEventsForDay(DateTime day) {
    // Normalizar la fecha eliminando la hora
    final date = DateTime(day.year, day.month, day.day);
    
    // Obtener todas las actividades para la fecha
    final activities = _events.entries
        .where((entry) =>
            entry.key.year == date.year &&
            entry.key.month == date.month &&
            entry.key.day == date.day)
        .expand((entry) => entry.value)
        .toList();
    
    // Filtrar por categoría si hay una seleccionada
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      return activities.where((activity) => 
        activity.category == _selectedCategory).toList();
    }
    
    return activities;
  }

  void _toggleCreateForm() {
    setState(() {
      _showCreateForm = !_showCreateForm;
    });
  }

  Future<void> _createActivityInline(BuildContext context) async {
    // Obtener la fecha actual sin hora para comparaciones
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    
    // Asegurarnos de que la fecha seleccionada no sea anterior a hoy
    final DateTime dateToUse = _selectedDay.isBefore(today) ? today : _selectedDay;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateActivityScreen(
          initialDate: dateToUse,
        ),
      ),
    );
    
    if (result == true) {
      await _loadActivities();
      _toggleCreateForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.activities,
        showBackButton: false,
        titleStyle: TextStyle(
          color: theme.colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onBackground),
            onPressed: () => _createActivityInline(context),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onBackground),
            onPressed: () {
              _showCategoryFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendario
          TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 3,
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle:
                  TextStyle(color: theme.colorScheme.onBackground),
              defaultTextStyle:
                  TextStyle(color: theme.colorScheme.onBackground),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                color: theme.colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onBackground,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onBackground,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
                // Reiniciar el formulario de creación cuando cambia el día
                _showCreateForm = false;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),

          // Línea divisoria
          Divider(
            color: theme.colorScheme.onBackground.withOpacity(0.2),
            thickness: 1,
            height: 1,
          ),

          // Título de la sección de eventos con un botón para añadir actividad
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.activities,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (_selectedCategory != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_selectedCategory!),
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedEvents = _getEventsForDay(_selectedDay);
                          });
                        },
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _createActivityInline(context),
                      tooltip: l10n.createActivity,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de eventos
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDay.isAtSameMomentAs(DateTime.now())
                              ? l10n.noActivitiesToday
                              : l10n.noActivitiesSelected,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _createActivityInline(context),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createActivity),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return ActivityCard(
                        activity: event,
                        onToggleComplete: () async {
                          final updatedActivity = event.copyWith(
                            isCompleted: !event.isCompleted,
                          );
                          await _repository.updateActivity(updatedActivity);
                          await _loadActivities();
                        },
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateActivityScreen(
                                activity: event,
                              ),
                            ),
                          );
                          if (result == true) {
                            await _loadActivities();
                          }
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.delete),
                              content: Text(l10n.activityDeleteConfirmation),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _repository.deleteActivity(event.id);
                            await _loadActivities();
                          }
                        },
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por categoría'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Todas las categorías'),
                  leading: Icon(
                    Icons.clear_all,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  selected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedEvents = _getEventsForDay(_selectedDay);
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ..._categories.map((category) => ListTile(
                      title: Text(category),
                      leading: Icon(
                        _getCategoryIcon(category),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      selected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          _selectedEvents = _getEventsForDay(_selectedDay);
                        });
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'trabajo':
        return Icons.work;
      case 'estudio':
        return Icons.school;
      case 'ejercicio':
        return Icons.fitness_center;
      case 'ocio':
        return Icons.sports_esports;
      default:
        return Icons.category;
    }
  }
}
