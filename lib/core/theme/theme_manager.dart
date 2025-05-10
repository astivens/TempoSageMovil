import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_styles.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

/// Administrador de temas de la aplicación
///
/// Esta clase maneja la lógica del tema de la aplicación,
/// permitiendo cambiar entre modo oscuro y claro y mantiene
/// las configuraciones del usuario.
class ThemeManager with ChangeNotifier {
  bool _isDarkMode;
  bool _isHighContrast;
  double _textScaleFactor;

  ThemeManager({
    bool isDarkMode = false,
    bool isHighContrast = false,
    double textScaleFactor = 1.0,
  })  : _isDarkMode = isDarkMode,
        _isHighContrast = isHighContrast,
        _textScaleFactor = textScaleFactor;

  /// Estado actual del modo oscuro
  bool get isDarkMode => _isDarkMode;

  /// Estado actual del modo de alto contraste
  bool get isHighContrast => _isHighContrast;

  /// Factor de escala de texto actual
  double get textScaleFactor => _textScaleFactor;

  /// Modo de tema actual para MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Tema para el modo claro
  ThemeData get lightTheme => AppStyles.lightTheme;

  /// Tema para el modo oscuro
  ThemeData get darkTheme => AppStyles.darkTheme;

  /// Cambia el modo oscuro
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  /// Cambia el modo de alto contraste
  void toggleHighContrast(bool value) {
    _isHighContrast = value;
    notifyListeners();
  }

  /// Actualiza el factor de escala de texto
  void updateTextScaleFactor(double value) {
    _textScaleFactor = value;
    notifyListeners();
  }

  /// Actualiza todas las configuraciones de tema desde el proveedor de configuración
  void updateFromSettings(SettingsProvider settingsProvider) {
    _isDarkMode = settingsProvider.settings.darkMode;
    _isHighContrast = settingsProvider.settings.highContrastMode;
    _textScaleFactor = settingsProvider.settings.fontSizeScale.toDouble();
    notifyListeners();
  }

  /// Obtiene el ThemeManager desde el contexto
  static ThemeManager of(BuildContext context) {
    return Provider.of<ThemeManager>(context, listen: false);
  }

  /// Comprueba si el tema actual es oscuro basado en el contexto
  static bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Obtiene el esquema de colores adecuado para el estado del tema actual
  Color getThemedColor({
    required Color darkModeColor,
    required Color lightModeColor,
    BuildContext? context,
  }) {
    // Si se proporciona un contexto, usarlo para determinar el modo
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark
          ? darkModeColor
          : lightModeColor;
    }

    // Si no hay contexto, usar el estado interno
    return _isDarkMode ? darkModeColor : lightModeColor;
  }
}
