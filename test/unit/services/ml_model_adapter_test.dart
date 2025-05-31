import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/ml_model_adapter.dart';

void main() {
  late MlModelAdapter adapter;
  late Directory tempDir;

  setUpAll(() async {
    // Inicializar Flutter binding
    TestWidgetsFlutterBinding.ensureInitialized();

    // Crear directorio temporal para las pruebas
    tempDir = await Directory.systemTemp.createTemp('temposage_ml_test_');
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

  group('MlModelAdapter', () {
    test('inicialización con directorio temporal', () async {
      // Arrange
      const modelFileName = 'test_model.tflite';
      const modelBasePath = 'ml_models/test';

      // Act & Assert
      final result =
          await adapter.initialize(modelFileName, modelBasePath: modelBasePath);
      expect(result, isFalse); // Debería fallar porque el modelo no existe
    });

    test('dispose limpia recursos correctamente', () {
      // Act
      adapter.dispose();

      // Assert
      expect(adapter.modelInfo, isEmpty);
    });
  });
}
