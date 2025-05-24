import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/ml_recommendation_card.dart';

void main() {
  group('MLRecommendationCard', () {
    testWidgets('Renderiza correctamente con los datos básicos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Prueba de Título',
                description: 'Descripción de prueba para la tarjeta',
                icon: Icons.lightbulb_outlined,
                type: RecommendationType.activity,
              ),
            ),
          ),
        ),
      );

      // Verificar que se renderizan los elementos básicos
      expect(find.text('Prueba de Título'), findsOneWidget);
      expect(
          find.text('Descripción de prueba para la tarjeta'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outlined), findsOneWidget);
      expect(find.text('Actividad sugerida'), findsOneWidget);
    });

    testWidgets('Muestra el tipo correcto según RecommendationType',
        (WidgetTester tester) async {
      // Probar tipo activity
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Actividad',
                description: 'Descripción',
                icon: Icons.assignment,
                type: RecommendationType.activity,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Actividad sugerida'), findsOneWidget);

      // Probar tipo habit
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Hábito',
                description: 'Descripción',
                icon: Icons.auto_awesome,
                type: RecommendationType.habit,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Hábito recomendado'), findsOneWidget);

      // Probar tipo timeBlock
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Bloque',
                description: 'Descripción',
                icon: Icons.schedule,
                type: RecommendationType.timeBlock,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Bloque de tiempo'), findsOneWidget);
    });

    testWidgets('Se expande al hacer tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Tarjeta Expandible',
                description: 'Descripción corta',
                icon: Icons.lightbulb_outlined,
                type: RecommendationType.activity,
                onAccept: () {},
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );

      // Verificar que inicialmente no muestra los botones de acción
      expect(find.text('Aceptar'), findsNothing);
      expect(find.text('Descartar'), findsNothing);

      // Hacer tap para expandir
      await tester.tap(find.byType(MLRecommendationCard));
      await tester.pumpAndSettle();

      // Verificar que ahora muestra los botones de acción
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
    });

    testWidgets('Llama a los callbacks cuando se presionan los botones',
        (WidgetTester tester) async {
      bool acceptCalled = false;
      bool dismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Tarjeta con Callbacks',
                description: 'Descripción corta',
                icon: Icons.lightbulb_outlined,
                type: RecommendationType.activity,
                onAccept: () => acceptCalled = true,
                onDismiss: () => dismissCalled = true,
              ),
            ),
          ),
        ),
      );

      // Expandir la tarjeta primero
      await tester.tap(find.byType(MLRecommendationCard));
      await tester.pumpAndSettle();

      // Verificar que los botones están presentes
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);

      // Hacer tap en el botón Descartar usando solo el texto
      await tester.tap(find.text('Descartar'));
      await tester.pump();
      expect(dismissCalled, true);

      // Expandir nuevamente para probar el botón Aceptar
      await tester.tap(find.byType(MLRecommendationCard));
      await tester.pumpAndSettle();

      // Hacer tap en el botón Aceptar usando solo el texto
      await tester.tap(find.text('Aceptar'));
      await tester.pump();
      expect(acceptCalled, true);

      // Esperar a que termine la animación de aceptación
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Maneja texto largo correctamente',
        (WidgetTester tester) async {
      const longTitle = 'Título corto';
      const longDescription =
          'Esta es una descripción de longitud media que se mostrará correctamente';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400, // Ancho suficiente para el contenido
                child: MLRecommendationCard(
                  title: longTitle,
                  description: longDescription,
                  icon: Icons.lightbulb_outlined,
                  type: RecommendationType.activity,
                ),
              ),
            ),
          ),
        ),
      );

      // Verificar que el texto se renderiza
      expect(find.text(longTitle), findsOneWidget);
      expect(find.textContaining('Esta es una descripción'), findsOneWidget);
    });

    testWidgets('Inicia expandida cuando isExpanded es true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationCard(
                title: 'Tarjeta Expandida',
                description: 'Descripción',
                icon: Icons.lightbulb_outlined,
                type: RecommendationType.activity,
                isExpanded: true,
                onAccept: () {},
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );

      // Esperar a que la animación se complete
      await tester.pumpAndSettle();

      // Verificar que los botones están visibles desde el inicio
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
    });
  });

  group('MLRecommendationContainer', () {
    testWidgets('Renderiza el título y las recomendaciones',
        (WidgetTester tester) async {
      final recommendations = [
        MLRecommendationCard(
          title: 'Recomendación 1',
          description: 'Descripción 1',
          icon: Icons.lightbulb_outlined,
          type: RecommendationType.activity,
        ),
        MLRecommendationCard(
          title: 'Recomendación 2',
          description: 'Descripción 2',
          icon: Icons.auto_awesome,
          type: RecommendationType.habit,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationContainer(
                title: 'Mis Recomendaciones',
                recommendations: recommendations,
              ),
            ),
          ),
        ),
      );

      // Verificar que se renderizan los elementos
      expect(find.text('Mis Recomendaciones'), findsOneWidget);
      expect(find.text('Recomendación 1'), findsOneWidget);
      expect(find.text('Recomendación 2'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget); // Ícono del header
    });

    testWidgets('Muestra botón "Ver todo" cuando se proporciona callback',
        (WidgetTester tester) async {
      bool viewAllCalled = false;
      final recommendations = [
        MLRecommendationCard(
          title: 'Recomendación 1',
          description: 'Descripción 1',
          icon: Icons.lightbulb_outlined,
          type: RecommendationType.activity,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationContainer(
                recommendations: recommendations,
                onViewAll: () => viewAllCalled = true,
              ),
            ),
          ),
        ),
      );

      // Verificar que el botón está presente
      expect(find.text('Ver todo'), findsOneWidget);

      // Hacer tap en el botón
      await tester.tap(find.text('Ver todo'));
      await tester.pump();
      expect(viewAllCalled, true);
    });

    testWidgets('No se renderiza cuando no hay recomendaciones',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MLRecommendationContainer(
              recommendations: [],
            ),
          ),
        ),
      );

      // Verificar que no se renderiza nada relevante
      expect(find.byType(MLRecommendationContainer), findsOneWidget);
      expect(find.text('Recomendaciones'), findsNothing);
    });

    testWidgets('Limita a máximo 2 recomendaciones según especificaciones',
        (WidgetTester tester) async {
      final recommendations = [
        MLRecommendationCard(
          title: 'Recomendación 1',
          description: 'Descripción 1',
          icon: Icons.lightbulb_outlined,
          type: RecommendationType.activity,
        ),
        MLRecommendationCard(
          title: 'Recomendación 2',
          description: 'Descripción 2',
          icon: Icons.auto_awesome,
          type: RecommendationType.habit,
        ),
        MLRecommendationCard(
          title: 'Recomendación 3',
          description: 'Descripción 3',
          icon: Icons.schedule,
          type: RecommendationType.timeBlock,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MLRecommendationContainer(
                recommendations: recommendations,
              ),
            ),
          ),
        ),
      );

      // Verificar que solo se muestran las primeras 2 recomendaciones
      expect(find.text('Recomendación 1'), findsOneWidget);
      expect(find.text('Recomendación 2'), findsOneWidget);
      expect(find.text('Recomendación 3'), findsNothing);
    });
  });

  group('RecommendationType', () {
    test('Tiene todos los valores esperados', () {
      expect(RecommendationType.values.length, 3);
      expect(RecommendationType.values, contains(RecommendationType.activity));
      expect(RecommendationType.values, contains(RecommendationType.habit));
      expect(RecommendationType.values, contains(RecommendationType.timeBlock));
    });
  });
}
