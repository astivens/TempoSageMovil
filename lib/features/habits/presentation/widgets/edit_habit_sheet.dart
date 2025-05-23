import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/habit_model.dart';
import '../../domain/entities/habit.dart';

class EditHabitSheet extends StatefulWidget {
  final HabitModel habit;

  const EditHabitSheet({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitSheet> createState() => _EditHabitSheetState();
}

class _EditHabitSheetState extends State<EditHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _timeController;
  late String _category;
  late String _reminder;
  late List<String> _daysOfWeek;
  bool _isLoading = false;

  final _repository = ServiceLocator.instance.habitRepository;
  final List<String> _categoryOptions = [
    'Trabajo',
    'Salud',
    'Personal',
    'Estudio',
    'Otro'
  ];
  final List<String> _reminderOptions = [
    '15 minutos antes',
    '30 minutos antes',
    '1 hora antes',
    'Sin recordatorio'
  ];
  final List<String> _dayOptions = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController =
        TextEditingController(text: widget.habit.description);
    _timeController = TextEditingController(text: widget.habit.time);
    _category = widget.habit.category;
    _reminder = widget.habit.reminder;
    _daysOfWeek = List.from(widget.habit.daysOfWeek);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Método para convertir de HabitModel a Habit
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Crear un objeto actualizado con los nuevos valores
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        daysOfWeek: _daysOfWeek,
        category: _category,
        reminder: _reminder,
        time: _timeController.text,
      );

      // Convertir a entidad y guardar
      final habitEntity = _mapModelToEntity(updatedHabit);
      await _repository.updateHabit(habitEntity);

      // Cerrar el sheet y refrescar datos
      if (mounted) {
        Navigator.pop(context, true); // true indica que hubo cambios
      }
    } catch (e) {
      // Manejar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          DateTime.parse('2021-01-01 ${_timeController.text}:00')),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (selectedTime != null) {
      setState(() {
        _timeController.text =
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar Hábito',
                  style: AppStyles.titleMedium.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.text),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Este campo es requerido'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: _categoryOptions
                  .map((category) =>
                      DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(_timeController.text),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _reminder,
              decoration: const InputDecoration(
                labelText: 'Recordatorio',
                border: OutlineInputBorder(),
              ),
              items: _reminderOptions
                  .map((reminder) =>
                      DropdownMenuItem(value: reminder, child: Text(reminder)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _reminder = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Días de la semana',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.text,
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: _dayOptions.map((day) {
                final isSelected = _daysOfWeek.contains(day);
                return FilterChip(
                  label: Text(day.substring(0, 3)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _daysOfWeek.add(day);
                      } else {
                        _daysOfWeek.remove(day);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.mocha.blue.withValues(alpha: 128)
                      : AppColors.latte.blue.withValues(alpha: 128),
                  checkmarkColor: AppColors.text,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.mocha.blue
                            : AppColors.latte.blue,
                    foregroundColor: AppColors.text,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
