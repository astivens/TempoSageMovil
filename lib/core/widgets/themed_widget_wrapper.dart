import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

/// Un widget wrapper que proporciona fácil acceso a los colores temáticos
///
/// Permite crear widgets que se adaptan automáticamente al tema
/// actual de la aplicación sin necesidad de verificaciones repetitivas.
class ThemedWidgetWrapper extends StatelessWidget {
  /// El constructor del widget
  final Widget Function(BuildContext context, bool isDarkMode) builder;

  const ThemedWidgetWrapper({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return builder(context, isDarkMode);
  }
}

/// Widget de ejemplo que demuestra cómo usar el ThemedWidgetWrapper
class ThemedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const ThemedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedWidgetWrapper(
      builder: (context, isDarkMode) {
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              color: context.themedColor(
                Color.fromARGB(
                    50, 255, 255, 255), // Sutil borde claro en modo oscuro
                Color.fromARGB(30, 0, 0, 0), // Sutil borde oscuro en modo claro
              ),
              width: 1,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
