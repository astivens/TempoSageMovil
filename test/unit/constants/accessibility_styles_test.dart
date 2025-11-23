import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/constants/accessibility_styles.dart';

void main() {
  group('AccessibilityStyles Tests', () {
    test('debería tener estilos de texto accesibles definidos', () {
      expect(AccessibilityStyles.accessibleTitleLarge, isA<TextStyle>());
      expect(AccessibilityStyles.accessibleBodyLarge, isA<TextStyle>());
    });

    test('debería tener estilo de botón accesible definido', () {
      expect(AccessibilityStyles.accessibleButtonStyle, isA<ButtonStyle>());
    });

    test('debería tener decoración de tarjeta accesible definida', () {
      expect(AccessibilityStyles.accessibleCardDecoration, isA<BoxDecoration>());
    });

    test('debería tener espaciado consistente definido', () {
      expect(AccessibilityStyles.spacingSmall, equals(8.0));
      expect(AccessibilityStyles.spacingMedium, equals(16.0));
      expect(AccessibilityStyles.spacingLarge, equals(24.0));
      expect(AccessibilityStyles.spacingExtraLarge, equals(32.0));
    });

    test('debería tener sombras accesibles definidas', () {
      expect(AccessibilityStyles.accessibleShadow, isA<List<BoxShadow>>());
      expect(AccessibilityStyles.accessibleShadow.length, greaterThan(0));
    });

    test('debería tener duración de animación definida', () {
      expect(AccessibilityStyles.animationDuration, equals(const Duration(milliseconds: 300)));
    });

    test('debería tener curva de animación definida', () {
      expect(AccessibilityStyles.animationCurve, equals(Curves.easeInOut));
    });

    test('debería tener tamaño de fuente aumentado en título', () {
      expect(AccessibilityStyles.accessibleTitleLarge.fontSize, equals(26));
      expect(AccessibilityStyles.accessibleTitleLarge.fontWeight, equals(FontWeight.bold));
    });

    test('debería tener tamaño de fuente aumentado en cuerpo', () {
      expect(AccessibilityStyles.accessibleBodyLarge.fontSize, equals(18));
    });

    test('debería tener altura de línea aumentada para legibilidad', () {
      expect(AccessibilityStyles.accessibleTitleLarge.height, equals(1.3));
      expect(AccessibilityStyles.accessibleBodyLarge.height, equals(1.5));
    });
  });
}

