import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/validators/form_validators.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/activity_model.dart';

class EditActivityScreen extends StatefulWidget {
  final ActivityModel activity;

  const EditActivityScreen({
    super.key,
    required this.activity,
  });

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  String _selectedCategory = 'Trabajo';
  String _selectedPriority = 'Media';
  bool _isCompleted = false;

  final List<String> _categories = ['Trabajo', 'Personal', 'Estudio', 'Otro'];
  final List<String> _priorities = ['Alta', 'Media', 'Baja'];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.activity.title;
    _descriptionController.text = widget.activity.description;
    _selectedDate = widget.activity.startTime;
    _startTime = TimeOfDay(
      hour: widget.activity.startTime.hour,
      minute: widget.activity.startTime.minute,
    );
    _endTime = TimeOfDay(
      hour: widget.activity.endTime.hour,
      minute: widget.activity.endTime.minute,
    );
    _selectedCategory = widget.activity.category;
    _selectedPriority = widget.activity.priority;
    _isCompleted = widget.activity.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateActivity() async {
    if (_formKey.currentState?.validate() ?? false) {
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

      final updatedActivity = widget.activity.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        category: _selectedCategory,
        priority: _selectedPriority,
        isCompleted: _isCompleted,
      );

      await ServiceLocator.instance.activityRepository
          .updateActivity(updatedActivity);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness:
                  context.isDarkMode ? Brightness.dark : Brightness.light,
              primary: context.primaryColor,
              onPrimary: context.isDarkMode ? Colors.white : Colors.black,
              secondary: context.secondaryColor,
              onSecondary: context.isDarkMode ? Colors.white : Colors.black,
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
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness:
                  context.isDarkMode ? Brightness.dark : Brightness.light,
              primary: context.primaryColor,
              onPrimary: context.isDarkMode ? Colors.white : Colors.black,
              secondary: context.secondaryColor,
              onSecondary: context.isDarkMode ? Colors.white : Colors.black,
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
        if (isStartTime) {
          _startTime = picked;
          if (_startTime.hour >= _endTime.hour &&
              _startTime.minute >= _endTime.minute) {
            _endTime = _startTime.replacing(hour: _startTime.hour + 1);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _deleteActivity() async {
    try {
      await ServiceLocator.instance.activityRepository
          .deleteActivity(widget.activity.id);
      if (mounted) {
        Navigator.pop(context, true); // true indica que se eliminó la actividad
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editActivity),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: context.textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.activityTitle,
                  hintText: l10n.activityTitleHint,
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
                    FormValidators.validateRequired(value, l10n.activityTitle),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: context.textColor),
                      const SizedBox(width: 8),
                      Text(
                        l10n.activityDate,
                        style: TextStyle(color: context.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
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
                              '${l10n.activityStartTime}: ${_startTime.format(context)}',
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
                      onTap: () => _selectTime(false),
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
                              '${l10n.activityEndTime}: ${_endTime.format(context)}',
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
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.activityDescription,
                  hintText: l10n.activityDescriptionHint,
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
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface0,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  hint: Text(l10n.activityCategory),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface0,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _priorities.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPriority = newValue;
                      });
                    }
                  },
                  hint: const Text('Priority'),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Completada',
                  style: TextStyle(color: context.textColor),
                ),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
                activeColor: context.primaryColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AccessibleButton.primary(
                  text: l10n.activitySaveChanges,
                  onPressed: _updateActivity,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.activityDelete),
                        content: Text(l10n.activityDeleteConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteActivity();
                            },
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.activityDelete),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
