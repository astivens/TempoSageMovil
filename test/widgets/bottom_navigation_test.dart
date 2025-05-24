import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposage/core/widgets/bottom_navigation.dart';

void main() {
  group('BottomNavigation', () {
    testWidgets('Renderiza correctamente con los elementos proporcionados',
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
              ],
            ),
          ),
        ),
      );

      // Verificar que se renderizan los elementos
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Buscar'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Llama al callback onTap al seleccionar un elemento',
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
              ],
            ),
          ),
        ),
      );

      // Verificar el índice inicial
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);

      // Tocar el segundo elemento
      await tester.tap(find.text('Buscar'));

      // Verificar que se actualizó el índice
      expect(selectedIndex, 1);
    });

    testWidgets('Factory tempoSage crea una barra con elementos predefinidos',
        (WidgetTester tester) async {
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
          ),
        ),
      );

      // Verificar que se renderizan los elementos predefinidos
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Actividades'), findsOneWidget);
      expect(find.text('Hábitos'), findsOneWidget);
      expect(find.text('Bloques'), findsOneWidget);

      // Verificar que se utilizan los iconos correctos (outlined cuando no están seleccionados)
      expect(find.byIcon(Icons.dashboard),
          findsOneWidget); // Activo porque currentIndex = 0
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });

    testWidgets('Factory minimal crea una barra sin etiquetas',
        (WidgetTester tester) async {
      int selectedIndex = 0;
      final items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
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
              selectedColor: Colors.red,
            ),
          ),
        ),
      );

      // Verificar que los iconos están presentes
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verificar la configuración de la barra
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.showSelectedLabels, false);
      expect(bottomNavBar.showUnselectedLabels, false);
      expect(bottomNavBar.selectedItemColor, Colors.red);
      expect(bottomNavBar.elevation, 0.0);
    });

    testWidgets('Aplica opciones personalizadas', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigation(
              currentIndex: 0,
              onTap: (index) {},
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
              ],
              backgroundColor: Colors.green,
              selectedItemColor: Colors.yellow,
              unselectedItemColor: Colors.grey,
              iconSize: 28.0,
              type: BottomNavigationBarType.shifting,
            ),
          ),
        ),
      );

      // Verificar la configuración de la barra
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.backgroundColor, Colors.green);
      expect(bottomNavBar.selectedItemColor, Colors.yellow);
      expect(bottomNavBar.unselectedItemColor, Colors.grey);
      expect(bottomNavBar.iconSize, 28.0);
      expect(bottomNavBar.type, BottomNavigationBarType.shifting);
    });
  });
}
