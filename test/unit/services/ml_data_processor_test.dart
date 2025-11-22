import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/chat/services/ml_data_processor.dart';
import 'package:temposage/services/tflite_service.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/services/ml_model_adapter.dart';
import 'package:temposage/core/models/productive_block.dart';

class MockTFLiteService extends Mock implements TFLiteService {}

class MockRecommendationService extends Mock implements RecommendationService {}

class MockCSVService extends Mock implements CSVService {}

class MockMlModelAdapter extends Mock implements MlModelAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MLDataProcessor Tests', () {
    late MLDataProcessor processor;
    late MockTFLiteService mockTFLiteService;
    late MockRecommendationService mockRecommendationService;
    late MockCSVService mockCSVService;
    late MockMlModelAdapter mockMlModelAdapter;

    setUp(() {
      mockTFLiteService = MockTFLiteService();
      mockRecommendationService = MockRecommendationService();
      mockCSVService = MockCSVService();
      mockMlModelAdapter = MockMlModelAdapter();

      processor = MLDataProcessor(
        tfliteService: mockTFLiteService,
        recommendationService: mockRecommendationService,
        csvService: mockCSVService,
        mlModelAdapter: mockMlModelAdapter,
      );
    });

    test('debería inicializar con servicios inyectados', () {
      // Act
      final injectedProcessor = MLDataProcessor(
        recommendationService: mockRecommendationService,
        csvService: mockCSVService,
      );

      // Assert
      expect(injectedProcessor, isNotNull);
    });

    test('getMLContextData debería retornar contexto ML completo', () async {
      // Arrange
      when(() => mockCSVService.loadTop3Blocks())
          .thenAnswer((_) async => []);
      when(() => mockCSVService.loadAllBlocksStats())
          .thenAnswer((_) async => []);
      when(() => mockRecommendationService.getRecommendations())
          .thenAnswer((_) async => []);

      // Act
      final context = await processor.getMLContextData();

      // Assert
      expect(context, isNotEmpty);
      expect(context, contains('TEMPOSAGE ML CONTEXT'));
      expect(context, contains('CATEGORÍAS DISPONIBLES'));
      expect(context, contains('PATRONES DE PRODUCTIVIDAD'));
    });

    test('getMLContextData debería manejar errores correctamente', () async {
      // Arrange
      when(() => mockCSVService.loadTop3Blocks())
          .thenThrow(Exception('Error de carga'));

      // Act
      final context = await processor.getMLContextData();

      // Assert
      expect(context, isNotEmpty);
      expect(context, contains('TEMPOSAGE ML CONTEXT'));
    });

    test('getContextualMLData debería retornar contexto para recomendaciones',
        () async {
      // Arrange
      when(() => mockRecommendationService.getRecommendations())
          .thenAnswer((_) async => []);

      // Act
      final context =
          await processor.getContextualMLData('recomendar actividad');

      // Assert
      expect(context, isNotEmpty);
      expect(context, contains('RECOMENDACIONES INTELIGENTES'));
    });

    test('getContextualMLData debería retornar contexto para horarios',
        () async {
      // Act
      final context = await processor.getContextualMLData('horario óptimo');

      // Assert
      expect(context, isNotEmpty);
    });

    test('getContextualMLData debería retornar contexto para productividad',
        () async {
      // Arrange
      when(() => mockCSVService.loadTop3Blocks())
          .thenAnswer((_) async => []);
      when(() => mockCSVService.loadAllBlocksStats())
          .thenAnswer((_) async => []);

      // Act
      final context =
          await processor.getContextualMLData('estadísticas de productividad');

      // Assert
      expect(context, isNotEmpty);
      expect(context, contains('PATRONES DE PRODUCTIVIDAD'));
    });

    test('getMLContextData debería incluir información de TFLite cuando está disponible',
        () async {
      // Arrange
      when(() => mockTFLiteService.labels).thenReturn(['trabajo', 'salud']);
      when(() => mockTFLiteService.runInference(
            taskDescription: any(named: 'taskDescription'),
            estimatedDuration: any(named: 'estimatedDuration'),
            startHour: any(named: 'startHour'),
            startWeekday: any(named: 'startWeekday'),
            oheValues: any(named: 'oheValues'),
          )).thenAnswer((_) async => {
        'category': 'trabajo',
        'duration': 2.0,
      });
      when(() => mockCSVService.loadTop3Blocks())
          .thenAnswer((_) async => []);
      when(() => mockCSVService.loadAllBlocksStats())
          .thenAnswer((_) async => []);
      when(() => mockRecommendationService.getRecommendations())
          .thenAnswer((_) async => []);

      // Act
      final context = await processor.getMLContextData();

      // Assert
      expect(context, contains('CAPACIDADES DEL MODELO ML'));
      expect(context, contains('trabajo'));
    });
  });
}

