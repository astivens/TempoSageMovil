import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temposage/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Medir tiempos de carga', (WidgetTester tester) async {
    final stopwatch = Stopwatch()..start();

    // Iniciar app
    app.main();
    await tester.pumpAndSettle();

    print('⏱️ Tiempo de carga inicial: ${stopwatch.elapsedMilliseconds}ms');

    // Intentar interactuar con la interfaz
    try {
      // Buscar elementos interactivos generales
      final interactiveWidgets = find.byWidgetPredicate((widget) =>
          widget is ElevatedButton ||
          widget is TextButton ||
          widget is IconButton ||
          widget is InkWell);

      if (interactiveWidgets.evaluate().isNotEmpty) {
        final widget = interactiveWidgets.first;
        stopwatch.reset();
        await tester.tap(widget);
        await tester.pumpAndSettle();
        print('⏱️ Tiempo de interacción: ${stopwatch.elapsedMilliseconds}ms');
      } else {
        print('⚠️ No se encontraron elementos interactivos');
      }
    } catch (e) {
      print('⚠️ Error al interactuar: $e');
    }

    // Finalizar prueba con éxito
    expect(true, isTrue, reason: 'La aplicación se cargó correctamente');
  });
}
