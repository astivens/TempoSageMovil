import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/core/theme/theme_manager.dart';
import 'package:temposage/features/settings/presentation/providers/settings_provider.dart';
import 'package:temposage/features/settings/data/models/settings_model.dart';

class MockSettingsProvider extends Mock implements SettingsProvider {}

void main() {
  group('ThemeManager Tests', () {
    late ThemeManager themeManager;

    setUp(() {
      themeManager = ThemeManager();
    });

    test('debería inicializar con valores por defecto', () {
      expect(themeManager.isDarkMode, isFalse);
      expect(themeManager.isHighContrast, isFalse);
      expect(themeManager.textScaleFactor, equals(1.0));
    });

    test('debería inicializar con valores personalizados', () {
      final customManager = ThemeManager(
        isDarkMode: true,
        isHighContrast: true,
        textScaleFactor: 1.5,
      );

      expect(customManager.isDarkMode, isTrue);
      expect(customManager.isHighContrast, isTrue);
      expect(customManager.textScaleFactor, equals(1.5));
    });

    test('debería alternar modo oscuro', () {
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      themeManager.toggleDarkMode(true);
      expect(themeManager.isDarkMode, isTrue);
      expect(notified, isTrue);

      themeManager.toggleDarkMode(false);
      expect(themeManager.isDarkMode, isFalse);
    });

    test('debería alternar modo de alto contraste', () {
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      themeManager.toggleHighContrast(true);
      expect(themeManager.isHighContrast, isTrue);
      expect(notified, isTrue);

      themeManager.toggleHighContrast(false);
      expect(themeManager.isHighContrast, isFalse);
    });

    test('debería actualizar factor de escala de texto', () {
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      themeManager.updateTextScaleFactor(1.5);
      expect(themeManager.textScaleFactor, equals(1.5));
      expect(notified, isTrue);

      themeManager.updateTextScaleFactor(2.0);
      expect(themeManager.textScaleFactor, equals(2.0));
    });

    test('debería retornar ThemeMode correcto', () {
      expect(themeManager.themeMode, equals(ThemeMode.light));

      themeManager.toggleDarkMode(true);
      expect(themeManager.themeMode, equals(ThemeMode.dark));
    });

    test('debería tener temas claro y oscuro definidos', () {
      expect(themeManager.lightTheme, isA<ThemeData>());
      expect(themeManager.darkTheme, isA<ThemeData>());
    });

    test('debería actualizar desde SettingsProvider', () {
      final mockSettingsProvider = MockSettingsProvider();
      when(() => mockSettingsProvider.settings).thenReturn(const SettingsModel(
        darkMode: true,
        highContrastMode: true,
        fontSizeScale: 2,
      ));

      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      themeManager.updateFromSettings(mockSettingsProvider);

      expect(themeManager.isDarkMode, isTrue);
      expect(themeManager.isHighContrast, isTrue);
      expect(themeManager.textScaleFactor, equals(2.0));
      expect(notified, isTrue);
    });

    test('debería obtener color temático sin contexto', () {
      themeManager.toggleDarkMode(true);
      final color = themeManager.getThemedColor(
        darkModeColor: Colors.white,
        lightModeColor: Colors.black,
      );
      expect(color, equals(Colors.white));

      themeManager.toggleDarkMode(false);
      final color2 = themeManager.getThemedColor(
        darkModeColor: Colors.white,
        lightModeColor: Colors.black,
      );
      expect(color2, equals(Colors.black));
    });

    testWidgets('debería obtener color temático con contexto', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              final color = themeManager.getThemedColor(
                darkModeColor: Colors.white,
                lightModeColor: Colors.black,
                context: context,
              );
              expect(color, equals(Colors.white));
              return const Scaffold();
            },
          ),
        ),
      );
    });

    testWidgets('debería verificar si el tema es oscuro desde contexto', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              expect(ThemeManager.isDarkTheme(context), isTrue);
              return const Scaffold();
            },
          ),
        ),
      );
    });
  });
}

