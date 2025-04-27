import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/time_block_model.dart';
import '../../data/repositories/time_block_repository.dart';

class CreateTimeBlockScreen extends StatefulWidget {
  const CreateTimeBlockScreen({super.key});

  @override
  State<CreateTimeBlockScreen> createState() => _CreateTimeBlockScreenState();
}

class _CreateTimeBlockScreenState extends State<CreateTimeBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repository = TimeBlockRepository();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  String _selectedCategory = 'Work';
  bool _isFocusTime = false;
  String _selectedColor = '#9D7CD8'; // Morado por defecto

  final List<String> _categories = ['Work', 'Personal', 'Study', 'Other'];
  final List<Map<String, String>> _colors = [
    {'name': 'Purple', 'value': '#9D7CD8'},
    {'name': 'Blue', 'value': '#7AA2F7'},
    {'name': 'Green', 'value': '#9ECE6A'},
    {'name': 'Red', 'value': '#F7768E'},
    {'name': 'Yellow', 'value': '#E0AF68'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTimeBlock() async {
    if (_formKey.currentState!.validate()) {
      // Crear fechas con año, mes y día correctos
      final DateTime startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final DateTime endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      debugPrint('Creando nuevo TimeBlock...');
      debugPrint('Fecha seleccionada: ${_selectedDate.toString()}');
      debugPrint('Hora inicio: ${_startTime.format(context)}');
      debugPrint('Hora fin: ${_endTime.format(context)}');
      debugPrint('StartDateTime: ${startDateTime.toString()}');

      final timeBlock = TimeBlockModel.create(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        category: _selectedCategory,
        isFocusTime: _isFocusTime,
        color: _selectedColor,
      );

      debugPrint('Agregando timeblock: ${timeBlock.title}');
      await _repository.addTimeBlock(timeBlock);

      // Verificar que se guardó correctamente
      final todayBlocks = await _repository.getTimeBlocksByDate(startDateTime);
      debugPrint(
          'TimeBlocks para hoy después de agregar: ${todayBlocks.length}');

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
            colorScheme: const ColorScheme.dark(
              primary: AppColors.mauve,
              onPrimary: AppColors.text,
              surface: AppColors.surface0,
              onSurface: AppColors.text,
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
            colorScheme: const ColorScheme.dark(
              primary: AppColors.mauve,
              onPrimary: AppColors.text,
              surface: AppColors.surface0,
              onSurface: AppColors.text,
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
          // Ajustar la hora de fin si es necesario
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Create Time Block',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a new time block to your schedule',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter time block title',
                  filled: true,
                  fillColor: AppColors.surface0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppColors.overlay0),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: AppStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Start and End Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.overlay0),
                            const SizedBox(width: 8),
                            Text(
                              'Start: ${_startTime.format(context)}',
                              style: AppStyles.bodyMedium,
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
                          color: AppColors.surface0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.overlay0),
                            const SizedBox(width: 8),
                            Text(
                              'End: ${_endTime.format(context)}',
                              style: AppStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Category
              DropdownButtonFormField<String>(
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
              const SizedBox(height: 16),
              // Focus Time Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface0,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppColors.mauve),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Focus Time',
                        style: AppStyles.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: _isFocusTime,
                      onChanged: (value) {
                        setState(() {
                          _isFocusTime = value;
                        });
                      },
                      activeColor: AppColors.mauve,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Color Selection
              const Text(
                'Color',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color['value']!;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(color['value']!.replaceAll('#', '0xFF')),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color['value']
                              ? AppColors.text
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add details about this time block',
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
              // Create Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: _saveTimeBlock,
                  text: 'Create Time Block',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
