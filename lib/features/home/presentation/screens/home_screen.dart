import 'package:flutter/material.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../activities/presentation/screens/activity_list_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../timeblocks/presentation/screens/time_blocks_screen.dart';
import '../../../habits/presentation/screens/habits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ActivityListScreen(),
    CalendarScreen(),
    TimeBlocksScreen(),
    HabitsScreen(),
  ];

  // Número de pantallas disponibles (sin contar ajustes que es una navegación)
  final int _numScreens = 5;

  void _onItemTapped(int index) {
    if (index == _numScreens) {
      // Si el índice es igual al número de pantallas, navegar a configuración
      Navigator.pushNamed(context, '/settings');
    } else if (index >= 0 && index < _numScreens) {
      // Solo actualizar el índice si está dentro del rango válido
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _openRecommendationTest() {
    Navigator.pushNamed(context, '/test-recommendation');
  }

  @override
  Widget build(BuildContext context) {
    // Obtener colores del tema actual
    final theme = Theme.of(context);

    return Scaffold(
      body: _selectedIndex < _screens.length
          ? _screens[_selectedIndex]
          : _screens[0], // Fallback a la primera pantalla por seguridad
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _openRecommendationTest,
              tooltip: 'Probar Recomendaciones',
              child: const Icon(Icons.movie),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex >= _numScreens ? 0 : _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Time Blocks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        // Usar colores del tema en lugar de colores fijos
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}
