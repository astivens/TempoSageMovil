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

    test('loadTop3Blocks debería ser un método asíncrono', () {
      // Arrange
      final service = CSVService();

      // Act
      final future = service.loadTop3Blocks();

      // Assert
      expect(future, isA<Future>());
    });

    test('loadAllBlocks debería ser un método asíncrono', () {
      // Arrange
      final service = CSVService();

      // Act
      final future = service.loadAllBlocks();

      // Assert
      expect(future, isA<Future>());
    });
  });
}

