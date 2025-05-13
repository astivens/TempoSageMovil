import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/services/service_locator.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/repositories/activity_repository.dart';
import '../../../activities/presentation/screens/create_activity_screen.dart';
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
    return _events.entries
        .where((entry) =>
            entry.key.year == date.year &&
            entry.key.month == date.month &&
            entry.key.day == date.day)
        .expand((entry) => entry.value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.calendarActivities,
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

          // Título de la sección de eventos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.calendarActivities,
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Lista de eventos
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      _selectedDay.isAtSameMomentAs(DateTime.now())
                          ? l10n.calendarNoEventsToday
                          : l10n.calendarNoEventsSelected,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          title: Text(
                            event.title,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                          leading: Container(
                            width: 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                          onTap: () {
                            // Abrir la vista de detalle o edición
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateActivityScreen(
                                  activity: event,
                                ),
                              ),
                            ).then((_) => _loadActivities());
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
