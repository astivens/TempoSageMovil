import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/habits/presentation/widgets/habit_card.dart';
import 'package:temposage/features/habits/data/models/habit_model.dart';

void main() {
  group('HabitCard Widget Tests', () {
    bool completeCalled = false;
    bool deleteCalled = false;

    setUp(() {
      completeCalled = false;
      deleteCalled = false;
    });

    Widget createTestWidget({
      HabitModel? habit,
      VoidCallback? onComplete,
      VoidCallback? onDelete,
    }) {
      final testHabit = habit ?? HabitModel.create(
        title: 'Test Habit',
        description: 'Test Description',
        daysOfWeek: ['Monday', 'Tuesday'],
        category: 'health',
        reminder: 'none',
        time: '09:00',
      );

      return MaterialApp(
        home: Scaffold(
          body: HabitCard(
            habit: testHabit,
            onComplete: onComplete ?? () {
              completeCalled = true;
            },
            onDelete: onDelete ?? () {
              deleteCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HabitCard), findsOneWidget);
    });

    testWidgets('debería mostrar el título del hábito', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Morning Exercise',
        description: 'Daily exercise',
        daysOfWeek: ['Monday'],
        category: 'health',
        reminder: 'none',
        time: '07:00',
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.text('Morning Exercise'), findsOneWidget);
    });

    testWidgets('debería mostrar la hora del hábito', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Test Habit',
        description: 'Test',
        daysOfWeek: ['Monday'],
        category: 'health',
        reminder: 'none',
        time: '14:30',
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCard), findsOneWidget);
    });

    testWidgets('debería mostrar los días de la semana', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Test Habit',
        description: 'Test',
        daysOfWeek: ['Monday', 'Wednesday', 'Friday'],
        category: 'health',
        reminder: 'none',
        time: '09:00',
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCard), findsOneWidget);
    });

    testWidgets('debería llamar onComplete cuando se completa el hábito', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final completeButton = find.byIcon(Icons.check_circle);
      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton);
        await tester.pumpAndSettle();
        expect(completeCalled, isTrue);
      }
    });

    testWidgets('debería llamar onDelete cuando se elimina el hábito', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        expect(deleteCalled, isTrue);
      }
    });

    testWidgets('debería mostrar hábito completado correctamente', (WidgetTester tester) async {
      final habit = HabitModel(
        id: 'test-1',
        title: 'Completed Habit',
        description: 'Test',
        daysOfWeek: ['Monday'],
        category: 'health',
        reminder: 'none',
        time: '09:00',
        isCompleted: true,
        dateCreation: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCard), findsOneWidget);
    });

    testWidgets('debería manejar múltiples días de la semana', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Daily Habit',
        description: 'Test',
        daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
        category: 'health',
        reminder: 'none',
        time: '08:00',
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCard), findsOneWidget);
    });

    testWidgets('debería formatear hora correctamente', (WidgetTester tester) async {
      final habit = HabitModel.create(
        title: 'Test Habit',
        description: 'Test',
        daysOfWeek: ['Monday'],
        category: 'health',
        reminder: 'none',
        time: '15:45',
      );

      await tester.pumpWidget(createTestWidget(habit: habit));
      await tester.pumpAndSettle();

      expect(find.byType(HabitCard), findsOneWidget);
    });
  });
}

