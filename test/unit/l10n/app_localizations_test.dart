import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/l10n/app_localizations.dart';

void main() {
  group('AppLocalizationsSetup Tests', () {
    test('debería tener locales soportados correctos', () {
      // Assert
      expect(AppLocalizationsSetup.supportedLocales.length, 2);
      expect(AppLocalizationsSetup.supportedLocales[0], const Locale('en'));
      expect(AppLocalizationsSetup.supportedLocales[1], const Locale('es'));
    });

    test('debería tener delegados de localización', () {
      // Assert
      expect(AppLocalizationsSetup.localizationsDelegates, isNotEmpty);
      expect(AppLocalizationsSetup.localizationsDelegates.length, 4);
    });

    testWidgets('debería obtener AppLocalizations del contexto',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizationsSetup.of(context);
              expect(localizations, isNotNull);
              return const Scaffold();
            },
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

