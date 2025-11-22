import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/extensions/color_extensions.dart';

void main() {
  group('ColorX Extension Tests', () {
    test('withAlphaValue debería retornar color con opacidad correcta', () {
      // Arrange
      const color = Colors.red;
      const opacity = 0.5;

      // Act
      final result = color.withAlphaValue(opacity);

      // Assert
      expect(result.alpha, (opacity * 255).round());
      expect(result.red, color.red);
      expect(result.green, color.green);
      expect(result.blue, color.blue);
    });

    test('withAlphaValue debería manejar opacidad 0.0', () {
      // Arrange
      const color = Colors.blue;
      const opacity = 0.0;

      // Act
      final result = color.withAlphaValue(opacity);

      // Assert
      expect(result.alpha, 0);
    });

    test('withAlphaValue debería manejar opacidad 1.0', () {
      // Arrange
      const color = Colors.green;
      const opacity = 1.0;

      // Act
      final result = color.withAlphaValue(opacity);

      // Assert
      expect(result.alpha, 255);
    });

    test('withAlphaValue debería redondear correctamente valores intermedios', () {
      // Arrange
      const color = Colors.purple;
      const opacity = 0.33;

      // Act
      final result = color.withAlphaValue(opacity);

      // Assert
      expect(result.alpha, (0.33 * 255).round());
    });
  });
}

