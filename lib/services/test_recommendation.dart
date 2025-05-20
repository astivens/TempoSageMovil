import 'package:flutter/material.dart';
import 'activity_recommendation_controller.dart';

class TestRecommendationPage extends StatefulWidget {
  const TestRecommendationPage({super.key});

  @override
  State<TestRecommendationPage> createState() => _TestRecommendationPageState();
}

class _TestRecommendationPageState extends State<TestRecommendationPage> {
  final ActivityRecommendationController _controller =
      ActivityRecommendationController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _controller.initialize();
      if (mounted) {
        await _controller.getRecommendations();
      }
    } catch (e) {
      print('Error en la prueba de recomendación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Recomendación TiSASRec'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.resultMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _controller.isLoading
                        ? Colors.blue
                        : (_controller.recommendations.isEmpty
                            ? Colors.red
                            : Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                if (_controller.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_controller.recommendations.isEmpty)
                  const Text('No se encontraron recomendaciones')
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actividades Recomendadas:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _controller.recommendations.length,
                            itemBuilder: (context, index) {
                              final itemId = _controller.recommendations[index];
                              return ListTile(
                                leading: const Icon(Icons.recommend),
                                title:
                                    Text(_controller.getActivityTitle(itemId)),
                                subtitle: Text(
                                    'Categoría: ${_controller.getActivityCategory(itemId)}'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _controller.isLoading ? null : _controller.getRecommendations,
        tooltip: 'Recargar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
