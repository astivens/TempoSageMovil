import 'package:flutter/material.dart';
import 'app_colors.dart';

class AccessibilityStyles {
  // Estilos de texto mejorados para legibilidad
  static const TextStyle accessibleTitleLarge = TextStyle(
    fontSize: 26, // Tamaño aumentado
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    letterSpacing: 0.5, // Espaciado mejorado
    height: 1.3, // Altura de línea aumentada
  );

  static const TextStyle accessibleBodyLarge = TextStyle(
    fontSize: 18, // Tamaño aumentado
    color: AppColors.text,
    letterSpacing: 0.3,
    height: 1.5, // Altura de línea aumentada
  );

  // Estilos para botones y elementos interactivos
  static final ButtonStyle accessibleButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    minimumSize: const Size(88, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Estilos para tarjetas y contenedores
  static final BoxDecoration accessibleCardDecoration = BoxDecoration(
    color: AppColors.surface0,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border, width: 1),
  );

  // Espaciado consistente
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Sombras para mejorar la percepción de profundidad
  static final List<BoxShadow> accessibleShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Animaciones suaves
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
}
