import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/expandable_fab.dart';

void main() {
  group('ExpandableFab', () {
    testWidgets('Renderiza correctamente el botón principal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              icon: const Icon(Icons.add),
              children: [
                ActionButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ),
      );

      // Verificar que el FAB principal se muestra
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Expande y contrae al tocar el botón principal',
        (WidgetTester tester) async {
      // Preparar los botones secundarios
      final children = [
        ActionButton(
          onPressed: () {},
          icon: const Icon(Icons.edit),
        ),
        ActionButton(
          onPressed: () {},
          icon: const Icon(Icons.delete),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              icon: const Icon(Icons.add),
              children: children,
            ),
          ),
        ),
      );

      // Inicialmente, los botones secundarios no deberían ser visibles (opacidad 0)
      final opacityFinder = find.byType(FadeTransition);
      expect(opacityFinder, findsNWidgets(2)); // Uno por cada ActionButton

      // Tocar el FAB para expandir
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // Comenzar la animación
      await tester.pump(
          const Duration(milliseconds: 50)); // Permitir que progrese un poco

      // Verificar que la animación ha comenzado
      for (final fadeTransition
          in tester.widgetList<FadeTransition>(opacityFinder)) {
        expect(fadeTransition.opacity.value, greaterThan(0.0));
      }

      // Avanzar la animación hasta el final
      await tester.pumpAndSettle();

      // Verificar que los botones están completamente visibles
      for (final fadeTransition
          in tester.widgetList<FadeTransition>(opacityFinder)) {
        expect(fadeTransition.opacity.value, equals(1.0));
      }

      // Tocar de nuevo para contraer
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verificar que los botones están ocultos de nuevo
      for (final fadeTransition
          in tester.widgetList<FadeTransition>(opacityFinder)) {
        expect(fadeTransition.opacity.value, equals(0.0));
      }
    });

    testWidgets('Puede comenzar expandido si initialOpen es true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              initialOpen: true,
              icon: const Icon(Icons.add),
              children: [
                ActionButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ),
      );

      // Esperar a que la animación termine
      await tester.pumpAndSettle();

      // Verificar que el botón secundario está visible
      final fadeTransition =
          tester.widget<FadeTransition>(find.byType(FadeTransition).first);
      expect(fadeTransition.opacity.value, equals(1.0));
    });

    testWidgets('Llama a callbacks onOpen y onClose',
        (WidgetTester tester) async {
      bool wasOpened = false;
      bool wasClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              icon: const Icon(Icons.add),
              onOpen: () => wasOpened = true,
              onClose: () => wasClosed = true,
              children: [
                ActionButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ),
      );

      // Abrir
      await tester.tap(find.byType(FloatingActionButton));
      expect(wasOpened, isTrue);
      expect(wasClosed, isFalse);

      // Reiniciar flags
      wasOpened = false;

      // Cerrar
      await tester.tap(find.byType(FloatingActionButton));
      expect(wasOpened, isFalse);
      expect(wasClosed, isTrue);
    });

    testWidgets('Se cierra al tocar fuera cuando está abierto',
        (WidgetTester tester) async {
      final GlobalKey<ExpandableFabState> fabKey =
          GlobalKey<ExpandableFabState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Positioned.fill(
                  child: Text('Fondo'),
                ),
                ExpandableFab(
                  key: fabKey,
                  icon: const Icon(Icons.add),
                  children: [
                    ActionButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Abrir el FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verificar que está abierto
      expect(fabKey.currentState!.isOpen, isTrue);

      // Tocar fuera (en una posición específica que no esté sobre el FAB)
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();

      // Verificar que se cerró
      expect(fabKey.currentState!.isOpen, isFalse);
    });

    testWidgets('Métodos open() y close() funcionan correctamente',
        (WidgetTester tester) async {
      final GlobalKey<ExpandableFabState> fabKey =
          GlobalKey<ExpandableFabState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableFab(
              key: fabKey,
              icon: const Icon(Icons.add),
              children: [
                ActionButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ),
      );

      // Inicialmente cerrado
      expect(fabKey.currentState!.isOpen, isFalse);

      // Abrir programáticamente
      fabKey.currentState!.open();
      await tester.pumpAndSettle();
      expect(fabKey.currentState!.isOpen, isTrue);

      // Cerrar programáticamente
      fabKey.currentState!.close();
      await tester.pumpAndSettle();
      expect(fabKey.currentState!.isOpen, isFalse);
    });
  });

  group('ActionButton', () {
    testWidgets('Renderiza correctamente', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ActionButton(
                onPressed: () => wasPressed = true,
                icon: const Icon(Icons.edit),
                tooltip: 'Editar',
              ),
            ),
          ),
        ),
      );

      // Verificar que el botón se muestra
      expect(find.byType(ActionButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Verificar que es presionable
      await tester.tap(find.byType(ActionButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('Aplica colores personalizados', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ActionButton(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      // Verificar el color del material
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ActionButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, equals(Colors.red));

      // Verificar el color del icono
      final iconButton = tester.widget<IconButton>(
        find.descendant(
          of: find.byType(ActionButton),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButton.color, equals(Colors.white));
    });
  });
}
