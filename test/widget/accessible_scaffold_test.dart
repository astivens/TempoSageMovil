import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_scaffold.dart';

void main() {
  group('AccessibleScaffold Widget Tests', () {
    testWidgets('Debe renderizar el scaffold con el cuerpo correcto',
        (WidgetTester tester) async {
      // Arrange
      const bodyText = 'Contenido del cuerpo';

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: Text(bodyText),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleScaffold), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text(bodyText), findsOneWidget);
    });

    testWidgets('Debe mostrar AppBar cuando showAppBar es true',
        (WidgetTester tester) async {
      // Arrange
      const title = 'Título de prueba';

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            title: title,
            body: Text('Cuerpo'),
            showAppBar: true,
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('No debe mostrar AppBar cuando showAppBar es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: Text('Cuerpo'),
            showAppBar: false,
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('Debe mostrar acciones en AppBar cuando se proporcionan',
        (WidgetTester tester) async {
      // Arrange
      final actions = [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            title: 'Título',
            body: const Text('Cuerpo'),
            actions: actions,
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Debe mostrar FloatingActionButton cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            body: const Text('Cuerpo'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Debe mostrar drawer cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            body: const Text('Cuerpo'),
            drawer: Drawer(
              child: ListTile(
                title: const Text('Opción'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Abrir el drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('Debe mostrar bottomNavigationBar cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            body: const Text('Cuerpo'),
            bottomNavigationBar: BottomNavigationBar(
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
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Debe mostrar botón de regreso cuando showBackButton es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            title: 'Título',
            body: const Text('Cuerpo'),
            showBackButton: true,
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Debe llamar a onBackPressed cuando se presiona el botón de regreso',
        (WidgetTester tester) async {
      // Arrange
      bool wasBackPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleScaffold(
            title: 'Título',
            body: const Text('Cuerpo'),
            showBackButton: true,
            onBackPressed: () {
              wasBackPressed = true;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Assert
      expect(wasBackPressed, isTrue);
    });

    testWidgets('Debe envolver el cuerpo en SingleChildScrollView cuando scrollable es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: Text('Cuerpo'),
            scrollable: true,
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('No debe envolver el cuerpo en SingleChildScrollView cuando scrollable es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: Text('Cuerpo'),
            scrollable: false,
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('Debe usar SafeArea para envolver el contenido',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibleScaffold(
            body: Text('Cuerpo'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      // Puede haber múltiples SafeArea (uno del AccessibleScaffold y otro del MaterialApp/Scaffold)
      // Verificamos que existe al menos uno
      expect(find.byType(SafeArea), findsWidgets);
    });
  });
}

