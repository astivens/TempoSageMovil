import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/presentation/widgets/dashboard_habits.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';

void main() {
  group('DashboardHabits Widget Tests', () {
    bool completeCalled = false;
    bool deleteCalled = false;
    bool viewAllCalled = false;
    bool addNewCalled = false;
    HabitModel? lastHabit;

    setUp(() {
      completeCalled = false;
      deleteCalled = false;
      viewAllCalled = false;
      addNewCalled = false;
      lastHabit = null;
    });

    Widget createTestWidget({List<HabitModel> habits = const []}) {
      return MaterialApp(
        home: Scaffold(
          body: DashboardHabits(
            habits: habits,
            onComplete: (habit) {
              completeCalled = true;
              lastHabit = habit;
            },
            onDelete: (habit) {
              deleteCalled = true;
              lastHabit = habit;
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

      expect(find.byType(DashboardHabits), findsOneWidget);
    });

    testWidgets('debería mostrar título y botones', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hábitos de Hoy'), findsOneWidget);
      expect(find.text('Ver Todos'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('debería mostrar mensaje cuando no hay hábitos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No hay hábitos para hoy'), findsOneWidget);
    });

    testWidgets('debería mostrar hábitos cuando hay hábitos disponibles', (WidgetTester tester) async {
      final habits = [
        HabitModel.create(
          title: 'Morning Exercise',
          description: 'Daily exercise',
          daysOfWeek: ['Monday'],
          category: 'health',
          reminder: 'none',
          time: '07:00',
        ),
      ];

      await tester.pumpWidget(createTestWidget(habits: habits));
      await tester.pumpAndSettle();

      expect(find.text('Morning Exercise'), findsOneWidget);
    });

    testWidgets('debería llamar onViewAll cuando se toca el botón', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver Todos'));
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

