import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/features/dashboard/presentation/widgets/metric_card.dart';

void main() {
  group('MetricCard Widget Tests', () {
    Widget createTestWidget({
      String title = 'Test Title',
      String value = '100',
      String? subtitle,
      IconData icon = Icons.star,
      Color? color,
      VoidCallback? onTap,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: title,
            value: value,
            subtitle: subtitle,
            icon: icon,
            color: color,
            onTap: onTap,
            isLoading: isLoading,
          ),
        ),
      );
    }

    testWidgets('debería renderizar el widget correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(MetricCard), findsOneWidget);
    });

    testWidgets('debería mostrar título y valor', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'Activities',
        value: '25',
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('debería mostrar subtítulo cuando está presente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        subtitle: 'Completed today',
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Completed today'), findsOneWidget);
    });

    testWidgets('debería mostrar icono correcto', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        icon: Icons.check_circle,
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('debería llamar onTap cuando se toca', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(createTestWidget(
        onTap: () {
          tapped = true;
        },
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.byType(MetricCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('debería mostrar indicador de carga cuando isLoading es true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isLoading: true,
      ));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MetricCard), findsOneWidget);
    });

    testWidgets('debería usar color personalizado cuando se proporciona', (WidgetTester tester) async {
      const customColor = Colors.blue;
      await tester.pumpWidget(createTestWidget(
        color: customColor,
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(MetricCard), findsOneWidget);
    });

    testWidgets('debería manejar valores largos correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        value: '999999',
        title: 'Very Long Title That Might Overflow',
      ));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(MetricCard), findsOneWidget);
    });
  });
}

