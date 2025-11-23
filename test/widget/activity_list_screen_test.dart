import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/activities/presentation/screens/activity_list_screen.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/core/services/service_locator.dart';
import 'package:temposage/features/activities/presentation/controllers/activity_recommendation_controller.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}
class MockActivityRecommendationController extends Mock implements ActivityRecommendationController {}

void main() {
  group('ActivityListScreen Widget Tests', () {
    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityListScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ActivityListScreen), findsOneWidget);
    });

    testWidgets('debería mostrar barra de búsqueda', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityListScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Buscar actividades...'), findsOneWidget);
    });

    testWidgets('debería mostrar botón flotante para agregar actividad', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityListScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('debería mostrar texto descriptivo', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityListScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Administra todas tus actividades y tareas programadas'), findsOneWidget);
    });
  });
}

