import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/bottom_navigation.dart';

void main() {
  group('BottomNavigation Widget Tests', () {
    testWidgets('Debe renderizar la barra de navegación correctamente',
        (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;
      final items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
              items: items,
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(BottomNavigation), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Debe llamar a onTap cuando se selecciona un elemento',
        (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;
      final items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
              items: items,
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Settings'));
      await tester.pump();

      // Assert
      expect(selectedIndex, 1);
    });

    testWidgets('BottomNavigation.tempoSage debe crear barra de navegación estándar',
        (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation.tempoSage(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - No se requiere acción adicional

      // Assert
      expect(find.byType(BottomNavigation), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Actividades'), findsOneWidget);
      expect(find.text('Hábitos'), findsOneWidget);
      expect(find.text('Bloques'), findsOneWidget);
      expect(find.text('Chat IA'), findsOneWidget);
    });

    testWidgets('BottomNavigation.minimal debe crear barra de navegación minimalista',
        (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;
      final items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation.minimal(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
              items: items,
            ),
            body: const Text('Body'),
          ),
        ),
      );

      // Act - Esperar a que el widget se renderice completamente
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(BottomNavigation), findsOneWidget);
      // En modo minimalista, las etiquetas pueden estar presentes pero ocultas
      // Verificamos que el widget se creó correctamente
      final bottomNav = tester.widget<BottomNavigation>(find.byType(BottomNavigation));
      expect(bottomNav.showSelectedLabels, isFalse);
      expect(bottomNav.showUnselectedLabels, isFalse);
    });
  });
}

