import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:temposage/core/constants/app_colors.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/features/habits/domain/entities/habit.dart';
import 'package:temposage/features/habits/presentation/widgets/habit_card.dart';
import 'package:temposage/core/widgets/custom_app_bar.dart';

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
      final habitsEntities = await _repository.getAllHabits();
      setState(() {
        _habits =
            habitsEntities.map(_mapEntityToModel).toList().cast<HabitModel>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Métodos para convertir entre entidad y modelo
  HabitModel _mapEntityToModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      title: entity.name,
      description: entity.description,
      daysOfWeek: entity.daysOfWeek,
      category: entity.category,
      reminder: entity.reminder,
      time: entity.time,
      isCompleted: entity.isDone,
      dateCreation: entity.dateCreation,
      lastCompleted: null,
      streak: 0,
      totalCompletions: 0,
    );
  }

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

  Future<void> _showAddHabitDialog() async {
    final result = await showDialog<HabitModel>(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );

    if (result != null) {
      final habitEntity = _mapModelToEntity(result);
      await _repository.addHabit(habitEntity);
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${habit.title} eliminado'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.mocha.red
                  : AppColors.latte.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.habits,
        showBackButton: false,
        titleStyle: TextStyle(
          color: theme.colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onBackground),
            onPressed: _showAddHabitDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary))
          : _habits.isEmpty
              ? Center(
                  child: Text(
                    l10n.noHabits,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
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
                        final habitEntity = _mapModelToEntity(habit);
                        final updatedEntity =
                            habitEntity.copyWith(isDone: true);
                        await _repository.updateHabit(updatedEntity);
                        if (mounted) {
                          _loadHabits();
                        }
                      },
                      onDelete: () => _deleteHabit(habit),
                    );
                  },
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
              if (_selectedDays[i]) selectedDays.add(i + 1);
            }

            if (_titleController.text.isNotEmpty && selectedDays.isNotEmpty) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              // Convertir los días de la semana de enteros a strings
              final daysOfWeekStr = selectedDays.map((day) {
                const days = [
                  'Lunes',
                  'Martes',
                  'Miércoles',
                  'Jueves',
                  'Viernes',
                  'Sábado',
                  'Domingo'
                ];
                return days[day - 1];
              }).toList();

              // Formatear la hora como string (HH:MM)
              final timeStr =
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

              debugPrint('Creando hábito para días: $daysOfWeekStr');

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
                reminder: 'none', // Valor por defecto
              );

              debugPrint(
                  'Hábito creado: ${habit.title} - Días: ${habit.daysOfWeek}');
              Navigator.of(context).pop(habit);
            } else {
              debugPrint(
                  'No se pudo crear el hábito: título vacío o sin días seleccionados');
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
