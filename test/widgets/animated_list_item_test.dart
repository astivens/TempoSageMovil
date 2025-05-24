import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/animated_list_item.dart';

void main() {
  group('AnimatedListItem', () {
    testWidgets('Renderiza correctamente el widget hijo',
        (WidgetTester tester) async {
      const testChild = Text('Contenido de prueba');

      // Crear el widget sin animación automática para evitar timers pendientes
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              child: testChild,
              animateOnInit: false, // Desactivar animación automática
            ),
          ),
        ),
      );

      // Verificar que se muestra el contenido
      expect(find.text('Contenido de prueba'), findsOneWidget);
    });

    testWidgets('Comienza con opacidad 0 y cambia durante la animación',
        (WidgetTester tester) async {
      const testChild = Text('Elemento animado');

      // Crear un controlador de animación para controlar la animación
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

      // Crear el widget con animación externa
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              child: testChild,
              animation: animation, // Usar animación externa
            ),
          ),
        ),
      );

      // Verificar opacidad inicial (debería ser 0)
      final opacityFinder = find.byType(Opacity);
      expect(opacityFinder, findsOneWidget);

      final initialOpacity = tester.widget<Opacity>(opacityFinder);
      expect(initialOpacity.opacity, equals(0.0));

      // Iniciar la animación
      controller.forward();

      // Avanzar el tiempo para permitir que progrese la animación
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // La animación debería estar en curso, la opacidad habrá cambiado
      final opacity = tester.widget<Opacity>(opacityFinder);
      expect(opacity.opacity, greaterThan(0.0));

      // Limpiar recursos
      controller.dispose();
    });

    testWidgets('Acepta una animación externa', (WidgetTester tester) async {
      const testChild = Text('Animación externa');

      // Crear un controlador de animación
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

      // Crear el widget con la animación externa
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              child: testChild,
              animation: animation,
            ),
          ),
        ),
      );

      // Verificar que se muestra el contenido
      expect(find.text('Animación externa'), findsOneWidget);

      // Iniciar la animación externa
      controller.forward();

      // Avanzar el tiempo
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // La opacidad debería haber cambiado
      final opacityFinder = find.byType(Opacity);
      final opacity = tester.widget<Opacity>(opacityFinder);
      expect(opacity.opacity, greaterThan(0.0));

      // Limpiar recursos
      controller.dispose();
    });
  });
}

/// Helper class para proporcionar vsync en pruebas
class TestVSync extends TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
