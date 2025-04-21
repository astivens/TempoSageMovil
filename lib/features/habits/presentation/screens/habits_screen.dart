import 'package:flutter/material.dart';
import 'package:temposage/core/constants/app_colors.dart';
import 'package:temposage/core/constants/app_styles.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/presentation/widgets/habit_card.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _repository = ServiceLocator.instance.habitRepository;
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    try {
      final habits = await _repository.getHabits();
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddHabitDialog() async {
    final result = await showDialog<HabitModel>(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );

    if (result != null) {
      await _repository.createHabit(result);
      _loadHabits();
    }
  }

  Future<void> _deleteHabit(HabitModel habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content:
            Text('¿Estás seguro de que quieres eliminar "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteHabit(habit.id);
        _loadHabits();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${habit.title} eliminado'),
            backgroundColor: AppColors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hábitos',
                    style: AppStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddHabitDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _habits.isEmpty
                      ? Center(
                          child: Text(
                            'No hay hábitos',
                            style: AppStyles.bodyLarge.copyWith(
                              color: AppColors.overlay0,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return HabitCard(
                              habit: habit,
                              onComplete: () async {
                                await _repository
                                    .markHabitAsCompleted(habit.id);
                                _loadHabits();
                              },
                              onDelete: () => _deleteHabit(habit),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Hábito'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Meditar',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Meditar 10 minutos por la mañana',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Hora'),
              trailing: TextButton(
                onPressed: _selectTime,
                child: Text(_selectedTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Días de la semana'),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                    selected: _selectedDays[i],
                    onSelected: (selected) {
                      setState(() => _selectedDays[i] = selected);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final selectedDays = <int>[];
            for (int i = 0; i < 7; i++) {
              if (_selectedDays[i]) selectedDays.add(i);
            }

            if (_titleController.text.isNotEmpty && selectedDays.isNotEmpty) {
              final habit = HabitModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                description: _descriptionController.text,
                startTime: DateTime.now(),
                endTime: DateTime.now().add(const Duration(hours: 1)),
                category: 'Hábito',
                isCompleted: false,
                streak: 0,
                completedDates: [],
                daysOfWeek: selectedDays,
                lastCompleted: null,
                totalCompletions: 0,
                time: _selectedTime,
                createdAt: DateTime.now(),
              );
              Navigator.of(context).pop(habit);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
