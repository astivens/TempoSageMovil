import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

/// Clase que define todos los colores utilizados en la aplicación.
/// Utiliza la paleta de colores Catppuccin para mantener consistencia visual.
class AppColors {
  // Acceso a los sabores de Catppuccin
  static final latte = catppuccin.latte;
  static final frappe = catppuccin.frappe;
  static final macchiato = catppuccin.macchiato;
  static final mocha = catppuccin.mocha;

  // Helpers para obtener colores según el tema actual
  static Color getBlue(bool isDarkMode) => isDarkMode ? mocha.blue : latte.blue;

  static Color getMauve(bool isDarkMode) =>
      isDarkMode ? mocha.mauve : latte.mauve;

  static Color getGreen(bool isDarkMode) =>
      isDarkMode ? mocha.green : latte.green;

  static Color getRed(bool isDarkMode) => isDarkMode ? mocha.red : latte.red;

  static Color getText(bool isDarkMode) => isDarkMode ? mocha.text : latte.text;

  static Color getBackground(bool isDarkMode) =>
      isDarkMode ? mocha.base : latte.base;

  static Color getSurface(bool isDarkMode) =>
      isDarkMode ? mocha.mantle : latte.mantle;

  // Colores del tema claro (Latte)
  static const Color latteBg = Color(0xFFEFF1F5);
  static const Color latteBase = Color(0xFFE6E9EF);
  static const Color latteMantle = Color(0xFFE6E9EF);
  static const Color latteCrust = Color(0xFFDCE0E8);
  static const Color latteText = Color(0xFF4C4F69);
  static const Color latteSubtext0 = Color(0xFF6C6F85);
  static const Color latteSubtext1 = Color(0xFF5C5F77);
  static const Color latteOverlay0 = Color(0xFF7C7F93);
  static const Color latteOverlay1 = Color(0xFF8C8FA1);
  static const Color latteOverlay2 = Color(0xFF9CA0B0);
  static const Color latteBlue = Color(0xFF1E66F5);
  static const Color latteLavender = Color(0xFF7287FD);
  static const Color latteTeal = Color(0xFF179299);
  static const Color latteGreen = Color(0xFF40A02B);
  static const Color latteYellow = Color(0xFFDF8E1D);
  static const Color latteRed = Color(0xFFD20F39);
  static const Color lattePeach = Color(0xFFFE640B);
  static const Color latteMauve = Color(0xFF8839EF);

  // Colores del tema oscuro (Mocha)
  static const Color rosewater = Color(0xFFF5E0DC);
  static const Color flamingo = Color(0xFFF2CDCD);
  static const Color pink = Color(0xFFF5C2E7);
  static const Color maroon = Color(0xFFEBA0AC);
  static const Color peach = Color(0xFFFAB387);
  static const Color yellow = Color(0xFFF9E2AF);
  static const Color green = Color(0xFFA6E3A1);
  static const Color teal = Color(0xFF94E2D5);
  static const Color sky = Color(0xFF89DCEB);
  static const Color sapphire = Color(0xFF74C7EC);
  static const Color lavender = Color(0xFFB4BEFE);
  static const Color text = Color(0xFFCDD6F4);
  static const Color subtext1 = Color(0xFFBAC2DE);
  static const Color overlay2 = Color(0xFF9399B2);
  static const Color overlay1 = Color(0xFF7F849C);
  static const Color overlay0 = Color(0xFF6C7086);
  static const Color surface0 = Color(0xFF313244);
  static const Color surface1 = Color(0xFF45475A);
  static const Color surface2 = Color(0xFF585B70);
  static const Color base = Color(0xFF1E1E2E);
  static const Color mantle = Color(0xFF181825);
  static const Color crust = Color(0xFF11111B);

  // Colores adicionales para la aplicación
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFCF6679);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textDisabled = Color(0x80FFFFFF);

  // Categorías y estados
  static const Color work = Color(0xFFFF5252);
  static const Color study = Color(0xFF448AFF);
  static const Color exercise = Color(0xFF66BB6A);
  static const Color leisure = Color(0xFFFFEB3B);
  static const Color other = Color(0xFF9C27B0);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color divider = Color(0x1FFFFFFF);
  static const Color border = Color(0x1FFFFFFF);
  static const Color transparent = Color(0x00000000);

  /// Método de ayuda para obtener los colores según el modo de tema
  static Color getColor(
    BuildContext context, {
    required Color darkModeColor,
    required Color lightModeColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? darkModeColor : lightModeColor;
  }

  /// Método para obtener un color de la paleta Catppuccin según el tema actual
  static Color getCatppuccinColor(
    BuildContext context, {
    required String colorName,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final flavor = isDarkMode ? mocha : latte;

    // Acceder dinámicamente a los colores de Catppuccin
    switch (colorName) {
      case 'rosewater':
        return flavor.rosewater;
      case 'flamingo':
        return flavor.flamingo;
      case 'pink':
        return flavor.pink;
      case 'mauve':
        return flavor.mauve;
      case 'red':
        return flavor.red;
      case 'maroon':
        return flavor.maroon;
      case 'peach':
        return flavor.peach;
      case 'yellow':
        return flavor.yellow;
      case 'green':
        return flavor.green;
      case 'teal':
        return flavor.teal;
      case 'sky':
        return flavor.sky;
      case 'sapphire':
        return flavor.sapphire;
      case 'blue':
        return flavor.blue;
      case 'lavender':
        return flavor.lavender;
      case 'text':
        return flavor.text;
      case 'subtext1':
        return flavor.subtext1;
      case 'subtext0':
        return flavor.subtext0;
      case 'overlay2':
        return flavor.overlay2;
      case 'overlay1':
        return flavor.overlay1;
      case 'overlay0':
        return flavor.overlay0;
      case 'surface2':
        return flavor.surface2;
      case 'surface1':
        return flavor.surface1;
      case 'surface0':
        return flavor.surface0;
      case 'base':
        return flavor.base;
      case 'mantle':
        return flavor.mantle;
      case 'crust':
        return flavor.crust;
      default:
        return flavor.base;
    }
  }
}
