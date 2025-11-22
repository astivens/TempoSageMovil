import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/unified_display_card.dart';

void main() {
  group('UnifiedDisplayCard Widget Tests', () {
    testWidgets('Debe renderizar la tarjeta con título correcto',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDisplayCard(
              title: 'Título de prueba',
              itemColor: Colors.blue,
            ),
          ),
        ),
      );

      // Act - Esperar a que se complete la animación
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(UnifiedDisplayCard), findsOneWidget);
      expect(find.text('Título de prueba'), findsOneWidget);
    });

    testWidgets('Debe mostrar descripción cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDisplayCard(
              title: 'Título',
              description: 'Descripción de prueba',
              itemColor: Colors.blue,
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Descripción de prueba'), findsOneWidget);
    });

    testWidgets('Debe mostrar categoría cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDisplayCard(
              title: 'Título',
              category: 'Categoría de prueba',
              itemColor: Colors.blue,
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - La categoría se muestra en un chip con texto en mayúsculas
      expect(find.text('CATEGORÍA DE PRUEBA'), findsOneWidget);
    });

    testWidgets('Debe mostrar rango de tiempo cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDisplayCard(
              title: 'Título',
              timeRange: '09:00 - 10:00',
              itemColor: Colors.blue,
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('09:00 - 10:00'), findsOneWidget);
    });

    testWidgets('Debe llamar a onTap cuando se toca la tarjeta',
        (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDisplayCard(
              title: 'Título',
              itemColor: Colors.blue,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Act - Tocar el texto del título que está dentro del GestureDetector
      await tester.pumpAndSettle();
      // Buscar el GestureDetector que contiene el contenido, no el del Slidable
      final titleFinder = find.text('Título');
      expect(titleFinder, findsOneWidget);
      // Tocar el título que está dentro del GestureDetector con onTap
      await tester.tap(titleFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('Debe mostrar prefix cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDisplayCard(
              title: 'Título',
              prefix: 'Hábito: ',
              itemColor: Colors.blue,
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Hábito:'), findsOneWidget);
    });
  });
}

