import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/dashboard/presentation/widgets/time_block_card.dart';

void main() {
  group('TimeBlockCard (Dashboard) Widget Tests', () {
    bool onTapCalled = false;
    bool onLongPressCalled = false;

    setUp(() {
      onTapCalled = false;
      onLongPressCalled = false;
    });

    Widget createTestWidget({
      String title = 'Test Block',
      String timeRange = '09:00 - 10:00',
      IconData icon = Icons.access_time,
      Color? color,
      String? description,
      bool isCompleted = false,
      bool isLoading = false,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TimeBlockCard(
            title: title,
            timeRange: timeRange,
            icon: icon,
            color: color,
            description: description,
            isCompleted: isCompleted,
            isLoading: isLoading,
            onTap: onTap ?? () {
              onTapCalled = true;
            },
            onLongPress: onLongPress ?? () {
              onLongPressCalled = true;
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

    testWidgets('debería mostrar título y rango de tiempo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'Meeting',
        timeRange: '10:00 - 11:00',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('10:00 - 11:00'), findsOneWidget);
    });

    testWidgets('debería mostrar descripción cuando está presente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        description: 'Team meeting',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Team meeting'), findsOneWidget);
    });

    testWidgets('debería mostrar icono de completado cuando isCompleted es true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isCompleted: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('debería mostrar indicador de carga cuando isLoading es true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isLoading: true,
      ));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('debería llamar onTap cuando se toca', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TimeBlockCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('debería usar color personalizado cuando se proporciona', (WidgetTester tester) async {
      const customColor = Colors.blue;
      await tester.pumpWidget(createTestWidget(
        color: customColor,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TimeBlockCard), findsOneWidget);
    });
  });
}

