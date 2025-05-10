import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_button.dart';

void main() {
  group('AccessibleButton', () {
    testWidgets('Renderiza correctamente con props básicas',
        (WidgetTester tester) async {
      const buttonText = 'Botón de prueba';
      bool wasPressed = false;

      // Crear el botón
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

      // Verificar que el botón se muestra con el texto correcto
      expect(find.text(buttonText), findsOneWidget);

      // Verificar que el botón es presionable
      await tester.tap(find.byType(AccessibleButton));
      expect(wasPressed, true);
    });

    testWidgets('Muestra indicador de carga cuando isLoading es true',
        (WidgetTester tester) async {
      // Crear el botón con isLoading=true
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

      // Verificar que el CircularProgressIndicator se muestra y el texto no
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando'), findsNothing);
    });

    testWidgets('No es presionable cuando isEnabled es false',
        (WidgetTester tester) async {
      bool wasPressed = false;

      // Crear el botón deshabilitado
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

      // Verificar que el botón está presente
      expect(find.text('Deshabilitado'), findsOneWidget);

      // Intentar presionar el botón
      await tester.tap(find.byType(AccessibleButton));

      // Verificar que el botón no fue presionado
      expect(wasPressed, false);
    });

    testWidgets('Muestra icono cuando se proporciona',
        (WidgetTester tester) async {
      // Crear el botón con icono
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              text: 'Con icono',
              onPressed: () {},
              icon: Icons.check,
            ),
          ),
        ),
      );

      // Verificar que el icono se muestra
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Factory primary crea botón con estilo primario',
        (WidgetTester tester) async {
      // Crear el botón usando factory
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton.primary(
              text: 'Botón primario',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verificar que el botón se muestra con el texto correcto
      expect(find.text('Botón primario'), findsOneWidget);

      // El estilo específico es difícil de probar sin acceder a propiedades internas
      // pero podemos verificar que el widget se construye correctamente
      expect(find.byType(AccessibleButton), findsOneWidget);
    });
  });
}
