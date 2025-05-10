import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../activities/data/models/activity_model.dart';
import '../../../activities/data/repositories/activity_repository.dart';
import '../../../activities/presentation/screens/create_activity_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ActivityRepository _repository =
      ServiceLocator.instance.activityRepository;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
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
    _focusedDay = now;
    _selectedDay = now;

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
    final isDarkMode = context.isDarkMode;

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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final surfaceColor = Theme.of(context).cardColor;
    final textColor = context.textColor;

    // Obtener dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcular dimensiones adecuadas para un calendario visible
    final double cellWidth = screenWidth / 7;
    final double cellHeight = cellWidth * 0.8;
    final double dayOfWeekHeight = 20.0;
    final double headerHeight = 50.0;

    // Altura del calendario = altura de cabecera + altura de días de semana + (altura de celda * 6 filas)
    final double calendarHeight =
        headerHeight + dayOfWeekHeight + (cellHeight * 6);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Calendario',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contenedor con altura fija para el calendario
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              height: calendarHeight,
              child: TableCalendar<ActivityModel>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                // Forzar sólo el formato mensual para evitar problemas de visualización
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mes',
                },
                rowHeight: cellHeight,
                daysOfWeekHeight: dayOfWeekHeight,
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  formatButtonVisible: false, // Ocultar el botón de formato
                  titleCentered: true,
                  headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  headerMargin: EdgeInsets.zero,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: textColor,
                    size: 28,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: textColor,
                    size: 28,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  weekendStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  // Usar la inicial del día para ahorrar espacio
                  dowTextFormatter: (date, locale) {
                    return DateFormat.E(locale)
                        .format(date)
                        .substring(0, 1)
                        .toUpperCase();
                  },
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true, // Mostrar días fuera del mes actual
                  // Decoración de día seleccionado
                  selectedDecoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  // Decoración del día actual
                  todayDecoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  // Decoración de días fuera del mes
                  outsideTextStyle: TextStyle(
                    color: textColor.withOpacity(0.5),
                  ),
                  // Decoración de marcadores
                  markerSize: 5,
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerMargin: const EdgeInsets.symmetric(horizontal: 0.3),
                  // Padding y márgenes
                  cellMargin: EdgeInsets.zero,
                  cellPadding: EdgeInsets.zero,
                ),
                calendarBuilders: CalendarBuilders(
                  // Personalizar la construcción de días para asegurar visibilidad completa
                  defaultBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.3),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                  // Personalizar marcadores de eventos
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;
                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          events.length > 3 ? 3 : events.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actividades',
                    style: AppStyles.titleMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    style: AppStyles.bodyMedium.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Lista de actividades
            Container(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: _selectedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: textColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay actividades para este día',
                            style: AppStyles.bodyLarge.copyWith(
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final activity = _selectedEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                              style: AppStyles.bodyLarge.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${TimeOfDay.fromDateTime(activity.startTime).format(context)} - ${TimeOfDay.fromDateTime(activity.endTime).format(context)}',
                                  style: AppStyles.bodySmall.copyWith(
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTag(activity.category, primaryColor),
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
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                  onPressed: () {},
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
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: AppStyles.bodySmall.copyWith(color: color),
      ),
    );
  }
}
