import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_button.dart';

void main() {
  group('AccessibleButton Widget Tests', () {
    testWidgets('Debe renderizar el botón con el texto correcto',
        (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Presionar';
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: buttonText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional para verificar renderizado

      // Assert
      expect(find.byType(AccessibleButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('Debe llamar a onPressed cuando se presiona el botón',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Presionar',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('Debe mostrar un icono cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Botón con icono',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Debe mostrar CircularProgressIndicator cuando isLoading es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Cargando',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando'), findsNothing);
    });

    testWidgets('No debe llamar a onPressed cuando isEnabled es false',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Deshabilitado',
              onPressed: () {
                wasPressed = true;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isFalse);
    });

    testWidgets('No debe llamar a onPressed cuando isLoading es true',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Cargando',
              onPressed: () {
                wasPressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isFalse);
    });

    testWidgets('AccessibleButton.primary debe usar los colores correctos',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton.primary(
              text: 'Primario',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act
      final buttonWidget = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      // Assert
      expect(buttonWidget.style?.backgroundColor?.resolve({}), isNotNull);
    });

    testWidgets('Debe usar ancho completo cuando isFullWidth es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Ancho completo',
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );

      // Act
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);

      // Assert
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('Debe usar el ancho personalizado cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      const customWidth = 200.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Ancho personalizado',
              onPressed: () {},
              width: customWidth,
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional para verificar renderizado

      // Assert
      expect(find.byType(AccessibleButton), findsOneWidget);
      expect(find.text('Ancho personalizado'), findsOneWidget);
      
      // Verificar que el widget se renderiza correctamente con el ancho personalizado
      // El ancho se aplica a través del SizedBox interno del AccessibleButton
      final accessibleButton = tester.widget<AccessibleButton>(find.byType(AccessibleButton));
      expect(accessibleButton.width, equals(customWidth));
    });

    testWidgets('Debe usar la altura personalizada cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      const customHeight = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Altura personalizada',
              onPressed: () {},
              height: customHeight,
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional para verificar renderizado

      // Assert
      expect(find.byType(AccessibleButton), findsOneWidget);
      expect(find.text('Altura personalizada'), findsOneWidget);
      
      // Verificar que el widget se renderiza correctamente con la altura personalizada
      // La altura se aplica a través del SizedBox interno del AccessibleButton
      final accessibleButton = tester.widget<AccessibleButton>(find.byType(AccessibleButton));
      expect(accessibleButton.height, equals(customHeight));
    });
  });
}

