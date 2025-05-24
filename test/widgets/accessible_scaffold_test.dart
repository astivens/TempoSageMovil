import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_scaffold.dart';

void main() {
  group('AccessibleScaffold', () {
    testWidgets('Renderiza el body correctamente', (WidgetTester tester) async {
      const testBody = Text('Contenido de prueba');

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: testBody,
          ),
        ),
      );

      // Verificar que el contenido se muestra
      expect(find.text('Contenido de prueba'), findsOneWidget);
    });

    testWidgets('Muestra AppBar con título cuando se proporciona',
        (WidgetTester tester) async {
      const testTitle = 'Título de prueba';

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: SizedBox(),
            title: testTitle,
          ),
        ),
      );

      // Verificar que la AppBar se muestra con el título
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('No muestra AppBar cuando showAppBar es false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: SizedBox(),
            showAppBar: false,
          ),
        ),
      );

      // Verificar que la AppBar no se muestra
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('Muestra botón de regreso cuando showBackButton es true',
        (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            body: const SizedBox(),
            showBackButton: true,
            onBackPressed: () {
              backPressed = true;
            },
          ),
        ),
      );

      // Verificar que el botón de regreso se muestra
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Pulsar el botón de regreso
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Verificar que se llamó al callback
      expect(backPressed, isTrue);
    });

    testWidgets('Aplica padding personalizado cuando se proporciona',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: SizedBox(),
            padding: customPadding,
          ),
        ),
      );

      // Verificar que se aplica el padding
      final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));

      // Buscar el padding que contiene el SizedBox (nuestro body)
      Padding? targetPadding;
      for (final padding in paddingWidgets) {
        if (padding.padding == customPadding) {
          targetPadding = padding;
          break;
        }
      }

      expect(targetPadding, isNotNull);
      expect(targetPadding!.padding, equals(customPadding));
    });

    testWidgets(
        'Envuelve el contenido en SingleChildScrollView cuando scrollable es true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: Text('Contenido scrollable'),
            scrollable: true,
          ),
        ),
      );

      // Verificar que el SingleChildScrollView está presente
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Muestra FAB cuando se proporciona',
        (WidgetTester tester) async {
      const fab = FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: SizedBox(),
            floatingActionButton: fab,
          ),
        ),
      );

      // Verificar que el FAB se muestra
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Muestra bottomNavigationBar cuando se proporciona',
        (WidgetTester tester) async {
      final bottomNav = BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            body: const SizedBox(),
            bottomNavigationBar: bottomNav,
          ),
        ),
      );

      // Verificar que el bottomNavigationBar se muestra
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
