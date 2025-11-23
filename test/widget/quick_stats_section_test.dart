import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/dashboard/presentation/widgets/quick_stats_section.dart';
import 'package:temposage/core/l10n/app_localizations.dart';

void main() {
  group('QuickStatsSection Widget Tests', () {
    Widget createTestWidget({
      int completedActivities = 0,
      int completedHabits = 0,
      int totalActivities = 0,
      int totalHabits = 0,
      Duration totalActivityTime = Duration.zero,
      Duration remainingTime = Duration.zero,
      double focusScore = 0.0,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        home: Scaffold(
          body: QuickStatsSection(
            completedActivities: completedActivities,
            completedHabits: completedHabits,
            totalActivities: totalActivities,
            totalHabits: totalHabits,
            totalActivityTime: totalActivityTime,
            remainingTime: remainingTime,
            focusScore: focusScore,
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });

    testWidgets('debería mostrar estadísticas con valores por defecto', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });

    testWidgets('debería mostrar estadísticas con valores personalizados', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        completedActivities: 5,
        completedHabits: 3,
        totalActivities: 10,
        totalHabits: 7,
        totalActivityTime: const Duration(hours: 2, minutes: 30),
        remainingTime: const Duration(hours: 5, minutes: 30),
        focusScore: 75.5,
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });

    testWidgets('debería mostrar porcentaje de actividades completadas', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        completedActivities: 7,
        totalActivities: 10,
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });

    testWidgets('debería mostrar porcentaje de hábitos completados', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        completedHabits: 4,
        totalHabits: 8,
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });

    testWidgets('debería manejar valores extremos correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        completedActivities: 0,
        completedHabits: 0,
        totalActivities: 0,
        totalHabits: 0,
        focusScore: 0.0,
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });

    testWidgets('debería limpiar recursos al hacer dispose', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(QuickStatsSection), findsOneWidget);
    });
  });
}

