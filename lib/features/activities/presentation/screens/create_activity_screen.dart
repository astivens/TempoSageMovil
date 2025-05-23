import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/activity_model.dart';
import '../../../../core/services/service_locator.dart';
import 'package:provider/provider.dart';
import '../controllers/activity_recommendation_controller.dart';

class CreateActivityScreen extends StatefulWidget {
  final ActivityModel? activity;
  final DateTime? initialDate;

  const CreateActivityScreen({
    super.key, 
    this.activity,
    this.initialDate,
  });

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _category = 'Trabajo';
  String _priority = 'Media';
  bool _isCompleted = false;
  bool _isSubmitting = false;
  bool _sendReminder = false;
  int _reminderMinutesBefore = 15;
  late ActivityRecommendationController _recommendationController;

  final List<String> _categories = [
    'Trabajo',
    'Estudio',
    'Ejercicio',
    'Ocio',
    'Otro'
  ];

  final List<String> _priorities = ['Alta', 'Media', 'Baja'];

  final List<int> _reminderOptions = [5, 10, 15, 30, 60, 120];

  @override
  void initState() {
    super.initState();
    _recommendationController = ActivityRecommendationController();
    _loadRecommendations();
    
    // Obtener la fecha actual sin hora para comparaciones
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    
    if (widget.activity != null) {
      _titleController.text = widget.activity!.title;
      _descriptionController.text = widget.activity!.description;
      _selectedDate = widget.activity!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.activity!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.activity!.endTime);
      _category = widget.activity!.category;
      _priority = widget.activity!.priority;
      _isCompleted = widget.activity!.isCompleted;
      _sendReminder = widget.activity!.sendReminder;
      _reminderMinutesBefore = widget.activity!.reminderMinutesBefore;
    } else {
      // Para una nueva actividad
      // Usar la fecha inicial proporcionada o la fecha actual
      _selectedDate = widget.initialDate != null ?
          // Si hay una fecha inicial, verificamos que no sea anterior a hoy
          (widget.initialDate!.isBefore(today) ? today : widget.initialDate!) :
          today;
          
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now().replacing(
        hour: TimeOfDay.now().hour + 1 > 23 ? 23 : TimeOfDay.now().hour + 1,
      );
    }
  }

  Future<void> _loadRecommendations() async {
    await _recommendationController.loadRecommendations();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final activityRepository = ServiceLocator.instance.activityRepository;
        final startDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _startTime.hour,
          _startTime.minute,
        );
        final endDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _endTime.hour,
          _endTime.minute,
        );

        // Si el tiempo de fin es antes que el tiempo de inicio, ajustarlo al día siguiente
        final adjustedEndDateTime = endDateTime.isBefore(startDateTime)
            ? endDateTime.add(const Duration(days: 1))
            : endDateTime;

        final activity = ActivityModel(
          id: widget.activity?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          startTime: startDateTime,
          endTime: adjustedEndDateTime,
          category: _category,
          priority: _priority,
          isCompleted: _isCompleted,
          sendReminder: _sendReminder,
          reminderMinutesBefore: _reminderMinutesBefore,
        );

        if (widget.activity != null) {
          await activityRepository.updateActivity(activity);
        } else {
          await activityRepository.addActivity(activity);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  Future<void> _selectDate() async {
    // Obtenemos la fecha actual sin hora para comparaciones
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    
    // Configuramos la primera fecha seleccionable
    // Si estamos editando una actividad existente, permitimos fechas pasadas
    // Si estamos creando una nueva, solo permitimos desde hoy
    final DateTime firstSelectableDate = widget.activity != null ? 
        today.subtract(const Duration(days: 365)) : 
        today;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) && widget.activity == null ? 
                  today : _selectedDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;
        // Si la hora de inicio es después de la hora de fin, actualizar la hora de fin
        if (_compareTimeOfDay(_startTime, _endTime) >= 0) {
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (pickedTime != null && pickedTime != _endTime) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 - minutes2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditing = widget.activity != null;

    // Definir colores para mejorar el contraste y visibilidad
    final borderColor = theme.colorScheme.primary.withOpacity(0.7);
    final fillColor = theme.colorScheme.surface.withOpacity(0.3);
    final textColor = theme.colorScheme.onSurface;

    // Estilo de entrada común para todos los campos de texto con mejor contraste
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        borderRadius: BorderRadius.circular(8),
      ),
      fillColor: fillColor,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(
        color: textColor.withOpacity(0.8),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: textColor.withOpacity(0.6),
      ),
    );

    return ChangeNotifierProvider.value(
      value: _recommendationController,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: isEditing ? l10n.editActivity : l10n.createActivity,
          showBackButton: true,
          titleStyle: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          centerTitle: true,
        ),
        body: Consumer<ActivityRecommendationController>(
          builder: (context, recommendationController, child) {
            return SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: inputDecoration.copyWith(
                          labelText: l10n.activityTitle,
                          hintText: l10n.activityTitleHint,
                          prefixIcon: Icon(Icons.title,
                              color:
                                  theme.colorScheme.primary.withOpacity(0.7)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.activityTitle;
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: inputDecoration.copyWith(
                          labelText: l10n.activityDescription,
                          hintText: l10n.activityDescriptionHint,
                          prefixIcon: Icon(Icons.description,
                              color:
                                  theme.colorScheme.primary.withOpacity(0.7)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fecha
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1.0),
                            borderRadius: BorderRadius.circular(8),
                            color: fillColor,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.activityDate,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateTimeUtils.formatDate(_selectedDate),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_drop_down,
                                  color: theme.colorScheme.onSurface)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hora de inicio y fin
                      Row(
                        children: [
                          // Hora de inicio
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectStartTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 1.0),
                                  borderRadius: BorderRadius.circular(8),
                                  color: fillColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6)),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.activityStartTime,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _startTime.format(context),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Hora de fin
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectEndTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 1.0),
                                  borderRadius: BorderRadius.circular(8),
                                  color: fillColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6)),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.activityEndTime,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _endTime.format(context),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Botón para sugerir horario óptimo
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (_category.isNotEmpty) {
                            final tempActivity = ActivityModel(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              title: _titleController.text.isNotEmpty
                                  ? _titleController.text
                                  : 'Actividad temporal',
                              description: _descriptionController.text,
                              startTime: DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                _startTime.hour,
                                _startTime.minute,
                              ),
                              endTime: DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                _endTime.hour,
                                _endTime.minute,
                              ),
                              category: _category,
                              priority: _priority,
                            );

                            await recommendationController
                                .suggestOptimalTime(tempActivity);

                            // Mostrar diálogo de confirmación
                            if (recommendationController.error == null &&
                                context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Horario óptimo sugerido'),
                                  content: const Text(
                                    'Se ha encontrado un horario óptimo para tu actividad basado en tu historial y disponibilidad.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Selecciona una categoría primero'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          'Sugerir horario óptimo',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fila para Categoría y Prioridad
                      Row(
                        children: [
                          // Categoría
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: borderColor, width: 1.0),
                                borderRadius: BorderRadius.circular(8),
                                color: fillColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.category,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _category,
                                        isExpanded: true,
                                        dropdownColor: theme.cardColor,
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16),
                                        hint: Text(
                                          l10n.activityCategory,
                                          style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.8)),
                                        ),
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: theme.colorScheme.onSurface),
                                        items: _categories.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _category = newValue;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Prioridad
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: borderColor, width: 1.0),
                                borderRadius: BorderRadius.circular(8),
                                color: fillColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.priority_high,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _priority,
                                        isExpanded: true,
                                        dropdownColor: theme.cardColor,
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16),
                                        hint: Text(
                                          l10n.activityPriority,
                                          style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.8)),
                                        ),
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: theme.colorScheme.onSurface),
                                        items: _priorities.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _priority = newValue;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Completado (solo visible al editar)
                      if (isEditing) ...[
                        SwitchListTile(
                          title: Text(
                            l10n.activityCompleted,
                            style:
                                TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          value: _isCompleted,
                          onChanged: (bool value) {
                            setState(() {
                              _isCompleted = value;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: fillColor,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Recordatorio
                      SwitchListTile(
                        title: Text(
                          'Recordatorio',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        value: _sendReminder,
                        onChanged: (bool value) {
                          setState(() {
                            _sendReminder = value;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: borderColor, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: fillColor,
                      ),

                      // Minutos antes (solo visible si recordatorio está activado)
                      if (_sendReminder) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1.0),
                            borderRadius: BorderRadius.circular(8),
                            color: fillColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recordar',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _reminderMinutesBefore,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                ),
                                items: _reminderOptions.map((minutes) {
                                  return DropdownMenuItem<int>(
                                    value: minutes,
                                    child: Text('$minutes minutos antes'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _reminderMinutesBefore = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Sección de recomendaciones
                      if (widget.activity == null &&
                          recommendationController
                              .recommendedActivities.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recomendaciones basadas en tu historial',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ...recommendationController
                                    .recommendedActivities
                                    .map(
                                      (activity) => ListTile(
                                        title: Text(activity.title),
                                        subtitle: Text(activity.description),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              _category = activity.category;
                                              _titleController.text =
                                                  activity.title;
                                              _descriptionController.text =
                                                  activity.description;
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                    color: theme.colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                l10n.cancel,
                                style:
                                    TextStyle(color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _saveActivity,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(isEditing
                                      ? l10n.activitySaveChanges
                                      : l10n.activityCreate),
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
    );
  }
}
