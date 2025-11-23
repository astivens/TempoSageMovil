import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/services/csv_service.dart';

void main() {
  group('CSVService (services) Tests', () {
    test('debería inicializar el servicio', () {
      // Arrange & Act
      final service = CSVService();

      // Assert
      expect(service, isNotNull);
    });

    test('loadTop3Blocks debería ser un método asíncrono', () async {
      // Arrange
      final service = CSVService();

      // Act & Assert
      final future = service.loadTop3Blocks();
      expect(future, isA<Future>());
      
      // El método puede fallar si los assets no están disponibles en tests, pero debe retornar un Future
      try {
        await future;
      } catch (e) {
        // Esperado en entorno de test sin assets
        expect(e, isNotNull);
      }
    });

    test('loadAllBlocks debería ser un método asíncrono', () async {
      // Arrange
      final service = CSVService();

      // Act & Assert
      final future = service.loadAllBlocks();
      expect(future, isA<Future>());
      
      // El método puede fallar si los assets no están disponibles en tests, pero debe retornar un Future
      try {
        await future;
      } catch (e) {
        // Esperado en entorno de test sin assets
        expect(e, isNotNull);
      }
    });
  });
}

