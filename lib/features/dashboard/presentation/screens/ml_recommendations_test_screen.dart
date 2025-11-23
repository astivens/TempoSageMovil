import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/navigation/app_router.dart';
import 'ml_model_diagnostic_screen.dart';

class MLRecommendationsTestScreen extends StatefulWidget {
  const MLRecommendationsTestScreen({super.key});

  @override
  State<MLRecommendationsTestScreen> createState() =>
      _MLRecommendationsTestScreenState();
}

class _MLRecommendationsTestScreenState
    extends State<MLRecommendationsTestScreen> {
  final List<MLRecommendationCard> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _generateTestRecommendations();
  }

  void _generateTestRecommendations() {
    _recommendations.addAll([
      MLRecommendationCard(
        title: 'Momento ideal para ejercicio',
        description:
            'Basado en tu historial, las 7:00 AM es tu hora más productiva para actividades físicas. ¿Te animas a hacer ejercicio ahora?',
        icon: Icons.fitness_center_outlined,
        type: RecommendationType.activity,
        onAccept: () => _handleAcceptRecommendation('exercise'),
        onDismiss: () => _handleDismissRecommendation('exercise'),
      ),
      MLRecommendationCard(
        title: 'Tiempo de hidratación',
        description:
            'Has estado trabajando por 2 horas. Es un buen momento para tomar agua y hacer una pausa de 5 minutos.',
        icon: Icons.local_drink_outlined,
        type: RecommendationType.habit,
        onAccept: () => _handleAcceptRecommendation('hydration'),
        onDismiss: () => _handleDismissRecommendation('hydration'),
      ),
      MLRecommendationCard(
        title: 'Bloque de trabajo profundo',
        description:
            'Tienes 3 tareas importantes pendientes. Te sugiero crear un bloque de 2 horas para trabajo concentrado.',
        icon: Icons.psychology_outlined,
        type: RecommendationType.timeBlock,
        onAccept: () => _handleAcceptRecommendation('deep_work'),
        onDismiss: () => _handleDismissRecommendation('deep_work'),
      ),
      MLRecommendationCard(
        title: 'Pausa para meditar',
        description:
            'Tu nivel de estrés parece elevado. Una sesión de meditación de 10 minutos podría ayudarte a relajarte.',
        icon: Icons.self_improvement_outlined,
        type: RecommendationType.habit,
        onAccept: () => _handleAcceptRecommendation('meditation'),
        onDismiss: () => _handleDismissRecommendation('meditation'),
      ),
      MLRecommendationCard(
        title: 'Revisar objetivos semanales',
        description:
            'Es viernes y es un buen momento para revisar tus objetivos de la semana y planificar la siguiente.',
        icon: Icons.flag_outlined,
        type: RecommendationType.activity,
        onAccept: () => _handleAcceptRecommendation('weekly_review'),
        onDismiss: () => _handleDismissRecommendation('weekly_review'),
      ),
    ]);
  }

  void _handleAcceptRecommendation(String recommendationId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recomendación "$recommendationId" aceptada'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDismissRecommendation(String recommendationId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recomendación "$recommendationId" descartada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.detail(
        title: 'Recomendaciones ML',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado explicativo
            AccessibleCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recomendaciones Inteligentes',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estas recomendaciones se generan basándose en tus patrones de actividad, horarios más productivos y objetivos personales.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contenedor de recomendaciones
            MLRecommendationContainer(
              title: 'Recomendaciones para ti',
              recommendations: _recommendations,
            ),

            const SizedBox(height: 24),

            // Sección de estadísticas de ML
            AccessibleCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estadísticas de Aprendizaje',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('Recomendaciones aceptadas', '12'),
                    const SizedBox(height: 8),
                    _buildStatRow('Precisión del modelo', '87%'),
                    const SizedBox(height: 8),
                    _buildStatRow('Días de datos analizados', '45'),
                    const SizedBox(height: 8),
                    _buildStatRow('Patrones identificados', '8'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _generateTestRecommendations(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generar Nuevas'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AccessibleButton.primary(
                        text: 'Volver',
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.arrow_back,
                      ),
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MLModelDiagnosticScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Diagnóstico del Modelo ML'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 100), // Espacio adicional
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
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
    );
  }
}
