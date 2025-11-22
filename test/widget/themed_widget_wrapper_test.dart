import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/themed_widget_wrapper.dart';

void main() {
  group('ThemedWidgetWrapper Widget Tests', () {
    testWidgets('Debe renderizar el widget usando el builder',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Contenido temático';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ThemedWidgetWrapper(
              builder: (context, isDarkMode) {
                return Text(childText);
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(ThemedWidgetWrapper), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe pasar isDarkMode correcto en modo claro',
        (WidgetTester tester) async {
      // Arrange
      bool? actualIsDarkMode;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ThemedWidgetWrapper(
              builder: (context, isDarkMode) {
                actualIsDarkMode = isDarkMode;
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(actualIsDarkMode, isFalse);
    });

    testWidgets('Debe pasar isDarkMode correcto en modo oscuro',
        (WidgetTester tester) async {
      // Arrange
      bool? actualIsDarkMode;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ThemedWidgetWrapper(
              builder: (context, isDarkMode) {
                actualIsDarkMode = isDarkMode;
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(actualIsDarkMode, isTrue);
    });
  });

  group('ThemedContainer Widget Tests', () {
    testWidgets('Debe renderizar el contenedor con el hijo',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Contenido del contenedor';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThemedContainer(
              child: Text(childText),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(ThemedContainer), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe usar padding personalizado cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      const customPadding = EdgeInsets.all(24.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemedContainer(
              padding: customPadding,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(ThemedContainer), findsOneWidget);
    });
  });
}

