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

    test('generateRoute debería generar ruta para home', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.home),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta para activities', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.activities),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta para timeBlocks', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.timeBlocks),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta para habits', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.habits),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta para testRecommendation', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.testRecommendation),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta para mlDiagnostic', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.mlDiagnostic),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta para chatAI', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.chatAI),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute debería generar ruta por defecto para rutas desconocidas', () {
      // Arrange & Act
      final route = AppRouter.generateRoute(
        const RouteSettings(name: '/unknown'),
      );

      // Assert
      expect(route, isA<MaterialPageRoute>());
    });
  });
}

