import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/custom_app_bar.dart';

void main() {
  group('CustomAppBar', () {
    testWidgets('Renderiza correctamente con título',
        (WidgetTester tester) async {
      const testTitle = 'Título de prueba';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: testTitle,
            ),
          ),
        ),
      );

      // Verificar que se muestra el título
      expect(find.text(testTitle), findsOneWidget);

      // Verificar que se muestra el botón de regreso por defecto
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Muestra título y subtítulo correctamente',
        (WidgetTester tester) async {
      const testTitle = 'Título principal';
      const testSubtitle = 'Subtítulo secundario';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );

      // Verificar que se muestra el título y subtítulo
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });

    testWidgets('No muestra botón de regreso cuando showBackButton es false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              showBackButton: false,
            ),
          ),
        ),
      );

      // Verificar que no se muestra el botón de regreso
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('Llama a onBackPressed cuando se proporciona',
        (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              onBackPressed: () {
                backPressed = true;
              },
            ),
          ),
        ),
      );

      // Tocar el botón de regreso
      await tester.tap(find.byIcon(Icons.arrow_back));

      // Verificar que se llamó a onBackPressed
      expect(backPressed, isTrue);
    });

    testWidgets('Aplica estilo personalizado para título',
        (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 24,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título con estilo',
              titleStyle: customStyle,
            ),
          ),
        ),
      );

      // Verificar que se aplica el estilo personalizado
      final textWidget = tester.widget<Text>(find.text('Título con estilo'));
      expect(textWidget.style, equals(customStyle));
    });

    testWidgets('Acepta acciones personalizadas', (WidgetTester tester) async {
      final actions = [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              actions: actions,
            ),
          ),
        ),
      );

      // Verificar que se muestran las acciones
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Factory main crea una AppBar para pantallas principales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar.main(
              title: 'Pantalla principal',
              subtitle: 'Descripción',
            ),
          ),
        ),
      );

      // Verificar configuración para pantalla principal
      expect(find.text('Pantalla principal'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
      expect(
          find.byIcon(Icons.arrow_back), findsNothing); // Sin botón de regreso

      // Verificar que el título está centrado
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('Factory detail crea una AppBar para pantallas de detalle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar.detail(
              title: 'Detalle',
              subtitle: 'Información adicional',
            ),
          ),
        ),
      );

      // Verificar configuración para pantalla de detalle
      expect(find.text('Detalle'), findsOneWidget);
      expect(find.text('Información adicional'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back),
          findsOneWidget); // Con botón de regreso
    });
  });
}
