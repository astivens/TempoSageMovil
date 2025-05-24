import 'package:flutter/material.dart';

/// Widget que escala su contenido al pasar el cursor por encima.
///
/// Este componente es útil para crear efectos de hover en interfaces
/// de usuario interactivas, especialmente en dispositivos de escritorio.
///
/// Propiedades:
/// - [child]: El widget hijo que será escalado.
/// - [scale]: El factor de escala al hacer hover (1.0 = sin cambio).
/// - [duration]: La duración de la animación de escala.
/// - [curve]: La curva de animación a usar.
/// - [enabled]: Permite desactivar la funcionalidad de hover.
class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const HoverScale({
    super.key,
    required this.child,
    this.scale = 1.03,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
  });

  @override
  State<HoverScale> createState() => HoverScaleState();
}

/// Estado público para facilitar pruebas
class HoverScaleState extends State<HoverScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(HoverScale oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinicializar animación si cambian propiedades clave
    if (oldWidget.scale != widget.scale ||
        oldWidget.curve != widget.curve ||
        oldWidget.duration != widget.duration) {
      _updateAnimation();
    }

    // Actualizar estado de hover si se desactiva
    if (oldWidget.enabled && !widget.enabled && _isHovered) {
      _isHovered = false;
      _controller.reverse();
    }
  }

  /// Inicializa el controlador de animación y la animación de escala
  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  /// Actualiza la animación sin crear un nuevo controlador
  void _updateAnimation() {
    _controller.duration = widget.duration;

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Maneja el evento de hover
  void handleHover(bool isHovered) {
    if (!widget.enabled || _isHovered == isHovered) return;

    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enabled ? (_) => handleHover(true) : null,
      onExit: widget.enabled ? (_) => handleHover(false) : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
