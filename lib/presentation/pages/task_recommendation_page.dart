import 'package:flutter/material.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/models/productive_block.dart';
import 'package:temposage/core/constants/app_colors.dart';

class TaskRecommendationPage extends StatefulWidget {
  const TaskRecommendationPage({super.key});

  @override
  State<TaskRecommendationPage> createState() => _TaskRecommendationPageState();
}

class _TaskRecommendationPageState extends State<TaskRecommendationPage> {
  final RecommendationService _recommendationService = RecommendationService();
  final CSVService _csvService = CSVService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController =
      TextEditingController(text: '60');

  double _priority = 3;
  double _energyLevel = 0.5;
  double _moodLevel = 0.5;

  TaskPrediction? _prediction;
  List<ProductiveBlock> _top3Blocks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _recommendationService.initialize();

      // Cargar bloques por defecto
      _top3Blocks = await _csvService.loadTop3Blocks();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al inicializar el servicio: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _predictTask() async {
    if (_descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa una descripción';
      });
      return;
    }

    final duration = double.tryParse(_durationController.text) ?? 60.0;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prediction = await _recommendationService.predictTaskDetails(
        description: _descriptionController.text,
        estimatedDuration: duration,
        priority: _priority.round(),
        energyLevel: _energyLevel,
        moodLevel: _moodLevel,
      );

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al predecir la tarea: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    _recommendationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.mocha.base : AppColors.latte.base,
      appBar: AppBar(
        title: const Text('Recomendación de Tareas'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputForm(),
              const SizedBox(height: 24.0),
              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analizando datos y generando recomendaciones...'),
                    ],
                  ),
                ),
              if (_errorMessage != null) _buildErrorMessage(),
              if (_prediction != null && !_isLoading) _buildPredictionResult(),
              if (!_isLoading && _prediction == null) _buildProductiveBlocks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? AppColors.mocha.mantle : AppColors.latte.base,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Describe tu tarea',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Semantics(
              label: 'Descripción de la tarea',
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción de la tarea',
                  hintText: 'Ej. Preparar informe de ventas',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDarkMode
                      ? AppColors.mocha.surface0
                      : AppColors.latte.surface0,
                  prefixIcon: const Icon(Icons.description),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 16.0),
            Semantics(
              label: 'Duración estimada en minutos',
              child: TextField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Duración estimada (minutos)',
                  hintText: 'Ej. 60',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDarkMode
                      ? AppColors.mocha.surface0
                      : AppColors.latte.surface0,
                  prefixIcon: const Icon(Icons.timer),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 24.0),
            _buildContextSection(),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _predictTask,
                icon: const Icon(Icons.analytics),
                label: const Text('Predecir y Recomendar'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contexto personal',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16.0),
        _buildSlider(
          label: 'Prioridad',
          value: _priority,
          min: 1,
          max: 5,
          divisions: 4,
          formatValue: (value) => value.round().toString(),
          icon: Icons.priority_high,
          onChanged: (value) {
            setState(() {
              _priority = value;
            });
          },
        ),
        const SizedBox(height: 16.0),
        _buildSlider(
          label: 'Nivel de energía',
          value: _energyLevel,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          formatValue: (value) => '${(value * 100).round()}%',
          icon: Icons.battery_charging_full,
          onChanged: (value) {
            setState(() {
              _energyLevel = value;
            });
          },
        ),
        const SizedBox(height: 16.0),
        _buildSlider(
          label: 'Estado de ánimo',
          value: _moodLevel,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          formatValue: (value) => '${(_moodLevel * 100).round()}%',
          icon: Icons.mood,
          onChanged: (value) {
            setState(() {
              _moodLevel = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) formatValue,
    required IconData icon,
    required Function(double) onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '$label: ${formatValue(value)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            trackShape: const RoundedRectSliderTrackShape(),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorTextStyle: TextStyle(
              color: isDarkMode ? AppColors.mocha.text : AppColors.latte.text,
            ),
          ),
          child: Semantics(
            label: '$label: ${formatValue(value)}',
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: formatValue(value),
              onChanged: onChanged,
              semanticFormatterCallback: formatValue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[900]),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionResult() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: colorScheme.secondary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultados del Análisis',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Basado en tus datos y patrones de productividad',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildPredictionDetail(
              icon: Icons.category,
              title: 'Categoría',
              value: _prediction!.category,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _buildPredictionDetail(
              icon: Icons.timelapse,
              title: 'Duración Estimada',
              value:
                  '${_prediction!.estimatedDuration.toStringAsFixed(0)} minutos',
              color: colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Bloque Horario Sugerido',
              child: Text(
                'Bloque Horario Sugerido',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            _prediction!.suggestedDateTime != null
                ? _buildSuggestedTimeCard(_prediction!.suggestedDateTime!)
                : const Text('No hay bloque sugerido disponible.'),
            if (_prediction!.suggestedBlocks.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildProductiveBlocksList(_prediction!.suggestedBlocks),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionDetail({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedTimeCard(DateTime dateTime) {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final day = days[dateTime.weekday - 1];
    final hour =
        dateTime.hour < 10 ? '0${dateTime.hour}:00' : '${dateTime.hour}:00';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Día recomendado: $day a las $hour',
      child: Card(
        elevation: 2,
        color: isDarkMode
            ? AppColors.mocha.blue.withOpacity(0.2)
            : AppColors.latte.blue.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue,
                size: 32,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'a las $hour',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.mocha.green.withOpacity(0.3)
                      : AppColors.latte.green.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: isDarkMode
                      ? AppColors.mocha.green
                      : AppColors.latte.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductiveBlocksList(List<ProductiveBlock> blocks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Bloques más productivos para esta categoría',
          child: Text(
            'Bloques más productivos para esta categoría',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children:
              blocks.map((block) => _buildProductiveBlockItem(block)).toList(),
        ),
      ],
    );
  }

  Widget _buildProductiveBlockItem(ProductiveBlock block) {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final dayName = block.weekday >= 0 && block.weekday < days.length
        ? days[block.weekday]
        : 'Desconocido';
    final hourFormatted =
        block.hour < 10 ? '0${block.hour}:00' : '${block.hour}:00';
    final percentage = (block.completionRate * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Semantics(
        label:
            'Bloque productivo: $dayName a las $hourFormatted, tasa de completado $percentage por ciento',
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorForCompletionRate(block.completionRate),
            child: Text(
              percentage.split('.')[0] + '%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            '$dayName a las $hourFormatted',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: block.category != null
              ? Text('Categoría: ${block.category}')
              : null,
          trailing: block.isProductiveBlock
              ? Tooltip(
                  message: 'Bloque altamente productivo',
                  child: Icon(Icons.star, color: Colors.amber),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }

  Widget _buildProductiveBlocks() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8.0),
                Text(
                  'Bloques más productivos',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Basado en tu historial de actividades y patrones de productividad',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            _top3Blocks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Cargando bloques productivos...'),
                    ),
                  )
                : Column(
                    children: _top3Blocks
                        .map((block) => _buildProductiveBlockItem(block))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCompletionRate(double rate) {
    if (rate >= 0.8) return Colors.green[700]!;
    if (rate >= 0.6) return Colors.green[400]!;
    if (rate >= 0.4) return Colors.orange;
    if (rate >= 0.2) return Colors.deepOrange;
    return Colors.red;
  }
}
