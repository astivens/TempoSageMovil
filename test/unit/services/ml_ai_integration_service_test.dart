import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/core/services/ml_ai_integration_service.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/core/services/csv_service.dart';
import 'package:temposage/core/services/ml_model_adapter.dart';
import 'package:temposage/services/google_ai_service.dart';
import 'package:temposage/core/models/productive_block.dart';

// Mocks
class MockRecommendationService extends Mock implements RecommendationService {}

class MockCSVService extends Mock implements CSVService {}

class MockGoogleAIService extends Mock implements GoogleAIService {}

class MockMlModelAdapter extends Mock implements MlModelAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MLAIIntegrationService service;
  late MockRecommendationService mockRecommendationService;
  late MockCSVService mockCSVService;
  late MockGoogleAIService mockGoogleAIService;
  late MockMlModelAdapter mockMlModelAdapter;

  setUpAll(() {
    // Registrar fallback values para mocktail
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(ProductiveBlock(
      weekday: 1,
      hour: 9,
      category: 'Trabajo',
      completionRate: 0.8,
    ));
  });

  setUp(() {
    mockRecommendationService = MockRecommendationService();
    mockCSVService = MockCSVService();
    mockGoogleAIService = MockGoogleAIService();
    mockMlModelAdapter = MockMlModelAdapter();

    service = MLAIIntegrationService(
      recommendationService: mockRecommendationService,
      csvService: mockCSVService,
      googleAIService: mockGoogleAIService,
      mlModelAdapter: mockMlModelAdapter,
    );
  });

  group('MLAIIntegrationService', () {
    group('processQueryWithML', () {
      test('debería procesar consulta de recomendación correctamente', () async {
        // Arrange
        const userQuery = '¿Qué actividad me recomiendas?';
        final mockRecommendations = [
          {'title': 'Estudiar', 'category': 'Estudio', 'score': 0.9},
          {'title': 'Ejercicio', 'category': 'Salud', 'score': 0.8},
        ];
        final mockResponse = ChatResponse.fromAI('Te recomiendo estudiar');

        when(() => mockRecommendationService.getRecommendations())
            .thenAnswer((_) async => mockRecommendations);
        when(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockMlModelAdapter.runInference(
              text: any(named: 'text'),
              estimatedDuration: any(named: 'estimatedDuration'),
            )).thenAnswer((_) async => <String, dynamic>{
          'categoryIndex': 0,
          'confidence': 0.9,
        });

        // Act
        final result = await service.processQueryWithML(userQuery);

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains('Te recomiendo'));
        verify(() => mockRecommendationService.getRecommendations()).called(1);
        verify(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .called(1);
      });

      test('debería procesar consulta de horario correctamente', () async {
        // Arrange
        const userQuery = '¿Cuándo es el mejor momento para estudiar?';
        final mockBlocks = [
          ProductiveBlock(
            weekday: 1,
            hour: 9,
            category: 'Estudio',
            completionRate: 0.9,
          ),
          ProductiveBlock(
            weekday: 1,
            hour: 14,
            category: 'Estudio',
            completionRate: 0.85,
          ),
        ];
        final mockStats = [
          ProductiveBlock(
            weekday: 1,
            hour: 9,
            category: 'Estudio',
            completionRate: 0.9,
          ),
        ];
        final mockResponse = ChatResponse.fromAI('El mejor momento es a las 9 AM');

        when(() => mockCSVService.loadTop3Blocks())
            .thenAnswer((_) async => mockBlocks);
        when(() => mockCSVService.loadAllBlocksStats())
            .thenAnswer((_) async => mockStats);
        when(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockMlModelAdapter.runInference(
              text: any(named: 'text'),
              estimatedDuration: any(named: 'estimatedDuration'),
              timeOfDay: any(named: 'timeOfDay'),
              dayOfWeek: any(named: 'dayOfWeek'),
            )).thenAnswer((_) async => <String, dynamic>{
          'optimalTime': 9,
          'optimalDay': 1,
        });

        // Act
        final result = await service.processQueryWithML(userQuery);

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockCSVService.loadTop3Blocks()).called(1);
        verify(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .called(1);
      });

      test('debería retornar respuesta genérica cuando no hay datos ML', () async {
        // Arrange
        const userQuery = 'Hola';
        when(() => mockRecommendationService.getRecommendations())
            .thenAnswer((_) async => []);
        when(() => mockCSVService.loadTop3Blocks())
            .thenAnswer((_) async => []);
        when(() => mockCSVService.loadAllBlocksStats())
            .thenAnswer((_) async => []);

        // Act
        final result = await service.processQueryWithML(userQuery);

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains('TempoSage AI'));
      });

      test('debería manejar errores correctamente', () async {
        // Arrange
        const userQuery = 'Test error';
        when(() => mockRecommendationService.getRecommendations())
            .thenThrow(Exception('Error de red'));

        // Act
        final result = await service.processQueryWithML(userQuery);

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains('TempoSage AI'));
      });

      test('debería procesar consulta de análisis correctamente', () async {
        // Arrange
        const userQuery = 'Muéstrame estadísticas de productividad';
        final mockStats = [
          ProductiveBlock(
            weekday: 1,
            hour: 9,
            category: 'Trabajo',
            completionRate: 0.8,
          ),
          ProductiveBlock(
            weekday: 1,
            hour: 10,
            category: 'Trabajo',
            completionRate: 0.75,
          ),
        ];
        final mockResponse = ChatResponse.fromAI('Estadísticas de productividad');

        when(() => mockCSVService.loadAllBlocksStats())
            .thenAnswer((_) async => mockStats);
        when(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.processQueryWithML(userQuery);

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockCSVService.loadAllBlocksStats()).called(1);
      });

      test('debería procesar consulta de clasificación correctamente', () async {
        // Arrange
        const userQuery = 'Clasifica esta actividad';
        final mockResponse = ChatResponse.fromAI('Actividad clasificada');

        when(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockMlModelAdapter.runInference(
              text: any(named: 'text'),
              estimatedDuration: any(named: 'estimatedDuration'),
            )).thenAnswer((_) async => <String, dynamic>{
          'categoryIndex': 2,
          'confidence': 0.85,
        });

        // Act
        final result = await service.processQueryWithML(userQuery);

        // Assert
        expect(result, isNotEmpty);
        verify(() => mockGoogleAIService.sendMessageWithMLContext(any(), any()))
            .called(1);
      });
    });

    group('Constructor', () {
      test('debería crear instancia con todas las dependencias', () {
        // Arrange & Act
        final serviceInstance = MLAIIntegrationService(
          recommendationService: mockRecommendationService,
          csvService: mockCSVService,
          googleAIService: mockGoogleAIService,
          mlModelAdapter: mockMlModelAdapter,
        );

        // Assert
        expect(serviceInstance, isNotNull);
      });

      test('debería crear instancia sin mlModelAdapter', () {
        // Arrange & Act
        final serviceInstance = MLAIIntegrationService(
          recommendationService: mockRecommendationService,
          csvService: mockCSVService,
          googleAIService: mockGoogleAIService,
        );

        // Assert
        expect(serviceInstance, isNotNull);
      });
    });
  });
}

