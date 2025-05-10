import 'package:flutter/material.dart';
import '../constants/accessibility_styles.dart';

/// Tarjeta accesible con soporte para interacciones táctiles.
///
/// Este componente proporciona una tarjeta optimizada para accesibilidad
/// con soporte para eventos de toque, bordes redondeados y apariencia
/// consistente en toda la aplicación.
///
/// Propiedades:
/// - [child]: El contenido a mostrar dentro de la tarjeta.
/// - [padding]: El relleno interno de la tarjeta.
/// - [onTap]: Función llamada cuando se toca la tarjeta.
/// - [color]: Color de fondo de la tarjeta.
/// - [elevation]: Elevación de la tarjeta (sombra).
/// - [borderRadius]: Radio del borde redondeado.
/// - [margin]: Margen externo de la tarjeta.
/// - [splashColor]: Color del efecto de salpicadura al tocar.
/// - [highlightColor]: Color de resaltado al mantener presionado.
/// - [shadowColor]: Color de la sombra.
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double elevation;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? shadowColor;

  const AccessibleCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation = 2.0,
    this.borderRadius,
    this.margin,
    this.splashColor,
    this.highlightColor,
    this.shadowColor,
  });

  /// Crea una tarjeta con elevación alta para elementos destacados
  factory AccessibleCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
    Color? color,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
  }) {
    return AccessibleCard(
      key: key,
      child: child,
      padding: padding,
      onTap: onTap,
      color: color,
      elevation: 4.0,
      borderRadius: borderRadius,
      margin: margin,
      shadowColor: Colors.black54,
    );
  }

  /// Crea una tarjeta plana sin elevación para interfaces minimalistas
  factory AccessibleCard.flat({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
    Color? color,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
  }) {
    return AccessibleCard(
      key: key,
      child: child,
      padding: padding,
      onTap: onTap,
      color: color,
      elevation: 0.0,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final defaultPadding =
        const EdgeInsets.all(AccessibilityStyles.spacingMedium);

    return Card(
      color: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      shadowColor: shadowColor,
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );
  }
}
