import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/activities/presentation/widgets/activity_card.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';

void main() {
  group('ActivityCard Widget Tests', () {
    late ActivityModel testActivity;

    setUp(() {
      testActivity = ActivityModel(
        id: '1',
        title: 'Test Activity',
        description: 'Test Description',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        category: 'Work',
        priority: 'High',
        isCompleted: false,
      );
    });

    testWidgets('Debe renderizar la tarjeta con la actividad correcta',
        (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      bool wasToggled = false;
      bool wasEdited = false;
      bool wasDeleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: testActivity,
              onTap: () {
                wasTapped = true;
              },
              onToggleComplete: () {
                wasToggled = true;
              },
              onEdit: () {
                wasEdited = true;
              },
              onDelete: () {
                wasDeleted = true;
              },
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional para verificar renderizado

      // Assert
      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.text('Test Activity'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('Debe llamar a onTap cuando se toca la tarjeta',
        (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: testActivity,
              onTap: () {
                wasTapped = true;
              },
              onToggleComplete: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('Debe mostrar tachado cuando la actividad está completada',
        (WidgetTester tester) async {
      // Arrange
      final completedActivity = testActivity.copyWith(isCompleted: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: completedActivity,
              onTap: () {},
              onToggleComplete: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      final textWidget = tester.widget<Text>(find.text('Test Activity'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('Debe mostrar icono de hábito cuando isHabit es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: testActivity,
              isHabit: true,
              onTap: () {},
              onToggleComplete: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('No debe mostrar icono de hábito cuando isHabit es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: testActivity,
              isHabit: false,
              onTap: () {},
              onToggleComplete: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.repeat), findsNothing);
    });

    testWidgets('Debe llamar a onToggleComplete cuando se toca el checkbox',
        (WidgetTester tester) async {
      // Arrange
      bool wasToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: testActivity,
              onTap: () {},
              onToggleComplete: () {
                wasToggled = true;
              },
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act
      final checkboxes = find.byType(InkWell);
      await tester.tap(checkboxes.last);
      await tester.pump();

      // Assert
      expect(wasToggled, isTrue);
    });

    testWidgets('Debe mostrar checkbox marcado cuando la actividad está completada',
        (WidgetTester tester) async {
      // Arrange
      final completedActivity = testActivity.copyWith(isCompleted: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: completedActivity,
              onTap: () {},
              onToggleComplete: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}

