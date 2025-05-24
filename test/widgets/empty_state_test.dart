import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('Renderiza correctamente con propiedades básicas',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Sin elementos',
              message: 'No hay elementos para mostrar',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Sin elementos'), findsOneWidget);
      expect(find.text('No hay elementos para mostrar'), findsOneWidget);
    });

    testWidgets('Muestra botón de acción cuando se proporciona',
        (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'Sin elementos',
              message: 'No hay elementos para mostrar',
              actionLabel: 'Agregar elemento',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Agregar elemento'), findsOneWidget);

      await tester.tap(find.text('Agregar elemento'));
      await tester.pump();
      expect(actionCalled, true);
    });

    testWidgets('Factory activities crea estado vacío para actividades',
        (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.activities(
              onCreateActivity: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      expect(find.text('No hay actividades'), findsOneWidget);
      expect(find.textContaining('Comienza creando'), findsOneWidget);
      expect(find.text('Crear Actividad'), findsOneWidget);

      await tester.tap(find.text('Crear Actividad'));
      await tester.pump();
      expect(actionCalled, true);
    });

    testWidgets('Factory habits crea estado vacío para hábitos',
        (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.habits(
              onCreateHabit: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
      expect(find.text('Sin hábitos por seguir'), findsOneWidget);
      expect(find.textContaining('Desarrolla hábitos'), findsOneWidget);
      expect(find.text('Agregar Hábito'), findsOneWidget);

      await tester.tap(find.text('Agregar Hábito'));
      await tester.pump();
      expect(actionCalled, true);
    });

    testWidgets('Factory timeBlocks crea estado vacío para bloques de tiempo',
        (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.timeBlocks(
              onCreateBlock: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      expect(find.text('Agenda vacía'), findsOneWidget);
      expect(find.textContaining('Planifica tu día'), findsOneWidget);
      expect(find.text('Crear Bloque'), findsOneWidget);

      await tester.tap(find.text('Crear Bloque'));
      await tester.pump();
      expect(actionCalled, true);
    });

    testWidgets('Factory dashboard crea estado de bienvenida',
        (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.dashboard(
              onGetStarted: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
      expect(find.text('¡Bienvenido a TempoSage!'), findsOneWidget);
      expect(find.textContaining('Comienza organizando'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);

      await tester.tap(find.text('Empezar'));
      await tester.pump();
      expect(actionCalled, true);
    });

    testWidgets('Factory noResults crea estado sin resultados',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noResults(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Sin resultados'), findsOneWidget);
      expect(find.text('No hay elementos que mostrar'), findsOneWidget);
    });

    testWidgets('Factory noConnection crea estado sin conexión',
        (WidgetTester tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.noConnection(
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.textContaining('Verifica tu conexión'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(retryCalled, true);
    });

    testWidgets('Usa ilustración personalizada cuando se proporciona',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Título',
              message: 'Mensaje',
              customIllustration: Container(
                key: const Key('custom_illustration'),
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_illustration')), findsOneWidget);
      // El ícono no se muestra cuando hay ilustración personalizada
    });

    testWidgets('Aplica colores personalizados correctamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Título',
              message: 'Mensaje',
              iconColor: Colors.red,
            ),
          ),
        ),
      );

      // El ícono se renderiza con opacidad, así que verificamos que contiene el color base
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.inbox));
      expect(iconWidget.color.toString().contains('red'), true);
    });

    testWidgets('Aplica tamaño de ícono personalizado',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Título',
              message: 'Mensaje',
              iconSize: 100,
            ),
          ),
        ),
      );

      // El ícono se renderiza al 50% del tamaño del contenedor
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.inbox));
      expect(iconWidget.size, 50.0); // 100 * 0.5
    });
  });

  group('LoadingState', () {
    testWidgets('Renderiza indicador de carga circular por defecto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingState(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // LoadingState no tiene mensaje por defecto
    });

    testWidgets('Muestra mensaje personalizado', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingState(
              message: 'Cargando datos...',
            ),
          ),
        ),
      );

      expect(find.text('Cargando datos...'), findsOneWidget);
    });

    testWidgets('Muestra skeleton cuando showSkeleton es true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingState(
              showSkeleton: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Verificar que se muestran elementos skeleton
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('Skeleton tiene animación funcionando',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingState(
              showSkeleton: true,
            ),
          ),
        ),
      );

      // Verificar que la animación está funcionando
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // El skeleton debería estar presente
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });
  });

  group('ErrorState', () {
    testWidgets('Renderiza correctamente con propiedades básicas',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error',
              message: 'Algo salió mal',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Algo salió mal'), findsOneWidget);
    });

    testWidgets('Muestra botón de reintentar cuando se proporciona callback',
        (WidgetTester tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error',
              message: 'Algo salió mal',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(retryCalled, true);
    });

    testWidgets(
        'No muestra botón de reintentar cuando no se proporciona callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error',
              message: 'Algo salió mal',
            ),
          ),
        ),
      );

      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('Usa ícono personalizado cuando se proporciona',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error',
              message: 'Algo salió mal',
              icon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
