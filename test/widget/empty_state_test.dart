import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/empty_state.dart';
import 'package:temposage/core/widgets/accessible_button.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('Debe renderizar el estado vacío con icono, título y mensaje',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Título de prueba',
              message: 'Mensaje de prueba',
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Título de prueba'), findsOneWidget);
      expect(find.text('Mensaje de prueba'), findsOneWidget);
    });

    testWidgets('Debe mostrar botón de acción cuando se proporciona actionLabel y onAction',
        (WidgetTester tester) async {
      // Arrange
      bool wasActionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Título',
              message: 'Mensaje',
              actionLabel: 'Acción',
              onAction: () {
                wasActionPressed = true;
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional para verificar renderizado

      // Assert
      expect(find.text('Acción'), findsOneWidget);
    });

    testWidgets('No debe mostrar botón de acción cuando actionLabel es null',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Título',
              message: 'Mensaje',
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(AccessibleButton), findsNothing);
    });

    testWidgets('EmptyState.activities debe crear estado vacío para actividades',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.activities(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('No hay actividades'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('EmptyState.habits debe crear estado vacío para hábitos',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.habits(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Sin hábitos por seguir'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    });

    testWidgets('EmptyState.timeBlocks debe crear estado vacío para bloques de tiempo',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.timeBlocks(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Agenda vacía'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });

    testWidgets('EmptyState.dashboard debe crear estado vacío para dashboard',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.dashboard(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('¡Bienvenido a TempoSage!'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
    });

    testWidgets('EmptyState.noResults debe crear estado vacío sin resultados',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noResults(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Sin resultados'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('EmptyState.noResults debe mostrar término de búsqueda cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noResults(searchTerm: 'test'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.textContaining('test'), findsOneWidget);
    });

    testWidgets('EmptyState.noConnection debe crear estado vacío sin conexión',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noConnection(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('LoadingState debe mostrar CircularProgressIndicator',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(LoadingState), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingState debe mostrar mensaje cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: 'Cargando...'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Cargando...'), findsOneWidget);
    });

    testWidgets('ErrorState debe mostrar título y mensaje de error',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error de prueba',
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Algo salió mal'), findsOneWidget);
      expect(find.text('Error de prueba'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('ErrorState debe mostrar botón de reintentar cuando se proporciona onRetry',
        (WidgetTester tester) async {
      // Arrange
      bool wasRetried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error de prueba',
              onRetry: () {
                wasRetried = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      // Assert
      expect(wasRetried, isTrue);
    });
  });
}

