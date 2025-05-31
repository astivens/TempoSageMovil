import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temposage/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UI Performance Tests', () {
    testWidgets('Medir rendimiento durante navegación entre vistas',
        (WidgetTester tester) async {
      // Iniciar la aplicación
      app.main();
      await tester.pumpAndSettle();

      final binding = tester.binding as IntegrationTestWidgetsFlutterBinding;

      // Navegar a diferentes pantallas y medir el rendimiento
      await binding.traceAction(() async {
        // Buscar botones de navegación (ajustar según la UI real)
        final navigationButton = find.byType(BottomNavigationBar);

        // Verificar si se encontró el BottomNavigationBar
        if (navigationButton.evaluate().isNotEmpty) {
          // Navegar a la segunda tab
          await tester.tap(find.byIcon(Icons.calendar_today).first);
          await tester.pumpAndSettle();

          // Navegar a la tercera tab
          await tester.tap(find.byIcon(Icons.analytics).first);
          await tester.pumpAndSettle();

          // Volver a la primera tab
          await tester.tap(find.byIcon(Icons.home).first);
          await tester.pumpAndSettle();
        } else {
          // Alternativa: buscar otros elementos de navegación
          print(
              'BottomNavigationBar no encontrado, usando navegación alternativa');

          // Ejemplo: buscar botones de navegación por texto
          final buttons = find.byType(ElevatedButton);
          if (buttons.evaluate().isNotEmpty) {
            await tester.tap(buttons.first);
            await tester.pumpAndSettle();

            // Volver atrás
            await tester.pageBack();
            await tester.pumpAndSettle();
          }
        }
      }, reportKey: 'navigation_performance');
    });

    testWidgets('Medir rendimiento durante scroll en listas',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final binding = tester.binding as IntegrationTestWidgetsFlutterBinding;

      // Buscar una lista para hacer scroll
      final listView = find.byType(ListView);

      if (listView.evaluate().isNotEmpty) {
        await binding.traceAction(() async {
          // Realizar scroll hacia abajo
          await tester.fling(listView.first, const Offset(0, -500), 1000);
          await tester.pumpAndSettle();

          // Esperar un momento
          await Future.delayed(const Duration(milliseconds: 500));

          // Realizar scroll hacia arriba
          await tester.fling(listView.first, const Offset(0, 500), 1000);
          await tester.pumpAndSettle();
        }, reportKey: 'scroll_performance');
      } else {
        print('No se encontró ListView para medir rendimiento de scroll');
      }
    });

    testWidgets('Medir rendimiento al abrir diálogos y menús',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final binding = tester.binding as IntegrationTestWidgetsFlutterBinding;

      // Buscar botones que abran diálogos o menús
      final fabButton = find.byType(FloatingActionButton);

      if (fabButton.evaluate().isNotEmpty) {
        await binding.traceAction(() async {
          // Tap en FAB para abrir diálogo/menú
          await tester.tap(fabButton.first);
          await tester.pumpAndSettle();

          // Cerrar diálogo si se abrió (tap fuera o en botón cancelar)
          final backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
          } else {
            // Tap fuera para cerrar
            await tester.tapAt(const Offset(20, 20));
          }
          await tester.pumpAndSettle();
        }, reportKey: 'dialog_performance');
      } else {
        print(
            'No se encontró FloatingActionButton para medir rendimiento de diálogos');
      }
    });
  });
}
