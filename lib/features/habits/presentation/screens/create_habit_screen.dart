import 'package:flutter/material.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/habit.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  bool _isLoading = false;

  final _repository = ServiceLocator.instance.habitRepository;

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

  Future<void> _saveHabit() async {
    if (_titleController.text.trim().isEmpty ||
        !_selectedDays.any((day) => day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, introduce un título y selecciona al menos un día'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _titleController.text,
        description: _descriptionController.text,
        daysOfWeek: daysOfWeekStr,
        category: 'Hábito',
        reminder: 'none',
        time: timeStr,
        isDone: false,
        dateCreation: today,
      );

      await _repository.addHabit(habit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hábito "${habit.name}" creado exitosamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el hábito: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar.main(
        title: 'Nuevo Hábito',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              spacing: 8,
              children: List.generate(7, (index) {
                final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                return FilterChip(
                  label: Text(dayNames[index]),
                  selected: _selectedDays[index],
                  onSelected: (selected) {
                    setState(() => _selectedDays[index] = selected);
                  },
                  selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                  checkmarkColor: theme.colorScheme.primary,
                );
              }),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveHabit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Guardar Hábito'),
        ),
      ),
    );
  }
}
