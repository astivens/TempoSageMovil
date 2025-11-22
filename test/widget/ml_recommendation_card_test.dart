import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/ml_recommendation_card.dart';

void main() {
  group('MLRecommendationCard Widget Tests', () {
    testWidgets('Debe renderizar la tarjeta con título y descripción',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationCard(
              title: 'Título de prueba',
              description: 'Descripción de prueba',
              icon: Icons.star,
              type: RecommendationType.activity,
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(MLRecommendationCard), findsOneWidget);
      expect(find.text('Título de prueba'), findsOneWidget);
      expect(find.text('Descripción de prueba'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Debe mostrar el tipo de recomendación correcto',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationCard(
              title: 'Test',
              description: 'Test',
              icon: Icons.star,
              type: RecommendationType.habit,
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Hábito recomendado'), findsOneWidget);
    });

    testWidgets('Debe expandirse cuando se toca', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationCard(
              title: 'Test',
              description: 'Test',
              icon: Icons.star,
              type: RecommendationType.activity,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
    });

    testWidgets('Debe llamar a onAccept cuando se presiona Aceptar',
        (WidgetTester tester) async {
      // Arrange
      bool wasAccepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationCard(
              title: 'Test',
              description: 'Test',
              icon: Icons.star,
              type: RecommendationType.activity,
              onAccept: () {
                wasAccepted = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle(); // Esperar animaciones iniciales
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle(); // Esperar expansión
      
      // Buscar el botón Aceptar después de la expansión
      final acceptButton = find.text('Aceptar');
      expect(acceptButton, findsOneWidget);
      await tester.tap(acceptButton);
      
      // Esperar a que se complete la animación de aceptación (2 segundos)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assert
      expect(wasAccepted, isTrue);
    });

    testWidgets('Debe llamar a onDismiss cuando se presiona Descartar',
        (WidgetTester tester) async {
      // Arrange
      bool wasDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationCard(
              title: 'Test',
              description: 'Test',
              icon: Icons.star,
              type: RecommendationType.activity,
              onDismiss: () {
                wasDismissed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle(); // Esperar animaciones iniciales
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle(); // Esperar expansión
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasDismissed, isTrue);
    });
  });

  group('RecommendationTypeExtension Tests', () {
    test('displayText debería retornar texto correcto para activity', () {
      // Assert
      expect(RecommendationType.activity.displayText, 'Actividad sugerida');
    });

    test('displayText debería retornar texto correcto para habit', () {
      // Assert
      expect(RecommendationType.habit.displayText, 'Hábito recomendado');
    });

    test('displayText debería retornar texto correcto para timeBlock', () {
      // Assert
      expect(RecommendationType.timeBlock.displayText, 'Bloque de tiempo');
    });
  });

  group('MLRecommendationContainer Tests', () {
    testWidgets('Debe mostrar título cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationContainer(
              title: 'Título del contenedor',
              recommendations: [
                MLRecommendationCard(
                  title: 'Test',
                  description: 'Test',
                  icon: Icons.star,
                  type: RecommendationType.activity,
                ),
              ],
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.text('Título del contenedor'), findsOneWidget);
    });

    testWidgets('No debe mostrar nada cuando la lista está vacía',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationContainer(
              recommendations: [],
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(MLRecommendationContainer), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}

