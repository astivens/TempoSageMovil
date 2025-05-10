import 'package:flutter/material.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/utils/validators/form_validators.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/activity_model.dart';

class CreateActivityScreen extends StatefulWidget {
  final ActivityModel? activity;
  final Map<String, dynamic>? arguments;

  const CreateActivityScreen({
    super.key,
    this.activity,
    this.arguments,
  });

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repository = ServiceLocator.instance.activityRepository;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Trabajo';
  String _selectedPriority = 'Media';

  final List<String> _categories = ['Trabajo', 'Personal', 'Estudio', 'Otro'];
  final List<String> _priorities = ['Alta', 'Media', 'Baja'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.activity != null) {
      _titleController.text = widget.activity!.title;
      _descriptionController.text = widget.activity!.description;
      _selectedDate = widget.activity!.startTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.activity!.startTime);
      _selectedCategory = widget.activity!.category;
      _selectedPriority = widget.activity!.priority;
    } else if (widget.arguments != null) {
      _titleController.text = widget.arguments!['title'] ?? '';
      _selectedCategory = widget.arguments!['category'] ?? 'Trabajo';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final DateTime startTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final DateTime endTime = startTime.add(const Duration(hours: 1));

        final activity = widget.activity?.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              startTime: startTime,
              endTime: endTime,
              category: _selectedCategory,
              priority: _selectedPriority,
            ) ??
            ActivityModel.create(
              title: _titleController.text,
              description: _descriptionController.text,
              startTime: startTime,
              endTime: endTime,
              category: _selectedCategory,
              priority: _selectedPriority,
            );

        if (widget.activity != null) {
          await _repository.updateActivity(activity);
        } else {
          await _repository.addActivity(activity);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint('Error guardando actividad: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar la actividad'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar(
        title: widget.activity != null
            ? 'Editar Actividad'
            : 'Crear Nueva Actividad',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.activity != null
                    ? 'Edita los detalles de tu actividad'
                    : 'Añade una nueva actividad o tarea a tu agenda',
                style: AppStyles.bodyMedium.copyWith(
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Título de la actividad',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: TextStyle(color: context.textColor),
                  hintStyle: TextStyle(color: context.subtextColor),
                ),
                style: TextStyle(color: context.textColor),
                validator: (value) =>
                    FormValidators.validateRequired(value, 'Título'),
              ),
              const SizedBox(height: 16),
              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme(
                                  brightness: context.isDarkMode
                                      ? Brightness.dark
                                      : Brightness.light,
                                  primary: context.primaryColor,
                                  onPrimary: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  secondary: context.secondaryColor,
                                  onSecondary: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  surface: context.surfaceColor,
                                  onSurface: context.textColor,
                                  background: context.backgroundColor,
                                  onBackground: context.textColor,
                                  error: context.errorColor,
                                  onError: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: context.textColor),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(color: context.textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme(
                                  brightness: context.isDarkMode
                                      ? Brightness.dark
                                      : Brightness.light,
                                  primary: context.primaryColor,
                                  onPrimary: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  secondary: context.secondaryColor,
                                  onSecondary: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  surface: context.surfaceColor,
                                  onSurface: context.textColor,
                                  background: context.backgroundColor,
                                  onBackground: context.textColor,
                                  error: context.errorColor,
                                  onError: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: context.textColor),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(color: context.textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Category and Priority
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: context.surfaceColor,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(color: context.textColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          filled: true,
                          fillColor: context.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: context.textColor),
                        ),
                        style: TextStyle(color: context.textColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        dropdownColor: context.surfaceColor,
                        items: _priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(
                              priority,
                              style: TextStyle(color: context.textColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Prioridad',
                          filled: true,
                          fillColor: context.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: context.textColor),
                        ),
                        style: TextStyle(color: context.textColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add details about this activity',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: TextStyle(color: context.textColor),
                  hintStyle: TextStyle(color: context.subtextColor),
                ),
                style: TextStyle(color: context.textColor),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: AccessibleButton.primary(
                  text: widget.activity != null
                      ? 'Save Changes'
                      : 'Create Activity',
                  onPressed: _saveActivity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
