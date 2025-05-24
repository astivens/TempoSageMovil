import 'package:flutter/material.dart';
import '../../data/models/habit_model.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<bool> _selectedDays = List.generate(7, (index) => false);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo Hábito',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Meditar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Meditar 10 minutos por la mañana',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Hora
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hora'),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                  onPressed: _selectTime,
                ),
              ),
              const SizedBox(height: 8),

              // Días de la semana
              Text(
                'Días de la semana',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: [
                  'Lunes',
                  'Martes',
                  'Miércoles',
                  'Jueves',
                  'Viernes',
                  'Sábado',
                  'Domingo'
                ].asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: _selectedDays[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                    checkmarkColor: theme.colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isNotEmpty &&
                          _selectedDays.any((day) => day)) {
                        final daysOfWeekStr = <String>[];
                        final dayNames = [
                          'Lunes',
                          'Martes',
                          'Miércoles',
                          'Jueves',
                          'Viernes',
                          'Sábado',
                          'Domingo'
                        ];

                        for (int i = 0; i < _selectedDays.length; i++) {
                          if (_selectedDays[i]) {
                            daysOfWeekStr.add(dayNames[i]);
                          }
                        }

                        final timeStr =
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
                        final today = DateTime.now();

                        final habit = HabitModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          category: 'Hábito',
                          isCompleted: false,
                          streak: 0,
                          totalCompletions: 0,
                          daysOfWeek: daysOfWeekStr,
                          lastCompleted: null,
                          time: timeStr,
                          dateCreation: today,
                          reminder: 'none',
                        );

                        Navigator.of(context).pop(habit);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor, introduce un título y selecciona al menos un día'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
