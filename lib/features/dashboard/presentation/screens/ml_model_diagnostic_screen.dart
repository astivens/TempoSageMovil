import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/ml_model_adapter.dart';
import '../../../../core/services/recommendation_service.dart';
import '../../../../core/widgets/widgets.dart';

/// Pantalla de diagnóstico para verificar el funcionamiento del modelo ML
class MLModelDiagnosticScreen extends StatefulWidget {
  const MLModelDiagnosticScreen({super.key});

  @override
  State<MLModelDiagnosticScreen> createState() =>
      _MLModelDiagnosticScreenState();
}

class _MLModelDiagnosticScreenState extends State<MLModelDiagnosticScreen> {
  final TextEditingController _testTextController = TextEditingController();
  final TextEditingController _durationController =
      TextEditingController(text: '60.0');
  bool _isLoading = false;
  bool _isModelInitialized = false;
  Map<String, dynamic> _modelInfo = {};
  Map<String, dynamic>? _lastInferenceResult;
  String? _errorMessage;
  final List<Map<String, dynamic>> _testHistory = [];

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  @override
  void dispose() {
    _testTextController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _checkModelStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mlModelAdapter = GetIt.instance<MlModelAdapter>();

      // Verificar si el servicio está inicializado
      // Intentar obtener información del modelo
      final modelInfo = mlModelAdapter.modelInfo;
      setState(() {
        _isModelInitialized = modelInfo.isNotEmpty;
        _modelInfo = modelInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al verificar estado: $e';
        _isModelInitialized = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _runTestInference() async {
    if (_testTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un texto de prueba'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lastInferenceResult = null;
    });

    try {
      final mlModelAdapter = GetIt.instance<MlModelAdapter>();
      final duration = double.tryParse(_durationController.text) ?? 60.0;
      final now = DateTime.now();

      final result = await mlModelAdapter.runInference(
        text: _testTextController.text.trim(),
        estimatedDuration: duration,
        timeOfDay: now.hour.toDouble(),
        dayOfWeek: (now.weekday - 1).toDouble(),
      );

      setState(() {
        _lastInferenceResult = result;
        _testHistory.insert(0, {
          'timestamp': DateTime.now(),
          'input': _testTextController.text.trim(),
          'duration': duration,
          'result': result,
        });
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inferencia ejecutada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Error en inferencia: $e\n$stackTrace';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recommendationService = GetIt.instance<RecommendationService>();
      await recommendationService.initialize();

      await _checkModelStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modelo inicializado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al inicializar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.detail(
        title: 'Diagnóstico ML',
      ),
      body: _isLoading && _modelInfo.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSection(),
                  const SizedBox(height: 24),
                  _buildModelInfoSection(),
                  const SizedBox(height: 24),
                  _buildTestSection(),
                  if (_lastInferenceResult != null) ...[
                    const SizedBox(height: 24),
                    _buildResultSection(),
                  ],
                  if (_testHistory.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildHistorySection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusSection() {
    return AccessibleCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isModelInitialized
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: _isModelInitialized
                      ? Colors.green
                      : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isModelInitialized
                        ? 'Modelo ML Inicializado'
                        : 'Modelo ML No Inicializado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _checkModelStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Verificar Estado'),
                  ),
                ),
                if (!_isModelInitialized) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _initializeModel,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Inicializar Modelo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelInfoSection() {
    if (!_isModelInitialized || _modelInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    return AccessibleCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información del Modelo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tipo de Modelo', _modelInfo['modelType'] ?? 'N/A'),
            _buildInfoRow(
                'Número de Entradas', '${_modelInfo['inputs'] ?? 0}'),
            _buildInfoRow(
                'Número de Salidas', '${_modelInfo['outputs'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return AccessibleCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prueba de Inferencia',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testTextController,
              decoration: const InputDecoration(
                labelText: 'Texto de prueba',
                hintText: 'Ej: "Hacer ejercicio en el gimnasio"',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duración estimada (minutos)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _runTestInference,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? 'Ejecutando...' : 'Ejecutar Inferencia'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (_lastInferenceResult == null) {
      return const SizedBox.shrink();
    }

    return AccessibleCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultado de la Inferencia',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastInferenceResult!.containsKey('categoryIndex'))
              _buildInfoRow(
                'Categoría Predicha',
                '${_lastInferenceResult!['categoryIndex']}',
              ),
            if (_lastInferenceResult!.containsKey('topScore'))
              _buildInfoRow(
                'Confianza',
                '${(_lastInferenceResult!['topScore'] as double).toStringAsFixed(4)}',
              ),
            if (_lastInferenceResult!.containsKey('duration'))
              _buildInfoRow(
                'Duración Predicha',
                '${(_lastInferenceResult!['duration'] as double).toStringAsFixed(2)} minutos',
              ),
            if (_lastInferenceResult!.containsKey('categoryScores'))
              _buildScoresSection(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultado completo (JSON):',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastInferenceResult.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresSection() {
    final scores = _lastInferenceResult!['categoryScores'] as List<double>?;
    if (scores == null || scores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Puntuaciones por Categoría:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...scores.asMap().entries.map((entry) {
          final index = entry.key;
          final score = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  'Categoría $index:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: score.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  score.toStringAsFixed(4),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHistorySection() {
    return AccessibleCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Historial de Pruebas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._testHistory.take(5).map((test) {
              final timestamp = test['timestamp'] as DateTime;
              final input = test['input'] as String;
              final result = test['result'] as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Input: "$input"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (result.containsKey('categoryIndex'))
                      Text(
                        'Categoría: ${result['categoryIndex']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (result.containsKey('duration'))
                      Text(
                        'Duración: ${(result['duration'] as double).toStringAsFixed(2)} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

