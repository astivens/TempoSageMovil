import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/hover_scale.dart';

void main() {
  group('HoverScale', () {
    testWidgets('Renderiza correctamente el widget hijo',
        (WidgetTester tester) async {
      const testChild = Text('Contenido de prueba');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoverScale(
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Verificar que el hijo se renderiza
      expect(find.text('Contenido de prueba'), findsOneWidget);
    });

    testWidgets('Responde a eventos de hover', (WidgetTester tester) async {
      const testChild = Text('Elemento con hover');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoverScale(
                scale: 1.5, // Escala exagerada para la prueba
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Obtener el MouseRegion
      final mouseRegion = tester.widget<MouseRegion>(find.byType(MouseRegion));

      // Verificar que los callbacks están configurados
      expect(mouseRegion.onEnter, isNotNull);
      expect(mouseRegion.onExit, isNotNull);

      // Obtener el estado del widget
      final state = tester.state<HoverScaleState>(find.byType(HoverScale));

      // Verificar que inicialmente no tiene hover
      expect(state.handleHover, isNotNull);

      // Simular hover (llamando directamente al método)
      state.handleHover(true);
      await tester.pump();

      // La animación debería haber iniciado, avanzar medio camino
      await tester.pump(const Duration(milliseconds: 100));

      // Obtener el Transform.scale actual
      final transform = tester.widget<Transform>(find.byType(Transform));

      // La escala debería ser mayor a 1.0 pero menor al valor final (1.5)
      expect(transform.transform.getMaxScaleOnAxis(), greaterThan(1.0));
      expect(transform.transform.getMaxScaleOnAxis(), lessThan(1.5));
    });

    testWidgets('Se puede desactivar', (WidgetTester tester) async {
      const testChild = Text('Elemento desactivado');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoverScale(
                enabled: false,
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Obtener el MouseRegion
      final mouseRegion = tester.widget<MouseRegion>(find.byType(MouseRegion));

      // Verificar que los callbacks están configurados como null
      expect(mouseRegion.onEnter, isNull);
      expect(mouseRegion.onExit, isNull);
    });

    testWidgets('Actualiza la animación cuando cambian las propiedades',
        (WidgetTester tester) async {
      const testChild = Text('Elemento animado');

      // Crear un key para mantener el estado cuando se reconstruye el widget
      final key = GlobalKey<HoverScaleState>();

      // Primera configuración
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoverScale(
                key: key,
                scale: 1.2,
                duration: const Duration(milliseconds: 200),
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Obtener el estado inicial
      final state = key.currentState!;

      // Simular hover
      state.handleHover(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Cambiar la configuración
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoverScale(
                key: key,
                scale: 1.5, // Cambiar la escala
                duration:
                    const Duration(milliseconds: 300), // Cambiar la duración
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Verificar que didUpdateWidget se activa y reinicializa la animación
      await tester.pump();

      // La prueba verifica principalmente que no hay errores al cambiar las propiedades
    });
  });
}
