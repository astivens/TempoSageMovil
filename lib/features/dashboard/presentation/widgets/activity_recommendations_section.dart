import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/activity_recommendation_controller.dart';
import '../widgets/ai_recommendation_card.dart';
import '../../../../core/services/service_locator.dart';

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
  late ActivityRecommendationController _controller;

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
        // Obtener recomendaciones después de inicializar
        await _controller.getRecommendations();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.mocha.surface0 : AppColors.latte.surface0,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return _buildContent(context);
              }),
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
              color: isDarkMode ? AppColors.mocha.teal : AppColors.latte.teal,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Actividades Recomendadas',
              style: TextStyle(
                color: isDarkMode ? AppColors.mocha.text : AppColors.latte.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: (isDarkMode ? AppColors.mocha.text : AppColors.latte.text)
                .withOpacity(0.7),
          ),
          tooltip: 'Actualizar recomendaciones',
          onPressed:
              _controller.isLoading ? null : _controller.getRecommendations,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Mostrar indicador de carga
    if (_controller.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mostrar mensaje si no hay recomendaciones
    if (_controller.recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 40,
                color: isDarkMode
                    ? AppColors.mocha.subtext0
                    : AppColors.latte.subtext0,
              ),
              const SizedBox(height: 8),
              Text(
                'No hay suficientes datos para generar recomendaciones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.mocha.subtext0
                      : AppColors.latte.subtext0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar recomendaciones
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _controller.recommendations.length && i < 3; i++)
          _buildRecommendationCard(context, _controller.recommendations[i], i),
        if (_controller.recommendations.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: () => _showAllRecommendations(context),
                icon: const Icon(Icons.visibility),
                label: const Text('Ver todas las recomendaciones'),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, String activityId, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Obtener colores según el índice para variedad visual
    final List<Color> accentColors = isDarkMode
        ? [AppColors.mocha.blue, AppColors.mocha.mauve, AppColors.mocha.green]
        : [AppColors.latte.blue, AppColors.latte.mauve, AppColors.latte.green];

    final accentColor = accentColors[index % accentColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AIRecommendationCard(
        icon: Icons.stars,
        accentColor: accentColor,
        title: _controller.getActivityTitle(activityId),
        description:
            '${_controller.getActivityCategory(activityId)}\n${_controller.getActivityDescription(activityId)}',
        actionText: 'Crear actividad',
        onApply: () => _showCreateActivityDialog(context, activityId),
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
            children: _controller.recommendations.map((activityId) {
              return ListTile(
                title: Text(_controller.getActivityTitle(activityId)),
                subtitle: Text(_controller.getActivityCategory(activityId)),
                leading: const Icon(Icons.check_circle_outline),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateActivityDialog(widget.parentContext, activityId);
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

  void _showCreateActivityDialog(BuildContext context, String activityId) {
    final title = _controller.getActivityTitle(activityId);
    final category = _controller.getActivityCategory(activityId);
    final description = _controller.getActivityDescription(activityId);

    // Valores por defecto para la nueva actividad
    final now = DateTime.now();
    DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + 1,
      0,
    );
    DateTime endTime = startTime.add(const Duration(hours: 1));
    String priority = 'Media';
    bool sendReminder = true;
    int reminderMinutes = 15;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBackgroundColor =
        isDarkMode ? AppColors.mocha.base : AppColors.latte.base;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: const Text('Crear Nueva Actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar detalles de la actividad recomendada
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Categoría: $category',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: isDarkMode
                        ? AppColors.mocha.subtext0
                        : AppColors.latte.subtext0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(description),
                const Divider(height: 24),

                // Selector de fecha y hora
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Hora de inicio'),
                  subtitle: Text(
                    '${startTime.day}/${startTime.month} - ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: startTime,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (newDate != null) {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime),
                      );
                      if (newTime != null && mounted) {
                        setState(() {
                          startTime = DateTime(
                            newDate.year,
                            newDate.month,
                            newDate.day,
                            newTime.hour,
                            newTime.minute,
                          );
                          // Actualizar hora de fin para que sea 1 hora después
                          endTime = startTime.add(const Duration(hours: 1));
                        });
                      }
                    }
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_filled),
                  title: const Text('Hora de fin'),
                  subtitle: Text(
                    '${endTime.day}/${endTime.month} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: endTime,
                      firstDate: startTime,
                      lastDate: startTime.add(const Duration(days: 365)),
                    );
                    if (newDate != null) {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime),
                      );
                      if (newTime != null && mounted) {
                        setState(() {
                          endTime = DateTime(
                            newDate.year,
                            newDate.month,
                            newDate.day,
                            newTime.hour,
                            newTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),

                // Selector de prioridad
                Row(
                  children: [
                    const Text('Prioridad: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: priority,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            priority = value;
                          });
                        }
                      },
                      items: ['Alta', 'Media', 'Baja']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Opción de recordatorio
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enviar recordatorio'),
                  value: sendReminder,
                  onChanged: (value) {
                    setState(() {
                      sendReminder = value;
                    });
                  },
                ),

                if (sendReminder)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Text('Minutos antes: '),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: reminderMinutes,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                reminderMinutes = value;
                              });
                            }
                          },
                          items: [5, 10, 15, 30, 60]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e min'),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
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
                // Cerrar el diálogo
                Navigator.pop(context);
                // Mostrar indicador de progreso
                _showProgressDialog(context);

                // Crear la actividad
                final activity =
                    await _controller.createActivityFromRecommendation(
                  activityId,
                  startTime: startTime,
                  endTime: endTime,
                  priority: priority,
                  sendReminder: sendReminder,
                  reminderMinutesBefore: reminderMinutes,
                );

                // Cerrar indicador de progreso
                if (context.mounted) Navigator.pop(context);

                // Mostrar confirmación
                if (activity != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Actividad creada exitosamente'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Deshacer',
                        textColor: Colors.white,
                        onPressed: () async {
                          // Cancelar la actividad recién creada
                          final activityRepo =
                              ServiceLocator.instance.activityRepository;
                          await activityRepo.deleteActivity(activity.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Actividad cancelada'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al crear la actividad'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Creando actividad...'),
            ],
          ),
        );
      },
    );
  }
}
