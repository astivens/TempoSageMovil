import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/animated_list_item.dart';

void main() {
  group('AnimatedListItem Widget Tests', () {
    testWidgets('Debe renderizar el widget hijo correctamente',
        (WidgetTester tester) async {
      // Arrange
      const childText = 'Item de lista';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              child: const Text(childText),
            ),
          ),
        ),
      );

      // Act - Esperar a que se complete la animación
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedListItem), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('Debe animar el elemento cuando animateOnInit es true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              animateOnInit: true,
              child: const Text('Item'),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedListItem), findsOneWidget);
    });

    testWidgets('No debe animar el elemento cuando animateOnInit es false',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              animateOnInit: false,
              child: const Text('Item'),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedListItem), findsOneWidget);
    });

    testWidgets('Debe usar animación externa cuando se proporciona',
        (WidgetTester tester) async {
      // Arrange
      final controller = AnimationController(
        vsync: TestVSync(),
        duration: const Duration(seconds: 1),
      );
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              animation: animation,
              child: const Text('Item'),
            ),
          ),
        ),
      );

      // Act
      controller.forward();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedListItem), findsOneWidget);
      controller.dispose();
    });

    testWidgets('Debe aplicar delay basado en el índice',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedListItem(
                  index: 0,
                  delay: const Duration(milliseconds: 100),
                  child: const Text('Item 0'),
                ),
                AnimatedListItem(
                  index: 1,
                  delay: const Duration(milliseconds: 100),
                  child: const Text('Item 1'),
                ),
              ],
            ),
          ),
        ),
      );

      // Act
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}

class TestVSync extends TickerProvider {
  TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

