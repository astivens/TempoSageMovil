import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_animations.dart';

/// Botón de acción flotante expandible que muestra múltiples acciones.
///
/// Este componente muestra un FAB principal que, al pulsarse, se expande
/// para mostrar un conjunto de botones de acción secundarios distribuidos
/// en un arco. Es útil para presentar múltiples acciones relacionadas sin
/// ocupar espacio permanente en la pantalla.
///
/// Propiedades:
/// - [initialOpen]: Si el FAB debe comenzar expandido.
/// - [children]: Lista de widgets (botones) a mostrar cuando se expande.
/// - [distance]: Distancia máxima a la que se expanden los botones secundarios.
/// - [icon]: Icono a mostrar en el botón principal.
/// - [closeIcon]: Icono a mostrar para cerrar (por defecto es un icono de cierre).
/// - [fabColor]: Color del botón principal.
/// - [fabSize]: Tamaño del botón principal.
/// - [openFabTooltip]: Tooltip para el botón cuando está cerrado.
/// - [closeFabTooltip]: Tooltip para el botón cuando está abierto.
/// - [angle]: Ángulo total en grados para la distribución de los botones (por defecto 90°).
/// - [duration]: Duración de la animación de expansión.
/// - [onOpen]: Callback invocado cuando el FAB se expande.
/// - [onClose]: Callback invocado cuando el FAB se contrae.
@immutable
class ExpandableFab extends StatefulWidget {
  final bool initialOpen;
  final List<Widget> children;
  final double distance;
  final Widget icon;
  final Widget? closeIcon;
  final Color? fabColor;
  final double fabSize;
  final String? openFabTooltip;
  final String? closeFabTooltip;
  final double angle;
  final Duration duration;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const ExpandableFab({
    super.key,
    this.initialOpen = false,
    required this.children,
    required this.icon,
    this.distance = 100,
    this.closeIcon,
    this.fabColor,
    this.fabSize = 56.0,
    this.openFabTooltip,
    this.closeFabTooltip,
    this.angle = 90.0,
    this.duration = AppAnimations.normal,
    this.onOpen,
    this.onClose,
  })  : assert(children.length >= 1, 'Al menos un hijo debe ser proporcionado'),
        assert(angle > 0 && angle <= 360,
            'El ángulo debe estar entre 0 y 360 grados');

  @override
  State<ExpandableFab> createState() => ExpandableFabState();
}

/// Estado del ExpandableFab, expuesto para pruebas y posible control externo
class ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  /// Estado actual del FAB (abierto o cerrado)
  bool get isOpen => _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: widget.duration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: AppAnimations.smoothCurve,
      reverseCurve: AppAnimations.smoothCurve.flipped,
      parent: _controller,
    );
  }

  @override
  void didUpdateWidget(ExpandableFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar la duración de la animación si ha cambiado
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Abre o cierra manualmente el FAB
  void toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
        widget.onOpen?.call();
      } else {
        _controller.reverse();
        widget.onClose?.call();
      }
    });
  }

  /// Abre el FAB si está cerrado
  void open() {
    if (!_open) {
      toggle();
    }
  }

  /// Cierra el FAB si está abierto
  void close() {
    if (_open) {
      toggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Área transparente para cerrar al tocar fuera
          if (_open)
            Positioned.fill(
              child: GestureDetector(
                onTap: close,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: widget.fabSize,
      height: widget.fabSize,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          color: widget.fabColor ?? Theme.of(context).colorScheme.secondary,
          child: InkWell(
            onTap: toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.closeIcon ??
                  Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;

    // Si solo hay un elemento, colocarlo en el centro
    final angleStep = count > 1
        ? widget.angle / (count - 1)
        : 0.0; // Para un solo elemento, no hay ángulo

    for (var i = 0; i < count; i++) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleStep * i,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
      child: FloatingActionButton(
        tooltip: _open ? widget.closeFabTooltip : widget.openFabTooltip,
        backgroundColor: widget.fabColor,
        onPressed: toggle,
        child: widget.icon,
      ),
    );
  }
}

/// Widget para cada botón de acción expandible
@immutable
class _ExpandingActionButton extends StatelessWidget {
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );

        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: Transform.scale(
              scale: progress.value,
              child: child,
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

/// Botón de acción para usar con ExpandableFab
///
/// Proporciona un botón de acción flotante estilizado para ser usado
/// como uno de los elementos secundarios en un [ExpandableFab].
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final double size;
  final EdgeInsets padding;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.size = 40.0,
    this.padding = const EdgeInsets.all(4.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor ?? theme.colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: icon,
        color: foregroundColor ?? theme.colorScheme.onSecondary,
        padding: padding,
        constraints: BoxConstraints.tightFor(
          width: size,
          height: size,
        ),
      ),
    );
  }
}
