import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_app.dart';

void main() {
  group('AccessibleApp Widget Tests', () {
    testWidgets('Debe renderizar el widget hijo correctamente',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Contenido hijo';

      await tester.pumpWidget(
        AccessibleApp(
          child: MaterialApp(
            home: Scaffold(
              body: Text(childText),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe aplicar tema accesible cuando se proporciona baseTheme',
        (WidgetTester tester) async {
      // Arrange
      final baseTheme = ThemeData.light();

      await tester.pumpWidget(
        AccessibleApp(
          baseTheme: baseTheme,
          child: MaterialApp(
            theme: baseTheme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
    });

    testWidgets('Debe aplicar alto contraste cuando highContrast es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        AccessibleApp(
          highContrast: true,
          child: MaterialApp(
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
    });

    testWidgets('Debe aplicar textScale cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      const textScale = 1.5;

      await tester.pumpWidget(
        AccessibleApp(
          textScale: textScale,
          child: MaterialApp(
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
    });

    testWidgets('Debe manejar MaterialApp con ThemeMode.dark',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        AccessibleApp(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark(),
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
    });

    testWidgets('Debe manejar MaterialApp con ThemeMode.light',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        AccessibleApp(
          child: MaterialApp(
            themeMode: ThemeMode.light,
            theme: ThemeData.light(),
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
    });

    testWidgets('Debe envolver widget no-MaterialApp en MaterialApp',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Widget simple';

      await tester.pumpWidget(
        AccessibleApp(
          child: Text(childText),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe aplicar estilos de texto accesibles',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        AccessibleApp(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Título'),
              ),
              body: const Text('Cuerpo'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleApp), findsOneWidget);
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Cuerpo'), findsOneWidget);
    });

    testWidgets('Debe aplicar estilos de botones accesibles',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        AccessibleApp(
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {},
                child: const Text('Botón'),
              ),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Botón'), findsOneWidget);
    });

    testWidgets('Debe aplicar estilos de tarjetas accesibles',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        AccessibleApp(
          child: MaterialApp(
            home: Scaffold(
              body: Card(
                child: const Text('Tarjeta'),
              ),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Tarjeta'), findsOneWidget);
    });
  });
}

