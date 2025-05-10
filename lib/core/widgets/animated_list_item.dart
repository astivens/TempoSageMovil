import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

/// Componente que muestra un elemento de lista con una animación de entrada.
///
/// Este widget es útil para crear listas escalonadas donde cada elemento
/// aparece con una animación cuando la lista se carga inicialmente.
///
/// Propiedades:
/// - [child]: El widget hijo que será animado.
/// - [index]: El índice del elemento en la lista (determina el retraso).
/// - [delay]: El retraso base entre animaciones de elementos consecutivos.
/// - [animateOnInit]: Si es `true`, anima automáticamente al inicializarse.
/// - [animation]: Permite proveer una animación externa en lugar de crear una interna.
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final bool animateOnInit;
  final Animation<double>? animation;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
    this.animateOnInit = true,
    this.animation,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Solo crear un controlador si no se proporciona una animación externa
    if (widget.animation == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: AppAnimations.smoothCurve,
        ),
      );

      if (widget.animateOnInit) {
        Future.delayed(widget.delay * widget.index, () {
          if (mounted) {
            _controller!.forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Inicia manualmente la animación de entrada.
  /// Útil cuando [animateOnInit] es `false`.
  void animate() {
    _controller?.forward();
  }

  /// Revierte la animación (útil para animaciones de salida).
  void reverseAnimation() {
    _controller?.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Usar la animación proporcionada o la creada internamente
    final animation = widget.animation ?? _animation!;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
