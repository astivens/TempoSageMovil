import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
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
      appBar: CustomAppBar(
        title:
            widget.activity != null ? 'Edit Activity' : 'Create New Activity',
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
                    ? 'Edit your activity details'
                    : 'Add a new activity or task to your schedule',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Activity title',
                  filled: true,
                  fillColor: AppColors.surface0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    FormValidators.validateRequired(value, 'Title'),
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
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 8),
                            Text(_selectedTime.format(context)),
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
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: AppColors.surface0,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      items: _priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        filled: true,
                        fillColor: AppColors.surface0,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
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
                  fillColor: AppColors.surface0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: _saveActivity,
                  text: widget.activity != null
                      ? 'Save Changes'
                      : 'Create Activity',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
