import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_card.dart';

void main() {
  group('AccessibleCard Widget Tests', () {
    testWidgets('Debe renderizar el componente AccessibleCard correctamente',
        (WidgetTester tester) async {
      // Arrange - Preparar el widget para prueba
      const childText = 'Contenido de prueba';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              child: Text(childText),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional ya que el widget ya está renderizado

      // Assert - Verificar que el widget se renderizó correctamente
      expect(find.byType(AccessibleCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe llamar a onTap cuando se presiona',
        (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              onTap: () {
                wasTapped = true;
              },
              child: const Text('Toca aquí'),
            ),
          ),
        ),
      );

      // Act - Simular toque en la tarjeta
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert - Verificar que se llamó al callback
      expect(wasTapped, isTrue);
    });

    testWidgets('AccessibleCard.elevated debe tener una elevación de 4.0',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard.elevated(
              child: const Text('Tarjeta elevada'),
            ),
          ),
        ),
      );

      // Act - Encontrar el widget Card
      final cardWidget = tester.widget<Card>(find.byType(Card));

      // Assert - Verificar la elevación
      expect(cardWidget.elevation, 4.0);
    });

    testWidgets('AccessibleCard.flat debe tener una elevación de 0.0',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard.flat(
              child: const Text('Tarjeta plana'),
            ),
          ),
        ),
      );

      // Act - Encontrar el widget Card
      final cardWidget = tester.widget<Card>(find.byType(Card));

      // Assert - Verificar la elevación
      expect(cardWidget.elevation, 0.0);
    });
  });
}
