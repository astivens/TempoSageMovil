import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/repositories/activity_repository.dart';
import '../../../activities/presentation/screens/create_activity_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ActivityRepository _repository = ActivityRepository();
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<ActivityModel>> _events = {};
  List<ActivityModel> _selectedEvents = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Definir un rango de fechas que incluya el día actual
  late final DateTime kFirstDay;
  late final DateTime kLastDay;

  @override
  void initState() {
    super.initState();
    // Inicializar las fechas
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;

    // Establecer el primer día como el primer día del año actual
    kFirstDay = DateTime(now.year, 1, 1);
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
      // TODO: Handle error
      debugPrint('Error loading activities: $e');
    }
  }

  List<ActivityModel> _getEventsForDay(DateTime day) {
    // Normalizar la fecha eliminando la hora
    final date = DateTime(day.year, day.month, day.day);

    // Filtrar las actividades que coincidan exactamente con la fecha
    return _events.entries
        .where((entry) =>
            entry.key.year == date.year &&
            entry.key.month == date.month &&
            entry.key.day == date.day)
        .expand((entry) => entry.value)
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      // Actualizar la lista de eventos para el día seleccionado
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return AppColors.red;
      case 'media':
        return AppColors.yellow;
      case 'baja':
        return AppColors.green;
      default:
        return AppColors.overlay0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Calendar',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateActivityScreen(),
                ),
              );
              _loadActivities();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<ActivityModel>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: AppColors.mauve,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.mauve,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.mauve,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final activity = _selectedEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  color: AppColors.surface0,
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
                          '${TimeOfDay.fromDateTime(activity.startTime).format(context)} - ${TimeOfDay.fromDateTime(activity.endTime).format(context)}',
                          style: AppStyles.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTag(activity.category, AppColors.blue),
                            const SizedBox(width: 8),
                            _buildTag(
                              activity.priority,
                              _getPriorityColor(activity.priority),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.overlay0),
                          onPressed: () {
                            // TODO: Implement edit
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppStyles.bodySmall.copyWith(color: color),
      ),
    );
  }
}
