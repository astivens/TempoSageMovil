import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/presentation/widgets/dashboard_activities.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';

void main() {
  group('DashboardActivities Widget Tests', () {
    bool toggleCalled = false;
    bool editCalled = false;
    bool deleteCalled = false;
    bool viewAllCalled = false;
    bool addNewCalled = false;
    Activity? lastActivity;

    setUp(() {
      toggleCalled = false;
      editCalled = false;
      deleteCalled = false;
      viewAllCalled = false;
      addNewCalled = false;
      lastActivity = null;
    });

    Widget createTestWidget({List<Activity> activities = const []}) {
      return MaterialApp(
        home: Scaffold(
          body: DashboardActivities(
            activities: activities,
            onToggleCompletion: (activity) {
              toggleCalled = true;
              lastActivity = activity;
            },
            onEdit: (activity) {
              editCalled = true;
              lastActivity = activity;
            },
            onDelete: (activity) {
              deleteCalled = true;
              lastActivity = activity;
            },
            onViewAll: () {
              viewAllCalled = true;
            },
            onAddNew: () {
              addNewCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardActivities), findsOneWidget);
    });

    testWidgets('debería mostrar título y botones', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Today\'s Activities'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('debería mostrar mensaje cuando no hay actividades', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No activities for today'), findsOneWidget);
    });

    testWidgets('debería mostrar actividades cuando hay actividades disponibles', (WidgetTester tester) async {
      final activities = [
        Activity(
          id: '1',
          name: 'Test Activity',
          description: 'Test',
          date: DateTime.now(),
          category: 'work',
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(createTestWidget(activities: activities));
      await tester.pumpAndSettle();

      expect(find.text('Test Activity'), findsOneWidget);
    });

    testWidgets('debería llamar onViewAll cuando se toca el botón', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(viewAllCalled, isTrue);
    });

    testWidgets('debería llamar onAddNew cuando se toca el botón de agregar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(addNewCalled, isTrue);
    });
  });
}

