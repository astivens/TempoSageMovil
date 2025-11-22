import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/presentation/widgets/add_activity_button.dart';

void main() {
  group('AddActivityButton Widget Tests', () {
    testWidgets('Debe renderizar el botón correctamente',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddActivityButton(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional para verificar renderizado

      // Assert
      expect(find.byType(AddActivityButton), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Debe llamar a onPressed cuando se presiona el botón',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddActivityButton(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });
  });
}

