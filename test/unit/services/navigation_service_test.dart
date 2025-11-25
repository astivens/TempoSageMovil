import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/services/navigation_service.dart';

void main() {
  group('NavigationService', () {
    test('debería tener navigatorKey inicializado', () {
      // Assert
      expect(NavigationService.navigatorKey, isNotNull);
      expect(NavigationService.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    testWidgets('debería inicializar navigator correctamente cuando hay MaterialApp', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          home: const Scaffold(
            body: Text('Home'),
          ),
        ),
      );

      // Assert
      expect(NavigationService.navigatorKey.currentState, isNotNull);
      expect(NavigationService.navigator, isA<NavigatorState>());
    });

    testWidgets('debería navegar a una ruta usando navigateTo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/second': (context) => const Scaffold(body: Text('Second')),
          },
        ),
      );

      // Act
      final future = NavigationService.navigateTo('/second');
      await tester.pump();
      await future;

      // Assert
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('debería reemplazar la ruta actual usando replaceTo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/second': (context) => const Scaffold(body: Text('Second')),
          },
        ),
      );

      // Act
      final future = NavigationService.replaceTo('/second');
      await tester.pump();
      await future;

      // Assert
      expect(find.text('Second'), findsOneWidget);
    });
  });
}

