import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/page_transitions.dart';

void main() {
  group('MobilePageTransition Widget Tests', () {
    testWidgets('Debe renderizar el widget hijo correctamente',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Página de prueba';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobilePageTransition(
              child: const Text(childText),
            ),
          ),
        ),
      );

      // Act - Esperar a que se complete la animación
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MobilePageTransition), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe aplicar animación cuando isPopup es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobilePageTransition(
              isPopup: false,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MobilePageTransition), findsOneWidget);
    });

    testWidgets('Debe aplicar animación cuando isPopup es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobilePageTransition(
              isPopup: true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MobilePageTransition), findsOneWidget);
    });
  });

  group('createMobilePageRoute Tests', () {
    testWidgets('debería crear una ruta de página',
        (WidgetTester tester) async {
      // Arrange
      final route = createMobilePageRoute(
        page: const Scaffold(body: Text('Test Page')),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: '/',
        ),
      );

      // Assert
      expect(route, isA<PageRouteBuilder>());
    });

    testWidgets('debería crear una ruta de popup cuando isPopup es true',
        (WidgetTester tester) async {
      // Arrange
      final route = createMobilePageRoute(
        page: const Scaffold(body: Text('Test Page')),
        isPopup: true,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: '/',
        ),
      );

      // Assert
      expect(route, isA<PageRouteBuilder>());
    });
  });

  group('HeroPageTransition Tests', () {
    testWidgets('debería crear una ruta con transición Hero',
        (WidgetTester tester) async {
      // Arrange
      final route = HeroPageTransition(
        page: const Scaffold(body: Text('Test Page')),
        heroTag: 'test-hero',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: '/',
        ),
      );

      // Assert
      expect(route, isA<PageRouteBuilder>());
    });
  });
}

