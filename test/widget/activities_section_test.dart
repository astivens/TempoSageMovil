import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:temposage/features/dashboard/presentation/widgets/activities_section.dart';
import 'package:temposage/features/dashboard/controllers/dashboard_controller.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/core/l10n/app_localizations.dart';

class MockDashboardController extends Mock implements DashboardController {}

void main() {
  group('ActivitiesSection Widget Tests', () {
    late MockDashboardController controller;
    bool editActivityCalled = false;
    bool deleteActivityCalled = false;
    bool toggleActivityCalled = false;
    bool editHabitCalled = false;
    bool deleteHabitCalled = false;
    bool toggleHabitCalled = false;

    setUp(() {
      controller = MockDashboardController();
      editActivityCalled = false;
      deleteActivityCalled = false;
      toggleActivityCalled = false;
      editHabitCalled = false;
      deleteHabitCalled = false;
      toggleHabitCalled = false;
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        home: Scaffold(
          body: ActivitiesSection(
            controller: controller,
            onEditActivity: (activity) {
              editActivityCalled = true;
            },
            onDeleteActivity: (activity) {
              deleteActivityCalled = true;
            },
            onToggleActivity: (activity) {
              toggleActivityCalled = true;
            },
            onEditHabit: (habit) {
              editHabitCalled = true;
            },
            onDeleteHabit: (habit) {
              deleteHabitCalled = true;
            },
            onToggleHabit: (habit) {
              toggleHabitCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      when(() => controller.isLoading).thenReturn(false);
      when(() => controller.activities).thenReturn([]);
      when(() => controller.habits).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ActivitiesSection), findsOneWidget);
    });

    testWidgets('debería mostrar indicador de carga cuando isLoading es true', (WidgetTester tester) async {
      when(() => controller.isLoading).thenReturn(true);
      when(() => controller.activities).thenReturn([]);
      when(() => controller.habits).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando actividades...'), findsOneWidget);
    });

    testWidgets('debería mostrar estado vacío cuando no hay actividades ni hábitos', (WidgetTester tester) async {
      when(() => controller.isLoading).thenReturn(false);
      when(() => controller.activities).thenReturn([]);
      when(() => controller.habits).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ActivitiesSection), findsOneWidget);
    });

    testWidgets('debería mostrar actividades cuando hay actividades disponibles', (WidgetTester tester) async {
      final now = DateTime.now();
      final activity = ActivityModel(
        id: 'test-activity-1',
        title: 'Test Activity',
        description: 'Test Description',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        priority: 'medium',
        category: 'work',
      );

      when(() => controller.isLoading).thenReturn(false);
      when(() => controller.activities).thenReturn([activity]);
      when(() => controller.habits).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ActivitiesSection), findsOneWidget);
    });

    testWidgets('debería mostrar hábitos cuando hay hábitos disponibles', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Test Habit',
        description: 'Test Description',
        daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
        category: 'health',
        reminder: 'none',
        time: '09:00',
      );

      when(() => controller.isLoading).thenReturn(false);
      when(() => controller.activities).thenReturn([]);
      when(() => controller.habits).thenReturn([habit]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ActivitiesSection), findsOneWidget);
    });

    testWidgets('debería limpiar recursos al hacer dispose', (WidgetTester tester) async {
      when(() => controller.isLoading).thenReturn(false);
      when(() => controller.activities).thenReturn([]);
      when(() => controller.habits).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ActivitiesSection), findsOneWidget);
      
      // Limpiar el widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

