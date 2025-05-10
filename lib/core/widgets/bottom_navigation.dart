import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Barra de navegación inferior con mejoras de accesibilidad y personalización.
///
/// Este componente proporciona una barra de navegación inferior con soporte
/// para elementos dinámicos, etiquetas seleccionables y configuración
/// de apariencia.
///
/// Propiedades:
/// - [currentIndex]: Índice del elemento actualmente seleccionado.
/// - [onTap]: Callback invocado cuando se selecciona un elemento.
/// - [items]: Lista de elementos de navegación a mostrar.
/// - [backgroundColor]: Color de fondo de la barra.
/// - [selectedItemColor]: Color de los elementos seleccionados.
/// - [unselectedItemColor]: Color de los elementos no seleccionados.
/// - [showSelectedLabels]: Si se deben mostrar etiquetas para elementos seleccionados.
/// - [showUnselectedLabels]: Si se deben mostrar etiquetas para elementos no seleccionados.
/// - [type]: Tipo de animación para la barra (fixed o shifting).
/// - [elevation]: Elevación de la barra.
/// - [iconSize]: Tamaño de los iconos.
class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool? showSelectedLabels;
  final bool? showUnselectedLabels;
  final BottomNavigationBarType? type;
  final double elevation;
  final double iconSize;

  /// Crea una barra de navegación con opciones personalizadas
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showSelectedLabels,
    this.showUnselectedLabels,
    this.type,
    this.elevation = 8.0,
    this.iconSize = 24.0,
  });

  /// Crea una barra de navegación predeterminada para la aplicación TempoSage
  factory BottomNavigation.standard({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BottomNavigation(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Time Blocks',
          tooltip: 'Ver bloques de tiempo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Actividades',
          tooltip: 'Ver actividades',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: 'Hábitos',
          tooltip: 'Ver hábitos',
        ),
      ],
      backgroundColor: AppColors.base,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.overlay0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  /// Crea una barra de navegación minimalista con solo iconos
  factory BottomNavigation.minimal({
    Key? key,
    required int currentIndex,
    required Function(int) onTap,
    required List<BottomNavigationBarItem> items,
    Color? selectedColor,
  }) {
    return BottomNavigation(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: AppColors.base,
      selectedItemColor: selectedColor ?? AppColors.primary,
      unselectedItemColor: AppColors.overlay0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      showSelectedLabels: showSelectedLabels,
      showUnselectedLabels: showUnselectedLabels,
      type: type,
      elevation: elevation,
      iconSize: iconSize,
    );
  }
}
