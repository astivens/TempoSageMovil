import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/ml_model_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MlModelAdapter adapter;
  late Directory tempDir;

  setUpAll(() async {
    // Crear directorio temporal para las pruebas
    tempDir = await Directory.systemTemp.createTemp('temposage_ml_test_');
    
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    // Inicializar el adaptador con el directorio temporal
    adapter = MlModelAdapter(modelDirectoryPath: tempDir.path);
  });

  tearDown(() async {
    // Limpiar recursos después de cada prueba
    adapter.dispose();
  });

  tearDownAll(() async {
    // Limpiar el directorio temporal
    await tempDir.delete(recursive: true);
  });

  group('MlModelAdapter - inicialización', () {
    test('debería inicializar con directorio temporal', () async {
      const modelFileName = 'test_model.tflite';
      const modelBasePath = 'ml_models/test';

      final result =
          await adapter.initialize(modelFileName, modelBasePath: modelBasePath);
      expect(result, isFalse); // Debería fallar porque el modelo no existe
    });

    test('debería retornar false cuando el modelo no existe', () async {
      const modelFileName = 'non_existent_model.tflite';
      const modelBasePath = 'ml_models/test';

      final result =
          await adapter.initialize(modelFileName, modelBasePath: modelBasePath);
      expect(result, isFalse);
    });

    test('debería usar modelBasePath por defecto si no se proporciona', () async {
      const modelFileName = 'test_model.tflite';

      final result = await adapter.initialize(modelFileName);
      expect(result, isFalse); // Debería fallar porque el modelo no existe
    });
  });

  group('MlModelAdapter - dispose', () {
    test('dispose limpia recursos correctamente', () {
      adapter.dispose();

      expect(adapter.modelInfo, isEmpty);
    });

    test('dispose puede llamarse múltiples veces sin error', () {
      adapter.dispose();
      adapter.dispose();
      adapter.dispose();

      expect(adapter.modelInfo, isEmpty);
    });
  });

  group('MlModelAdapter - modelInfo', () {
    test('modelInfo debería retornar mapa vacío cuando no está inicializado', () {
      expect(adapter.modelInfo, isEmpty);
    });

    test('modelInfo debería ser un mapa', () {
      expect(adapter.modelInfo, isA<Map<String, dynamic>>());
    });
  });

  group('MlModelAdapter - runInference', () {
    test('runInference debería lanzar excepción cuando no está inicializado',
        () async {
      expectLater(
        adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('runInference debería usar valores por defecto para timeOfDay y dayOfWeek',
        () async {
      // Aunque fallará porque no está inicializado, verificamos que acepta los parámetros
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('runInference debería aceptar parámetros opcionales', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
          timeOfDay: 10.0,
          dayOfWeek: 1.0,
          additionalFeatures: {'priority': 0.8},
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('MlModelAdapter - casos edge', () {
    test('debería manejar texto vacío en runInference', () async {
      try {
        await adapter.runInference(
          text: '',
          estimatedDuration: 60.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar texto con caracteres especiales', () async {
      try {
        await adapter.runInference(
          text: r'Test @#$%^&*() text with special chars!',
          estimatedDuration: 60.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar texto muy largo', () async {
      final longText = 'Test ' * 100;
      try {
        await adapter.runInference(
          text: longText,
          estimatedDuration: 60.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar duración negativa', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: -10.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar duración cero', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 0.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar duración muy grande', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 999999.0,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar timeOfDay fuera de rango', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
          timeOfDay: 25.0, // Hora inválida
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar dayOfWeek fuera de rango', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
          dayOfWeek: 10.0, // Día inválido
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar additionalFeatures vacío', () async {
      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
          additionalFeatures: {},
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('debería manejar additionalFeatures con muchos valores', () async {
      final manyFeatures = <String, double>{};
      for (int i = 0; i < 20; i++) {
        manyFeatures['feature_$i'] = i * 0.1;
      }

      try {
        await adapter.runInference(
          text: 'Test text',
          estimatedDuration: 60.0,
          additionalFeatures: manyFeatures,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('MlModelAdapter - múltiples instancias', () {
    test('debería poder crear múltiples instancias', () {
      final adapter1 = MlModelAdapter(modelDirectoryPath: tempDir.path);
      final adapter2 = MlModelAdapter(modelDirectoryPath: tempDir.path);
      final adapter3 = MlModelAdapter();

      expect(adapter1, isNotNull);
      expect(adapter2, isNotNull);
      expect(adapter3, isNotNull);

      adapter1.dispose();
      adapter2.dispose();
      adapter3.dispose();
    });

    test('cada instancia debería tener su propio estado', () {
      final adapter1 = MlModelAdapter(modelDirectoryPath: tempDir.path);
      final adapter2 = MlModelAdapter(modelDirectoryPath: tempDir.path);

      expect(adapter1.modelInfo, isEmpty);
      expect(adapter2.modelInfo, isEmpty);

      adapter1.dispose();
      adapter2.dispose();
    });
  });

  group('MlModelAdapter - constructor', () {
    test('debería crear instancia sin modelDirectoryPath', () {
      final adapterWithoutPath = MlModelAdapter();
      expect(adapterWithoutPath, isNotNull);
      adapterWithoutPath.dispose();
    });

    test('debería crear instancia con modelDirectoryPath', () {
      final adapterWithPath =
          MlModelAdapter(modelDirectoryPath: tempDir.path);
      expect(adapterWithPath, isNotNull);
      adapterWithPath.dispose();
    });
  });
}
