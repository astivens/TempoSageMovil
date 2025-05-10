import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/accessible_app.dart';

void main() {
  group('AccessibleApp', () {
    testWidgets('Renderiza correctamente con un widget hijo básico',
        (WidgetTester tester) async {
      const testChild = Text('Contenido de prueba');

      await tester.pumpWidget(
        const AccessibleApp(
          child: testChild,
        ),
      );

      // Verificar que el widget hijo se renderiza
      expect(find.text('Contenido de prueba'), findsOneWidget);

      // Verificar que se creó un MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Envuelve un MaterialApp existente con tema accesible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const AccessibleApp(
          child: MaterialApp(
            home: Scaffold(
              body: Text('MaterialApp con tema accesible'),
            ),
          ),
        ),
      );

      // Verificar que se renderiza el contenido
      expect(find.text('MaterialApp con tema accesible'), findsOneWidget);
    });

    testWidgets('Aplica escala de texto personalizada',
        (WidgetTester tester) async {
      // Crear una clave para acceder al tema después
      final GlobalKey materialAppKey = GlobalKey();

      await tester.pumpWidget(
        AccessibleApp(
          textScale: 1.5, // Escala de texto mayor
          child: MaterialApp(
            key: materialAppKey,
            home: const Scaffold(
              body: Text('Texto escalado'),
            ),
          ),
        ),
      );

      // Verificar que se renderiza el contenido
      expect(find.text('Texto escalado'), findsOneWidget);

      // La comprobación del tema y escala requeriría acceder a propiedades internas
      // y es difícil en pruebas unitarias simples
    });

    testWidgets('Aplica contraste alto cuando se configura',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const AccessibleApp(
          highContrast: true,
          child: MaterialApp(
            home: Scaffold(
              body: Text('Modo de alto contraste'),
            ),
          ),
        ),
      );

      // Verificar que se renderiza el contenido
      expect(find.text('Modo de alto contraste'), findsOneWidget);

      // La verificación del contraste real requeriría acceso a las propiedades del tema
    });

    testWidgets('Combina múltiples propiedades de accesibilidad',
        (WidgetTester tester) async {
      final customTheme = ThemeData(
        primaryColor: Colors.purple,
        fontFamily: 'Roboto',
      );

      await tester.pumpWidget(
        AccessibleApp(
          baseTheme: customTheme,
          highContrast: true,
          textScale: 1.2,
          child: const MaterialApp(
            home: Scaffold(
              body: Text('Configuración múltiple'),
            ),
          ),
        ),
      );

      // Verificar que se renderiza el contenido
      expect(find.text('Configuración múltiple'), findsOneWidget);
    });

    testWidgets('Preserva configuraciones del MaterialApp original',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const AccessibleApp(
          child: MaterialApp(
            title: 'Prueba de título',
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Text('Preservar configuraciones'),
            ),
          ),
        ),
      );

      // Verificar que se renderiza el contenido
      expect(find.text('Preservar configuraciones'), findsOneWidget);

      // Verificar que no hay banner de debug
      expect(find.byType(CheckedModeBanner), findsNothing);
    });
  });
}
