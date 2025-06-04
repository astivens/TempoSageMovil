import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Barra de navegación inferior con mejoras de accesibilidad y personalización.
///
/// Este componente proporciona una barra de navegación inferior con soporte
/// para elementos dinámicos, etiquetas seleccionables y configuración
/// de apariencia basada en las especificaciones de TempoSage.
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

  /// Crea una barra de navegación estándar para TempoSage con las 4 secciones principales
  factory BottomNavigation.tempoSage({
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
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
          tooltip: 'Panel principal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Actividades',
          tooltip: 'Gestionar actividades',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome),
          label: 'Hábitos',
          tooltip: 'Seguimiento de hábitos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule_outlined),
          activeIcon: Icon(Icons.schedule),
          label: 'Bloques',
          tooltip: 'Bloques de tiempo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_outlined),
          activeIcon: Icon(Icons.chat),
          label: 'Chat IA',
          tooltip: 'Asistente de IA',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 2.0, // Reducido según especificaciones
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
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      selectedItemColor: selectedColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar colores dinámicos de catppuccin según el tema
    final defaultSelectedColor =
        AppColors.getCatppuccinColor(context, colorName: 'blue');
    final defaultUnselectedColor =
        AppColors.getCatppuccinColor(context, colorName: 'subtext1');
    final defaultBackgroundColor =
        AppColors.getCatppuccinColor(context, colorName: 'mantle');

    return Container(
      decoration: BoxDecoration(
        // Línea superior sutil para definir la separación
        border: Border(
          top: BorderSide(
            color: AppColors.getCatppuccinColor(context, colorName: 'overlay0'),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        backgroundColor: backgroundColor ?? defaultBackgroundColor,
        selectedItemColor: selectedItemColor ?? defaultSelectedColor,
        unselectedItemColor: unselectedItemColor ?? defaultUnselectedColor,
        showSelectedLabels: showSelectedLabels ?? true,
        showUnselectedLabels: showUnselectedLabels ?? true,
        type: type ?? BottomNavigationBarType.fixed,
        elevation: elevation,
        iconSize: iconSize,
        // Agregamos indicador visual más moderno
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Noto Sans',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Noto Sans',
        ),
      ),
    );
  }
}
