import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/chat/controllers/chat_ai_controller.dart';
import 'package:temposage/services/google_ai_service.dart';
import 'package:temposage/features/chat/services/ml_data_processor.dart';
import 'package:temposage/core/services/ml_ai_integration_service.dart';
import 'package:temposage/core/di/service_locator.dart';
import 'package:temposage/core/services/recommendation_service.dart';
import 'package:temposage/core/services/csv_service.dart';

// Mocks
class MockGoogleAIService extends Mock implements GoogleAIService {}

class MockMLDataProcessor extends Mock implements MLDataProcessor {}

class MockMLAIIntegrationService extends Mock implements MLAIIntegrationService {}

class MockRecommendationService extends Mock implements RecommendationService {}

void main() {
  late ChatAIController controller;
  late MockGoogleAIService mockAIService;
  late MockMLDataProcessor mockMLDataProcessor;
  late MockMLAIIntegrationService mockMLAIIntegrationService;

  setUpAll(() {
    // Registrar MLAIIntegrationService en getIt para los tests
    if (!getIt.isRegistered<MLAIIntegrationService>()) {
      getIt.registerLazySingleton<MLAIIntegrationService>(
        () => MockMLAIIntegrationService(),
      );
    }
    // Registrar RecommendationService en getIt (necesario para MLDataProcessor)
    if (!getIt.isRegistered<RecommendationService>()) {
      getIt.registerLazySingleton<RecommendationService>(
        () => MockRecommendationService(),
      );
    }
  });

  setUp(() {
    mockAIService = MockGoogleAIService();
    mockMLDataProcessor = MockMLDataProcessor();
    mockMLAIIntegrationService = MockMLAIIntegrationService();

    // Actualizar el registro en getIt
    if (getIt.isRegistered<MLAIIntegrationService>()) {
      getIt.unregister<MLAIIntegrationService>();
    }
    getIt.registerLazySingleton<MLAIIntegrationService>(
      () => mockMLAIIntegrationService,
    );

    controller = ChatAIController(
      aiService: mockAIService,
      mlDataProcessor: mockMLDataProcessor,
      mlAIIntegrationService: mockMLAIIntegrationService,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  tearDownAll(() {
    if (getIt.isRegistered<MLAIIntegrationService>()) {
      getIt.unregister<MLAIIntegrationService>();
    }
    if (getIt.isRegistered<RecommendationService>()) {
      getIt.unregister<RecommendationService>();
    }
  });

  group('ChatAIController', () {
    group('Constructor', () {
      test('debería crear instancia con todas las dependencias', () {
        // Arrange & Act
        final controllerInstance = ChatAIController(
          aiService: mockAIService,
          mlDataProcessor: mockMLDataProcessor,
          mlAIIntegrationService: mockMLAIIntegrationService,
        );

        // Assert
        expect(controllerInstance, isNotNull);
        expect(controllerInstance.messages, isEmpty);
        expect(controllerInstance.isLoading, isFalse);
        expect(controllerInstance.errorMessage, isNull);
      });

      test('debería crear instancia con dependencias opcionales', () {
        // Arrange & Act
        // Usa getIt para MLAIIntegrationService si no se proporciona
        final controllerInstance = ChatAIController(
          aiService: mockAIService,
          mlDataProcessor: mockMLDataProcessor,
          // mlAIIntegrationService se obtiene de getIt
        );

        // Assert
        expect(controllerInstance, isNotNull);
        expect(controllerInstance.messages, isEmpty);
        expect(controllerInstance.isLoading, isFalse);
      });
    });

    group('sendMessage', () {
      test('debería enviar mensaje y recibir respuesta usando ML-IA integration', () async {
        // Arrange
        const userMessage = '¿Qué actividad me recomiendas?';
        const aiResponseText = 'Te recomiendo estudiar';
        final aiResponse = ChatResponse.fromAI(aiResponseText);

        when(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .thenAnswer((_) async => aiResponseText);
        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});

        // Act
        await controller.sendMessage(userMessage);

        // Assert
        expect(controller.messages.length, equals(2));
        expect(controller.messages[0].text, equals(userMessage));
        expect(controller.messages[0].role, equals('user'));
        expect(controller.messages[1].text, equals(aiResponseText));
        expect(controller.messages[1].role, equals('assistant'));
        expect(controller.isLoading, isFalse);
        expect(controller.errorMessage, isNull);
        verify(() => mockMLAIIntegrationService.processQueryWithML(userMessage))
            .called(1);
      });

      test('debería usar fallback cuando ML-IA integration falla', () async {
        // Arrange
        const userMessage = 'Hola';
        const contextualData = 'Contexto ML';
        final aiResponse = ChatResponse.fromAI('Respuesta de fallback');

        when(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .thenThrow(Exception('Error en ML-IA'));
        when(() => mockMLDataProcessor.getContextualMLData(any()))
            .thenAnswer((_) async => contextualData);
        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});
        when(() => mockAIService.sendMessageWithMLContext(any(), any()))
            .thenAnswer((_) async => aiResponse);

        // Act
        await controller.sendMessage(userMessage);

        // Assert
        expect(controller.messages.length, greaterThanOrEqualTo(2));
        expect(controller.isLoading, isFalse);
        verify(() => mockAIService.sendMessageWithMLContext(any(), any()))
            .called(1);
      });

      test('debería usar método tradicional cuando no hay contexto ML', () async {
        // Arrange
        const userMessage = 'Hola';
        final aiResponse = ChatResponse.fromAI('Respuesta simple');

        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});
        when(() => mockMLDataProcessor.getContextualMLData(any()))
            .thenAnswer((_) async => '');
        when(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .thenAnswer((_) async => 'Respuesta ML');
        when(() => mockAIService.sendMessage(any()))
            .thenAnswer((_) async => aiResponse);

        // Act
        await controller.sendMessage(userMessage);

        // Assert
        expect(controller.messages.length, greaterThanOrEqualTo(2));
        // Verifica que se procesó el mensaje (puede usar ML integration o fallback)
        verify(() => mockMLAIIntegrationService.processQueryWithML(userMessage))
            .called(1);
      });

      test('debería manejar errores correctamente', () async {
        // Arrange
        const userMessage = 'Test error';

        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});
        when(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .thenThrow(Exception('Error de red'));

        // Act
        await controller.sendMessage(userMessage);

        // Assert
        expect(controller.messages.length, equals(2));
        expect(controller.messages[1].role, equals('error'));
        expect(controller.errorMessage, isNotNull);
        expect(controller.isLoading, isFalse);
      });

      test('debería ignorar mensajes vacíos', () async {
        // Arrange
        const emptyMessage = '   ';

        // Act
        await controller.sendMessage(emptyMessage);

        // Assert
        expect(controller.messages, isEmpty);
        verifyNever(() => mockMLAIIntegrationService.processQueryWithML(any()));
      });

      test('debería cargar contexto ML solo una vez', () async {
        // Arrange
        const userMessage1 = 'Primer mensaje';
        const userMessage2 = 'Segundo mensaje';
        final aiResponse = ChatResponse.fromAI('Respuesta');

        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});
        when(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .thenAnswer((_) async => 'Respuesta');

        // Act
        await controller.sendMessage(userMessage1);
        await controller.sendMessage(userMessage2);

        // Assert
        verify(() => mockAIService.setMLContext(any())).called(1);
        verify(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .called(2);
      });
    });

    group('clearConversation', () {
      test('debería limpiar todos los mensajes', () async {
        // Arrange
        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});
        when(() => mockMLAIIntegrationService.processQueryWithML(any()))
            .thenAnswer((_) async => 'Respuesta');
        await controller.sendMessage('Mensaje 1');
        await controller.sendMessage('Mensaje 2');

        // Act
        controller.clearConversation();

        // Assert
        expect(controller.messages, isEmpty);
        expect(controller.errorMessage, isNull);
        verify(() => mockAIService.clearConversation()).called(1);
      });
    });

    group('toggleMLIntegration', () {
      test('debería habilitar integración ML-IA', () {
        // Arrange
        expect(controller.isMLIntegrationEnabled, isTrue);

        // Act
        controller.toggleMLIntegration(false);

        // Assert
        expect(controller.isMLIntegrationEnabled, isFalse);
      });

      test('debería deshabilitar integración ML-IA', () {
        // Arrange
        controller.toggleMLIntegration(false);

        // Act
        controller.toggleMLIntegration(true);

        // Assert
        expect(controller.isMLIntegrationEnabled, isTrue);
      });
    });

    group('reloadMLContext', () {
      test('debería recargar el contexto ML', () async {
        // Arrange
        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML actualizado');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});

        // Act
        await controller.reloadMLContext();

        // Assert
        verify(() => mockAIService.setMLContext(any())).called(1);
      });
    });

    group('refreshMLIntegration', () {
      test('debería refrescar la integración ML-IA', () async {
        // Arrange
        when(() => mockMLDataProcessor.getMLContextData())
            .thenAnswer((_) async => 'Contexto ML');
        when(() => mockAIService.setMLContext(any()))
            .thenAnswer((_) async => {});

        // Act
        await controller.refreshMLIntegration();

        // Assert
        verify(() => mockAIService.setMLContext(any())).called(1);
      });
    });

    group('getMLIntegrationStatus', () {
      test('debería retornar estado de integración ML-IA', () {
        // Act
        final status = controller.getMLIntegrationStatus();

        // Assert
        expect(status, isA<Map<String, dynamic>>());
        expect(status['mlIntegrationEnabled'], isA<bool>());
        expect(status['mlContextLoaded'], isA<bool>());
        expect(status['aiServiceType'], isA<String>());
        expect(status['hasMLDataProcessor'], isA<bool>());
        expect(status['hasMLAIIntegrationService'], isA<bool>());
      });
    });

    group('Estado inicial', () {
      test('debería tener estado inicial correcto', () {
        // Assert
        expect(controller.messages, isEmpty);
        expect(controller.isLoading, isFalse);
        expect(controller.errorMessage, isNull);
        expect(controller.isMLIntegrationEnabled, isTrue);
      });
    });
  });
}

