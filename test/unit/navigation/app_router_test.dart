import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/navigation/app_router.dart';

void main() {
  group('AppRouter Tests', () {
    test('debería tener rutas constantes definidas', () {
      // Assert
      expect(AppRouter.activities, '/activities');
      expect(AppRouter.timeBlocks, '/timeblocks');
      expect(AppRouter.habits, '/habits');
      expect(AppRouter.home, '/home');
      expect(AppRouter.testRecommendation, '/test-recommendation');
      expect(AppRouter.mlDiagnostic, '/ml-diagnostic');
      expect(AppRouter.chatAI, '/chat-ai');
    });

    testWidgets('generateRoute debería generar ruta para home',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.home),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.home,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta para activities',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.activities),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.activities,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta para timeBlocks',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.timeBlocks),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.timeBlocks,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta para habits',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.habits),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.habits,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta para testRecommendation',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.testRecommendation),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.testRecommendation,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta para mlDiagnostic',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.mlDiagnostic),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.mlDiagnostic,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta para chatAI',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.chatAI),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: AppRouter.chatAI,
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generateRoute debería generar ruta por defecto para rutas desconocidas',
        (WidgetTester tester) async {
      // Arrange
      final route = AppRouter.generateRoute(
        const RouteSettings(name: '/unknown'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => route,
          initialRoute: '/unknown',
        ),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });
  });
}

