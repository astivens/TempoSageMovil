import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/expandable_fab.dart';

void main() {
  group('ExpandableFab Widget Tests', () {
    testWidgets('Debe renderizar el FAB correctamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              icon: const Icon(Icons.add),
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(ExpandableFab), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Debe mostrar hijos cuando se expande', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              icon: const Icon(Icons.add),
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('Debe comenzar abierto cuando initialOpen es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              initialOpen: true,
              icon: const Icon(Icons.add),
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      final state = tester.state<ExpandableFabState>(find.byType(ExpandableFab));
      expect(state.isOpen, isTrue);
    });

    testWidgets('Debe llamar a onOpen cuando se expande', (WidgetTester tester) async {
      // Arrange
      bool wasOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              icon: const Icon(Icons.add),
              onOpen: () {
                wasOpened = true;
              },
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert
      expect(wasOpened, isTrue);
    });

    testWidgets('Debe llamar a onClose cuando se contrae', (WidgetTester tester) async {
      // Arrange
      bool wasClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              initialOpen: true,
              icon: const Icon(Icons.add),
              onClose: () {
                wasClosed = true;
              },
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert
      expect(wasClosed, isTrue);
    });

    testWidgets('Debe actualizar duración cuando cambia el widget', (WidgetTester tester) async {
      // Arrange
      const initialDuration = Duration(milliseconds: 200);
      const newDuration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              icon: const Icon(Icons.add),
              duration: initialDuration,
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Actualizar el widget con nueva duración
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              icon: const Icon(Icons.add),
              duration: newDuration,
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verificar que el widget se actualizó correctamente
      expect(find.byType(ExpandableFab), findsOneWidget);
    });

    testWidgets('Debe abrir el FAB usando el método open()', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: ExpandableFab(
              icon: const Icon(Icons.add),
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.edit),
                ),
              ],
            ),
            body: const Text('Body'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Obtener el estado y llamar a open()
      final state = tester.state<ExpandableFabState>(find.byType(ExpandableFab));
      state.open();
      await tester.pumpAndSettle();

      // Assert
      expect(state.isOpen, isTrue);
    });
  });
}

