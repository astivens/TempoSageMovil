import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Necesitarás importar tus widgets principales aquí
// import 'package:temposage/features/home/presentation/pages/home_page.dart';

void main() {
  group('Pruebas de Portabilidad y Responsividad', () {
    // Definir dimensiones de diferentes dispositivos para probar
    const mobileSize = Size(360, 640); // Smartphone típico
    const tabletSize = Size(768, 1024); // Tablet típica
    const desktopSize = Size(1366, 768); // Escritorio típico

    Widget buildTestWidget() {
      // Reemplazar esto con tu widget real de la aplicación
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('TempoSage'),
          ),
          body: Center(
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: 800), // Restringir el ancho máximo
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Contenido principal'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text('Calendario'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('La interfaz debe adaptarse a tamaño móvil',
        (WidgetTester tester) async {
      // Configurar tamaño de dispositivo móvil
      tester.binding.window.physicalSizeTestValue = mobileSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      // Verificar que los elementos clave son visibles y correctamente posicionados
      expect(find.text('TempoSage'), findsOneWidget);
      expect(find.text('Contenido principal'), findsOneWidget);

      // En móvil, los elementos deberían estar centrados y apilados verticalmente
      final contentFinder = find.text('Contenido principal');
      final contentPos = tester.getCenter(contentFinder);
      expect(contentPos.dx, closeTo(mobileSize.width / 2, 10),
          reason: 'El contenido debe estar centrado horizontalmente en móvil');
    });

    testWidgets('La interfaz debe adaptarse a tamaño tablet',
        (WidgetTester tester) async {
      // Configurar tamaño de tablet
      tester.binding.window.physicalSizeTestValue = tabletSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('TempoSage'), findsOneWidget);
      expect(find.text('Contenido principal'), findsOneWidget);

      // Verificar que el layout se ajusta adecuadamente
      final calendarFinder = find.text('Calendario');
      expect(calendarFinder, findsOneWidget);

      // La posición exacta dependerá de tu diseño responsivo
      // Esta es una verificación general
      expect(find.byType(Row), findsOneWidget,
          reason: 'Los elementos deberían organizarse en fila en tablet');
    });

    testWidgets('La interfaz debe adaptarse a tamaño escritorio',
        (WidgetTester tester) async {
      // Configurar tamaño de escritorio
      tester.binding.window.physicalSizeTestValue = desktopSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('TempoSage'), findsOneWidget);

      // Verificar que el layout se ajusta adecuadamente
      // En escritorio, el contenido debe estar centrado y no ocupar todo el ancho
      final containerFinder = find.byType(Container);
      final containerSize = tester.getSize(containerFinder);

      // El contenedor debe respetar el maxWidth de 800
      expect(containerSize.width, lessThanOrEqualTo(800),
          reason:
              'El contenido debe tener un ancho máximo razonable en escritorio');
    });

    testWidgets('La interfaz debe manejar correctamente cambios de orientación',
        (WidgetTester tester) async {
      // Configurar tamaño en modo portrait
      const portraitSize = Size(360, 640);
      tester.binding.window.physicalSizeTestValue = portraitSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Act - Portrait
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Capturar posiciones en portrait
      final portraitContentPos =
          tester.getCenter(find.text('Contenido principal'));

      // Cambiar a landscape
      const landscapeSize = Size(640, 360); // Invertir dimensiones
      tester.binding.window.physicalSizeTestValue = landscapeSize;
      await tester.pumpAndSettle();

      // Capturar posiciones en landscape
      final landscapeContentPos =
          tester.getCenter(find.text('Contenido principal'));

      // Assert
      // Verificar que las posiciones cambiaron apropiadamente
      expect(portraitContentPos, isNot(equals(landscapeContentPos)),
          reason:
              'La posición del contenido debe ajustarse al cambiar la orientación');

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
