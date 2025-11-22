import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/database/hive_init.dart';

void main() {
  group('initHive Tests', () {
    test('initHive debería ser una función asíncrona', () {
      // Act
      final future = initHive();

      // Assert
      expect(future, isA<Future>());
    });

    test('initHive debería retornar Future<void>', () {
      // Act
      final future = initHive();

      // Assert
      expect(future, isA<Future<void>>());
    });
  });
}

