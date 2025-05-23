import 'package:flutter/material.dart';

extension ColorX on Color {
  /// Reemplaza withOpacity con withValues para evitar pérdida de precisión
  Color withAlphaValue(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}
