import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/constants/app_styles.dart';

void main() {
  group('AppStyles Tests', () {
    test('debería tener titleLarge definido correctamente', () {
      // Assert
      expect(AppStyles.titleLarge, isA<TextStyle>());
      expect(AppStyles.titleLarge.fontSize, 24);
      expect(AppStyles.titleLarge.fontWeight, FontWeight.bold);
      expect(AppStyles.titleLarge.fontFamily, 'Noto Sans');
    });

    test('debería tener titleMedium definido correctamente', () {
      // Assert
      expect(AppStyles.titleMedium, isA<TextStyle>());
      expect(AppStyles.titleMedium.fontSize, 20);
      expect(AppStyles.titleMedium.fontWeight, FontWeight.w600);
      expect(AppStyles.titleMedium.fontFamily, 'Noto Sans');
    });

    test('debería tener titleSmall definido correctamente', () {
      // Assert
      expect(AppStyles.titleSmall, isA<TextStyle>());
      expect(AppStyles.titleSmall.fontSize, 16);
      expect(AppStyles.titleSmall.fontWeight, FontWeight.w600);
      expect(AppStyles.titleSmall.fontFamily, 'Noto Sans');
    });

    test('debería tener headlineLarge definido correctamente', () {
      // Assert
      expect(AppStyles.headlineLarge, isA<TextStyle>());
      expect(AppStyles.headlineLarge.fontSize, 32);
      expect(AppStyles.headlineLarge.fontWeight, FontWeight.bold);
      expect(AppStyles.headlineLarge.fontFamily, 'Noto Sans');
    });

    test('debería tener headlineMedium definido correctamente', () {
      // Assert
      expect(AppStyles.headlineMedium, isA<TextStyle>());
      expect(AppStyles.headlineMedium.fontSize, 20);
      expect(AppStyles.headlineMedium.fontWeight, FontWeight.bold);
      expect(AppStyles.headlineMedium.fontFamily, 'Noto Sans');
    });

    test('debería tener headlineSmall definido correctamente', () {
      // Assert
      expect(AppStyles.headlineSmall, isA<TextStyle>());
      expect(AppStyles.headlineSmall.fontSize, 20);
      expect(AppStyles.headlineSmall.fontWeight, FontWeight.bold);
      expect(AppStyles.headlineSmall.fontFamily, 'Noto Sans');
    });

    test('debería tener bodyLarge definido correctamente', () {
      // Assert
      expect(AppStyles.bodyLarge, isA<TextStyle>());
      expect(AppStyles.bodyLarge.fontSize, 16);
      expect(AppStyles.bodyLarge.fontFamily, 'Noto Sans');
    });

    test('debería tener bodyMedium definido correctamente', () {
      // Assert
      expect(AppStyles.bodyMedium, isA<TextStyle>());
      expect(AppStyles.bodyMedium.fontSize, 14);
      expect(AppStyles.bodyMedium.fontFamily, 'Noto Sans');
    });

    test('debería tener bodySmall definido correctamente', () {
      // Assert
      expect(AppStyles.bodySmall, isA<TextStyle>());
      expect(AppStyles.bodySmall.fontSize, 12);
      expect(AppStyles.bodySmall.fontFamily, 'Noto Sans');
    });

    test('debería tener labelLarge definido correctamente', () {
      // Assert
      expect(AppStyles.labelLarge, isA<TextStyle>());
      expect(AppStyles.labelLarge.fontSize, 14);
      expect(AppStyles.labelLarge.fontFamily, 'Noto Sans');
    });

    test('debería tener labelMedium definido correctamente', () {
      // Assert
      expect(AppStyles.labelMedium, isA<TextStyle>());
      expect(AppStyles.labelMedium.fontSize, 12);
      expect(AppStyles.labelMedium.fontFamily, 'Noto Sans');
    });

    test('debería tener labelSmall definido correctamente', () {
      // Assert
      expect(AppStyles.labelSmall, isA<TextStyle>());
      expect(AppStyles.labelSmall.fontSize, 11);
      expect(AppStyles.labelSmall.fontFamily, 'Noto Sans');
    });
  });
}

