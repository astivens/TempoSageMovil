import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/constants/app_colors.dart';

void main() {
  group('AppColors Tests', () {
    test('debería tener acceso a los sabores de Catppuccin', () {
      // Assert
      expect(AppColors.latte, isNotNull);
      expect(AppColors.frappe, isNotNull);
      expect(AppColors.macchiato, isNotNull);
      expect(AppColors.mocha, isNotNull);
    });

    test('debería retornar colores correctos según el modo oscuro', () {
      // Act & Assert
      final blueDark = AppColors.getBlue(true);
      final blueLight = AppColors.getBlue(false);
      expect(blueDark, isNotNull);
      expect(blueLight, isNotNull);
      expect(blueDark, isNot(equals(blueLight)));

      final mauveDark = AppColors.getMauve(true);
      final mauveLight = AppColors.getMauve(false);
      expect(mauveDark, isNotNull);
      expect(mauveLight, isNotNull);

      final greenDark = AppColors.getGreen(true);
      final greenLight = AppColors.getGreen(false);
      expect(greenDark, isNotNull);
      expect(greenLight, isNotNull);

      final redDark = AppColors.getRed(true);
      final redLight = AppColors.getRed(false);
      expect(redDark, isNotNull);
      expect(redLight, isNotNull);

      final textDark = AppColors.getText(true);
      final textLight = AppColors.getText(false);
      expect(textDark, isNotNull);
      expect(textLight, isNotNull);

      final backgroundDark = AppColors.getBackground(true);
      final backgroundLight = AppColors.getBackground(false);
      expect(backgroundDark, isNotNull);
      expect(backgroundLight, isNotNull);

      final surfaceDark = AppColors.getSurface(true);
      final surfaceLight = AppColors.getSurface(false);
      expect(surfaceDark, isNotNull);
      expect(surfaceLight, isNotNull);
    });

    test('debería tener colores constantes definidos', () {
      // Assert
      expect(AppColors.latteBg, isA<Color>());
      expect(AppColors.latteBase, isA<Color>());
      expect(AppColors.latteMantle, isA<Color>());
      expect(AppColors.latteCrust, isA<Color>());
      expect(AppColors.latteText, isA<Color>());
      expect(AppColors.latteSubtext0, isA<Color>());
      expect(AppColors.latteSubtext1, isA<Color>());
      expect(AppColors.latteOverlay0, isA<Color>());
      expect(AppColors.latteOverlay1, isA<Color>());
      expect(AppColors.latteOverlay2, isA<Color>());
      expect(AppColors.latteBlue, isA<Color>());
      expect(AppColors.latteLavender, isA<Color>());
      expect(AppColors.latteTeal, isA<Color>());
      expect(AppColors.latteGreen, isA<Color>());
      expect(AppColors.latteYellow, isA<Color>());
      expect(AppColors.latteRed, isA<Color>());
      expect(AppColors.lattePeach, isA<Color>());
      expect(AppColors.latteMauve, isA<Color>());
    });

    test('debería tener colores del tema oscuro definidos', () {
      // Assert
      expect(AppColors.rosewater, isA<Color>());
      expect(AppColors.flamingo, isA<Color>());
      expect(AppColors.pink, isA<Color>());
      expect(AppColors.maroon, isA<Color>());
      expect(AppColors.peach, isA<Color>());
      expect(AppColors.yellow, isA<Color>());
      expect(AppColors.green, isA<Color>());
      expect(AppColors.teal, isA<Color>());
      expect(AppColors.sky, isA<Color>());
      expect(AppColors.sapphire, isA<Color>());
      expect(AppColors.lavender, isA<Color>());
      expect(AppColors.text, isA<Color>());
      expect(AppColors.subtext1, isA<Color>());
      expect(AppColors.overlay2, isA<Color>());
      expect(AppColors.overlay1, isA<Color>());
      expect(AppColors.overlay0, isA<Color>());
      expect(AppColors.surface0, isA<Color>());
      expect(AppColors.surface1, isA<Color>());
      expect(AppColors.surface2, isA<Color>());
      expect(AppColors.base, isA<Color>());
      expect(AppColors.mantle, isA<Color>());
      expect(AppColors.crust, isA<Color>());
    });

    test('debería tener colores adicionales definidos', () {
      // Assert
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.primaryVariant, isA<Color>());
      expect(AppColors.secondary, isA<Color>());
      expect(AppColors.secondaryVariant, isA<Color>());
      expect(AppColors.background, isA<Color>());
      expect(AppColors.surface, isA<Color>());
      expect(AppColors.error, isA<Color>());
      expect(AppColors.textSecondary, isA<Color>());
      expect(AppColors.textDisabled, isA<Color>());
    });

    test('debería tener colores de categorías definidos', () {
      // Assert
      expect(AppColors.work, isA<Color>());
      expect(AppColors.study, isA<Color>());
      expect(AppColors.exercise, isA<Color>());
      expect(AppColors.leisure, isA<Color>());
      expect(AppColors.other, isA<Color>());
    });

    test('debería tener colores de estado definidos', () {
      // Assert
      expect(AppColors.success, isA<Color>());
      expect(AppColors.warning, isA<Color>());
      expect(AppColors.info, isA<Color>());
      expect(AppColors.divider, isA<Color>());
      expect(AppColors.border, isA<Color>());
      expect(AppColors.transparent, isA<Color>());
    });

    testWidgets('getColor debería retornar color correcto según el contexto - modo oscuro',
        (WidgetTester tester) async {
      // Arrange
      final darkColor = Colors.black;
      final lightColor = Colors.white;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              final resultDark = AppColors.getColor(
                context,
                darkModeColor: darkColor,
                lightModeColor: lightColor,
              );
              expect(resultDark, darkColor);
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('getColor debería retornar color correcto según el contexto - modo claro',
        (WidgetTester tester) async {
      // Arrange
      final darkColor = Colors.black;
      final lightColor = Colors.white;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (context) {
              final resultLight = AppColors.getColor(
                context,
                darkModeColor: darkColor,
                lightModeColor: lightColor,
              );
              expect(resultLight, lightColor);
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('getCatppuccinColor debería retornar colores correctos - modo oscuro',
        (WidgetTester tester) async {
      // Arrange
      final colors = [
        'rosewater',
        'flamingo',
        'pink',
        'mauve',
        'red',
        'maroon',
        'peach',
        'yellow',
        'green',
        'teal',
        'sky',
        'sapphire',
        'blue',
        'lavender',
        'text',
        'subtext1',
        'subtext0',
        'overlay2',
        'overlay1',
        'overlay0',
        'surface2',
        'surface1',
        'surface0',
        'base',
        'mantle',
        'crust',
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              for (final colorName in colors) {
                final colorDark = AppColors.getCatppuccinColor(
                  context,
                  colorName: colorName,
                );
                expect(colorDark, isA<Color>());
              }
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('getCatppuccinColor debería retornar colores correctos - modo claro',
        (WidgetTester tester) async {
      // Arrange
      final colors = [
        'rosewater',
        'flamingo',
        'pink',
        'mauve',
        'red',
        'maroon',
        'peach',
        'yellow',
        'green',
        'teal',
        'sky',
        'sapphire',
        'blue',
        'lavender',
        'text',
        'subtext1',
        'subtext0',
        'overlay2',
        'overlay1',
        'overlay0',
        'surface2',
        'surface1',
        'surface0',
        'base',
        'mantle',
        'crust',
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (context) {
              for (final colorName in colors) {
                final colorLight = AppColors.getCatppuccinColor(
                  context,
                  colorName: colorName,
                );
                expect(colorLight, isA<Color>());
              }
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('getCatppuccinColor debería retornar color por defecto para nombre inválido',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              final color = AppColors.getCatppuccinColor(
                context,
                colorName: 'invalidColor',
              );
              expect(color, isA<Color>());
              expect(color, AppColors.mocha.base);
              return const Scaffold();
            },
          ),
        ),
      );
    });
  });
}

