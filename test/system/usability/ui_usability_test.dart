import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Necesitarás importar tus widgets de la aplicación real
// import 'package:temposage/features/home/presentation/pages/home_page.dart';

void main() {
  group('Pruebas de Usabilidad de UI', () {
    testWidgets(
        'Los botones deben tener un tamaño mínimo para facilitar la interacción',
        (WidgetTester tester) async {
      // Arrange
      final testWidget = MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Acción'),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final buttonSize = tester.getSize(buttonFinder);
      // Verificar que el botón cumple con el tamaño mínimo recomendado (48x48)
      expect(buttonSize.width, greaterThanOrEqualTo(48.0),
          reason:
              'Los botones deben tener al menos 48px de ancho para ser fácilmente seleccionables');
      expect(buttonSize.height, greaterThanOrEqualTo(48.0),
          reason:
              'Los botones deben tener al menos 48px de alto para ser fácilmente seleccionables');
    });

    testWidgets('El texto debe tener suficiente contraste para ser legible',
        (WidgetTester tester) async {
      // Arrange
      const backgroundColor = Colors.white;
      const textColor = Colors.black87; // Alto contraste
      final testWidget = MaterialApp(
        home: Scaffold(
          backgroundColor: backgroundColor,
          body: Center(
            child: Text(
              'Texto de ejemplo',
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      final textFinder = find.text('Texto de ejemplo');
      expect(textFinder, findsOneWidget);

      // Calcular la diferencia de luminosidad entre el fondo y el texto
      final backgroundLuminance = backgroundColor.computeLuminance();
      final textLuminance = textColor.computeLuminance();
      final contrastRatio = (backgroundLuminance > textLuminance)
          ? (backgroundLuminance + 0.05) / (textLuminance + 0.05)
          : (textLuminance + 0.05) / (backgroundLuminance + 0.05);

      // La relación de contraste recomendada es al menos 4.5:1 para texto normal
      expect(contrastRatio, greaterThanOrEqualTo(4.5),
          reason:
              'El texto debe tener una relación de contraste de al menos 4.5:1 para ser legible');
    });

    testWidgets('Los elementos interactivos deben tener feedback visual',
        (WidgetTester tester) async {
      // Arrange
      bool buttonPressed = false;
      final testWidget = MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      buttonPressed = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: buttonPressed ? Colors.blue[300] : Colors.blue,
                    child: const Text('Presióname'),
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Verificar el color inicial
      final initialColor =
          _getWidgetBackgroundColor(tester, find.byType(Container));

      // Simular presión
      await tester.tap(find.byType(InkWell));
      await tester.pump(); // Esperar a que se actualice el widget

      // Verificar el color después de la presión
      final pressedColor =
          _getWidgetBackgroundColor(tester, find.byType(Container));

      // Assert
      expect(initialColor, isNot(equals(pressedColor)),
          reason:
              'Los elementos interactivos deben cambiar visualmente al ser presionados');
    });
  });
}

// Función de ayuda para obtener el color de fondo de un widget
Color _getWidgetBackgroundColor(WidgetTester tester, Finder finder) {
  final Container container = tester.widget<Container>(finder);
  return container.color as Color;
}
