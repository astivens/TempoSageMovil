import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/hover_scale.dart';

void main() {
  group('HoverScale Widget Tests', () {
    testWidgets('Debe renderizar el widget hijo correctamente',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Hover me';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverScale(
              child: const Text(childText),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(HoverScale), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe usar escala por defecto de 1.03', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverScale(
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act
      final state = tester.state<HoverScaleState>(find.byType(HoverScale));

      // Assert
      expect(state.widget.scale, 1.03);
    });

    testWidgets('Debe usar duración por defecto de 200ms', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverScale(
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act
      final state = tester.state<HoverScaleState>(find.byType(HoverScale));

      // Assert
      expect(state.widget.duration, const Duration(milliseconds: 200));
    });

    testWidgets('Debe usar escala personalizada cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      const customScale = 1.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverScale(
              scale: customScale,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act
      final state = tester.state<HoverScaleState>(find.byType(HoverScale));

      // Assert
      expect(state.widget.scale, customScale);
    });

    testWidgets('No debe responder a hover cuando enabled es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverScale(
              enabled: false,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act
      final state = tester.state<HoverScaleState>(find.byType(HoverScale));
      final initialScale = tester.getSize(find.byType(HoverScale))!.width;
      state.handleHover(true);
      await tester.pumpAndSettle();

      // Assert - Cuando está deshabilitado, el hover no debería cambiar el tamaño
      final finalScale = tester.getSize(find.byType(HoverScale))!.width;
      expect(finalScale, equals(initialScale));
    });
  });
}

