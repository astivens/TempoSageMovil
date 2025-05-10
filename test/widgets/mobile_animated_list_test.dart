import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/mobile_animated_list.dart';

void main() {
  group('MobileAnimatedList', () {
    testWidgets('Renderiza una lista con elementos',
        (WidgetTester tester) async {
      final items = [
        const Text('Item 1', key: Key('item1')),
        const Text('Item 2', key: Key('item2')),
        const Text('Item 3', key: Key('item3')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileAnimatedList(
              children: items,
            ),
          ),
        ),
      );

      // Verificar que todos los elementos se muestran
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('Soporta eliminación de elementos',
        (WidgetTester tester) async {
      int? removedIndex;

      final items = [
        const Text('Item 1', key: Key('item1')),
        const Text('Item 2', key: Key('item2')),
        const Text('Item 3', key: Key('item3')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileAnimatedList(
              children: items,
              onRemove: (index) {
                removedIndex = index;
              },
            ),
          ),
        ),
      );

      // Verificar que se muestra el Dismissible
      expect(find.byType(Dismissible), findsNWidgets(3));

      // Simular deslizamiento para eliminar el segundo elemento
      await tester.drag(find.text('Item 2'), const Offset(500.0, 0.0));
      await tester.pumpAndSettle();

      // Verificar que se llamó al callback onRemove con el índice correcto
      expect(removedIndex, 1);
    });

    testWidgets('Acepta un controlador de desplazamiento personalizado',
        (WidgetTester tester) async {
      final scrollController = ScrollController();
      final items = List.generate(
          20, (index) => Text('Item $index', key: Key('item$index')));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileAnimatedList(
              children: items,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Verificar que el controlador de desplazamiento funciona
      expect(scrollController.hasClients, isTrue);

      // Limpiar recursos
      scrollController.dispose();
    });

    testWidgets('Soporta reordenamiento cuando está habilitado',
        (WidgetTester tester) async {
      // Estas variables se usarían en una prueba real de reordenamiento,
      // pero la simulación de reordenamiento es compleja en pruebas unitarias
      // Se mantienen aquí para documentar la estructura del callback
      // ignore: unused_local_variable
      int? oldIndex;
      // ignore: unused_local_variable
      int? newIndex;

      final items = [
        const Text('Item 1', key: Key('item1')),
        const Text('Item 2', key: Key('item2')),
        const Text('Item 3', key: Key('item3')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileAnimatedList(
              children: items,
              enableReorder: true,
              onReorder: (old, new_) {
                oldIndex = old;
                newIndex = new_;
              },
            ),
          ),
        ),
      );

      // Verificar que se usa ReorderableListView
      expect(find.byType(ReorderableListView), findsOneWidget);

      // La simulación de reordenamiento es compleja en pruebas, pero al menos
      // verificamos que el componente adecuado esté presente
    });
  });
}
