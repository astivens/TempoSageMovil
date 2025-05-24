import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_card.dart';

void main() {
  group('AccessibleCard', () {
    testWidgets('Renderiza correctamente el widget hijo',
        (WidgetTester tester) async {
      const testChild = Text('Contenido de prueba');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard(
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Verificar que el hijo se renderiza
      expect(find.text('Contenido de prueba'), findsOneWidget);

      // Verificar que se crea una Card
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Aplica padding personalizado cuando se proporciona',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard(
                padding: customPadding,
                child: Text('Contenido con padding'),
              ),
            ),
          ),
        ),
      );

      // Verificar que se aplica el padding
      final accessibleCardFinder = find.byType(AccessibleCard);
      final inkWellFinder = find.descendant(
        of: accessibleCardFinder,
        matching: find.byType(InkWell),
      );
      final paddingFinder = find.descendant(
        of: inkWellFinder,
        matching: find.byType(Padding),
      );
      final paddingWidget = tester.widget<Padding>(paddingFinder);
      expect(paddingWidget.padding, equals(customPadding));
    });

    testWidgets('Responde a eventos de toque', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard(
                onTap: () {
                  wasTapped = true;
                },
                child: const Text('Tarjeta tocable'),
              ),
            ),
          ),
        ),
      );

      // Tocar la tarjeta
      await tester.tap(find.byType(AccessibleCard));
      await tester.pump();

      // Verificar que se llamó a onTap
      expect(wasTapped, isTrue);
    });

    testWidgets('Factory elevated crea una tarjeta con elevación alta',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard.elevated(
                child: const Text('Tarjeta elevada'),
              ),
            ),
          ),
        ),
      );

      // Verificar que se crea la tarjeta
      expect(find.text('Tarjeta elevada'), findsOneWidget);

      // Verificar que tiene elevación 4.0
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4.0);
    });

    testWidgets('Factory flat crea una tarjeta sin elevación',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard.flat(
                child: const Text('Tarjeta plana'),
              ),
            ),
          ),
        ),
      );

      // Verificar que se crea la tarjeta
      expect(find.text('Tarjeta plana'), findsOneWidget);

      // Verificar que tiene elevación 0.0
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0.0);
    });

    testWidgets('Aplica borderRadius personalizado',
        (WidgetTester tester) async {
      const customRadius = BorderRadius.all(Radius.circular(8.0));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard(
                borderRadius: customRadius,
                child: Text('Tarjeta con bordes personalizados'),
              ),
            ),
          ),
        ),
      );

      // Verificar que se crea la tarjeta
      expect(find.text('Tarjeta con bordes personalizados'), findsOneWidget);

      // Verificar el borderRadius en Card y InkWell
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(customRadius));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.borderRadius, equals(customRadius));
    });

    testWidgets('Aplica margen cuando se especifica',
        (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleCard(
                margin: customMargin,
                child: Text('Tarjeta con margen'),
              ),
            ),
          ),
        ),
      );

      // Verificar el margen en la Card
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, equals(customMargin));
    });
  });
}
