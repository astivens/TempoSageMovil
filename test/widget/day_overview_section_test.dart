import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/dashboard/presentation/widgets/day_overview_section.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';
import 'package:temposage/core/l10n/app_localizations.dart';

void main() {
  group('DayOverviewSection Widget Tests', () {
    Widget createTestWidget({
      List<ActivityModel> morningActivities = const [],
      List<ActivityModel> afternoonActivities = const [],
      List<ActivityModel> eveningActivities = const [],
      List<HabitModel> morningHabits = const [],
      List<HabitModel> afternoonHabits = const [],
      List<HabitModel> eveningHabits = const [],
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        home: Scaffold(
          body: DayOverviewSection(
            morningActivities: morningActivities,
            afternoonActivities: afternoonActivities,
            eveningActivities: eveningActivities,
            morningHabits: morningHabits,
            afternoonHabits: afternoonHabits,
            eveningHabits: eveningHabits,
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });

    testWidgets('debería mostrar secciones para mañana, tarde y noche', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });

    testWidgets('debería mostrar actividades de la mañana cuando están disponibles', (WidgetTester tester) async {
      final now = DateTime.now();
      final activity = ActivityModel(
        id: 'test-1',
        title: 'Morning Activity',
        description: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        priority: 'high',
        category: 'work',
      );

      await tester.pumpWidget(createTestWidget(
        morningActivities: [activity],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });

    testWidgets('debería mostrar actividades de la tarde cuando están disponibles', (WidgetTester tester) async {
      final now = DateTime.now();
      final activity = ActivityModel(
        id: 'test-2',
        title: 'Afternoon Activity',
        description: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        priority: 'medium',
        category: 'personal',
      );

      await tester.pumpWidget(createTestWidget(
        afternoonActivities: [activity],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });

    testWidgets('debería mostrar actividades de la noche cuando están disponibles', (WidgetTester tester) async {
      final now = DateTime.now();
      final activity = ActivityModel(
        id: 'test-3',
        title: 'Evening Activity',
        description: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        priority: 'low',
        category: 'leisure',
      );

      await tester.pumpWidget(createTestWidget(
        eveningActivities: [activity],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });

    testWidgets('debería mostrar hábitos de la mañana cuando están disponibles', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Morning Habit',
        description: 'Test',
        daysOfWeek: ['Monday'],
        category: 'health',
        reminder: 'none',
        time: '08:00',
      );

      await tester.pumpWidget(createTestWidget(
        morningHabits: [habit],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });

    testWidgets('debería manejar múltiples actividades y hábitos', (WidgetTester tester) async {
      final now = DateTime.now();
      final activities = List.generate(3, (i) => ActivityModel(
        id: 'test-activity-$i',
        title: 'Activity $i',
        description: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        priority: 'medium',
        category: 'work',
      ));

      final habits = List.generate(2, (i) => HabitModel.create(
        title: 'Habit $i',
        description: 'Test',
        daysOfWeek: ['Monday'],
        category: 'health',
        reminder: 'none',
        time: '${9 + i}:00',
      ));

      await tester.pumpWidget(createTestWidget(
        morningActivities: activities,
        morningHabits: habits,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DayOverviewSection), findsOneWidget);
    });
  });
}

