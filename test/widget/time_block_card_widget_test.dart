import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/timeblocks/presentation/widgets/time_block_card.dart';
import 'package:temposage/features/timeblocks/data/models/time_block_model.dart';

void main() {
  group('TimeBlockCard Widget Tests', () {
    bool onTapCalled = false;

    setUp(() {
      onTapCalled = false;
    });

    Widget createTestWidget({
      TimeBlockModel? timeBlock,
      VoidCallback? onTap,
    }) {
      final testTimeBlock = timeBlock ?? TimeBlockModel.create(
        title: 'Test Block',
        description: 'Test Description',
        startTime: DateTime(2023, 1, 1, 9, 0),
        endTime: DateTime(2023, 1, 1, 10, 0),
        category: 'work',
        color: '#2196F3',
      );

      return MaterialApp(
        home: Scaffold(
          body: TimeBlockCard(
            timeBlock: testTimeBlock,
            onTap: onTap ?? () {
              onTapCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TimeBlockCard), findsOneWidget);
    });

    testWidgets('debería mostrar título del time block', (WidgetTester tester) async {
      final timeBlock = TimeBlockModel.create(
        title: 'Meeting',
        description: 'Team meeting',
        startTime: DateTime(2023, 1, 1, 10, 0),
        endTime: DateTime(2023, 1, 1, 11, 0),
        category: 'work',
        color: '#4CAF50',
      );

      await tester.pumpWidget(createTestWidget(timeBlock: timeBlock));
      await tester.pumpAndSettle();

      expect(find.text('Meeting'), findsOneWidget);
    });

    testWidgets('debería mostrar rango de tiempo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('debería mostrar descripción cuando está presente', (WidgetTester tester) async {
      final timeBlock = TimeBlockModel.create(
        title: 'Test',
        description: 'Test Description',
        startTime: DateTime(2023, 1, 1, 9, 0),
        endTime: DateTime(2023, 1, 1, 10, 0),
        category: 'work',
        color: '#2196F3',
      );

      await tester.pumpWidget(createTestWidget(timeBlock: timeBlock));
      await tester.pumpAndSettle();

      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('debería llamar onTap cuando se toca', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TimeBlockCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('debería mostrar chip de categoría', (WidgetTester tester) async {
      final timeBlock = TimeBlockModel.create(
        title: 'Test',
        description: 'Test',
        startTime: DateTime(2023, 1, 1, 9, 0),
        endTime: DateTime(2023, 1, 1, 10, 0),
        category: 'personal',
        color: '#FF9800',
      );

      await tester.pumpWidget(createTestWidget(timeBlock: timeBlock));
      await tester.pumpAndSettle();

      expect(find.text('PERSONAL'), findsOneWidget);
    });

    testWidgets('debería mostrar chip de tiempo de enfoque cuando isFocusTime es true', (WidgetTester tester) async {
      final timeBlock = TimeBlockModel(
        id: 'test-1',
        title: 'Focus Time',
        description: 'Test',
        startTime: DateTime(2023, 1, 1, 9, 0),
        endTime: DateTime(2023, 1, 1, 10, 0),
        category: 'work',
        color: '#2196F3',
        isFocusTime: true,
      );

      await tester.pumpWidget(createTestWidget(timeBlock: timeBlock));
      await tester.pumpAndSettle();

      expect(find.text('TIEMPO DE ENFOQUE'), findsOneWidget);
    });
  });
}

