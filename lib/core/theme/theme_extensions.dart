import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Extensiones para trabajar con temas en la aplicación
extension ThemeExtension on BuildContext {
  /// Determina si el tema actual es oscuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Obtiene el color apropiado basado en el tema actual (oscuro o claro)
  Color themedColor(Color darkModeColor, Color lightModeColor) {
    return isDarkMode ? darkModeColor : lightModeColor;
  }

  /// Acceso a otros colores específicos del tema

  /// Color de texto principal según tema
  Color get textColor =>
      isDarkMode ? AppColors.mocha.text : AppColors.latte.text;

  /// Color de subtexto según tema
  Color get subtextColor =>
      isDarkMode ? AppColors.mocha.subtext0 : AppColors.latte.subtext0;

  /// Color de fondo según tema
  Color get backgroundColor =>
      isDarkMode ? AppColors.mocha.base : AppColors.latte.base;

  /// Color de superficie según tema
  Color get surfaceColor =>
      isDarkMode ? AppColors.mocha.surface0 : AppColors.latte.surface0;

  /// Color principal del tema
  Color get primaryColor =>
      isDarkMode ? AppColors.mocha.blue : AppColors.latte.blue;

  /// Color secundario del tema
  Color get secondaryColor =>
      isDarkMode ? AppColors.mocha.mauve : AppColors.latte.mauve;

  /// Color de error del tema
  Color get errorColor =>
      isDarkMode ? AppColors.mocha.red : AppColors.latte.red;
}

/// Extensión para facilitar el acceso a los estilos de texto con el color correcto
extension ThemedTextStyle on TextStyle {
  /// Aplica el color de texto adecuado según el tema
  TextStyle themed(BuildContext context) {
    return copyWith(
      color: context.textColor,
    );
  }

  /// Aplica el color de subtexto adecuado según el tema
  TextStyle themedSubtext(BuildContext context) {
    return copyWith(
      color: context.subtextColor,
    );
  }

  /// Aplica un color específico del tema
  TextStyle withThemedColor(BuildContext context,
      {required Color darkModeColor, required Color lightModeColor}) {
    return copyWith(
      color: context.themedColor(darkModeColor, lightModeColor),
    );
  }
}
