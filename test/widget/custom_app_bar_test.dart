import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/custom_app_bar.dart';

void main() {
  group('CustomAppBar Widget Tests', () {
    testWidgets('Debe renderizar la AppBar con el título correcto',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(
              title: 'Título de prueba',
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(CustomAppBar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Título de prueba'), findsOneWidget);
    });

    testWidgets('Debe mostrar subtítulo cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              subtitle: 'Subtítulo',
            ),
            body: Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Subtítulo'), findsOneWidget);
    });

    testWidgets('Debe mostrar botón de regreso cuando showBackButton es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              showBackButton: true,
            ),
            body: Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('No debe mostrar botón de regreso cuando showBackButton es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              showBackButton: false,
            ),
            body: Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
    });

    testWidgets('Debe llamar a onBackPressed cuando se presiona el botón de regreso',
        (WidgetTester tester) async {
      // Arrange
      bool wasBackPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              showBackButton: true,
              onBackPressed: () {
                wasBackPressed = true;
              },
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump();

      // Assert
      expect(wasBackPressed, isTrue);
    });

    testWidgets('Debe mostrar acciones cuando se proporcionan',
        (WidgetTester tester) async {
      // Arrange
      final actions = [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
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
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('CustomAppBar.main debe crear AppBar sin botón de regreso',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar.main(
              title: 'Título principal',
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Título principal'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
    });

    testWidgets('CustomAppBar.detail debe crear AppBar con botón de regreso',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar.detail(
              title: 'Título de detalle',
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Título de detalle'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('Debe usar leading personalizado cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'Título',
              leading: const Icon(Icons.menu),
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
    });
  });
}

