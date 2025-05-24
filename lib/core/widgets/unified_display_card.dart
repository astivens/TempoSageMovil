import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../constants/app_styles.dart'; // Asumiendo que AppStyles es necesario para los estilos de texto base
// Asegúrate de que las extensiones de tema estén disponibles si las usas directamente aquí
// import '../theme/theme_extensions.dart';

class UnifiedDisplayCard extends StatefulWidget {
  final String title;
  final String? description;
  final String? category;
  final String? timeRange; // Formateado como "HH:mm - HH:mm" o solo "HH:mm"
  final bool isFocusTime;
  final Color itemColor;
  final String? prefix; // Ej: "Hábito: ", "Actividad: "
  final bool isCompleted; // Para mostrar alguna indicación visual

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback?
      onToggleComplete; // Si se necesita una acción de completar separada

  const UnifiedDisplayCard({
    super.key,
    required this.title,
    this.description,
    this.category,
    this.timeRange,
    this.isFocusTime = false,
    required this.itemColor,
    this.prefix,
    this.isCompleted = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
  });

  @override
  State<UnifiedDisplayCard> createState() => _UnifiedDisplayCardState();
}

class _UnifiedDisplayCardState extends State<UnifiedDisplayCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isFocusTime) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _shimmerController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _shimmerController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final bool isDarkMode = theme.brightness == Brightness.dark; // Ya no se necesita si usamos theme.colorScheme

    final String displayTitle = widget.prefix != null
        ? '${widget.prefix}${widget.title}'
        : widget.title;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isFocusTime
              ? _pulseAnimation.value
              : _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverEnter(),
            onExit: (_) => _onHoverExit(),
            child: Slidable(
              key: widget.key ??
                  ValueKey(widget.title + (widget.timeRange ?? '')),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.5,
                children: [
                  if (widget.onEdit != null)
                    SlidableAction(
                      onPressed: (_) => widget.onEdit!(),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      icon: Icons.edit,
                      label: 'Editar',
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)),
                    ),
                  if (widget.onDelete != null)
                    SlidableAction(
                      onPressed: (_) => widget.onDelete!(),
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      icon: Icons.delete,
                      label: 'Eliminar',
                      borderRadius: widget.onEdit == null
                          ? const BorderRadius.horizontal(
                              left: Radius.circular(12))
                          : BorderRadius.zero,
                    ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? widget.itemColor.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.5),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow
                          .withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 12 : 6,
                      offset: Offset(0, _isHovered ? 6 : 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Shimmer effect
                    if (_isHovered)
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(
                                        -1.0 + _shimmerAnimation.value, 0.0),
                                    end: Alignment(
                                        1.0 + _shimmerAnimation.value, 0.0),
                                    colors: [
                                      Colors.transparent,
                                      widget.itemColor.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // Content
                    GestureDetector(
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      onTap: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (widget.onToggleComplete != null) ...[
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: widget.isCompleted,
                                            onChanged: (_) =>
                                                widget.onToggleComplete!(),
                                            activeColor: widget.itemColor,
                                            side: BorderSide(
                                                color:
                                                    theme.colorScheme.outline,
                                                width: 1.5),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ] else ...[
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: widget.itemColor,
                                            shape: BoxShape.circle,
                                            boxShadow: _isHovered
                                                ? [
                                                    BoxShadow(
                                                      color: widget.itemColor
                                                          .withOpacity(0.4),
                                                      blurRadius: 8,
                                                      spreadRadius: 2,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          style: AppStyles.titleSmall.copyWith(
                                            color: _isHovered
                                                ? widget.itemColor
                                                : theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                            decoration: widget.isCompleted &&
                                                    widget.onToggleComplete ==
                                                        null
                                                ? TextDecoration.lineThrough
                                                : null,
                                            decorationColor: theme
                                                .colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                          child: Text(
                                            displayTitle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.timeRange != null &&
                                    widget.timeRange!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _isHovered
                                          ? widget.itemColor.withOpacity(0.1)
                                          : theme.colorScheme.surfaceVariant
                                              .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.timeRange!,
                                      style: TextStyle(
                                        color: _isHovered
                                            ? widget.itemColor
                                            : theme
                                                .colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            if (widget.description != null &&
                                widget.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: (widget.onToggleComplete != null)
                                        ? 32
                                        : 20),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: _isHovered
                                        ? theme.colorScheme.onSurface
                                            .withOpacity(0.8)
                                        : theme.colorScheme.onSurfaceVariant,
                                    decoration: widget.isCompleted &&
                                            widget.onToggleComplete == null
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: theme
                                        .colorScheme.onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                                  child: Text(
                                    widget.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (widget.category != null || widget.isFocusTime)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: (widget.onToggleComplete != null)
                                        ? 32
                                        : 20),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (widget.category != null &&
                                        widget.category!.isNotEmpty)
                                      _buildAnimatedChip(
                                          context,
                                          widget.category!,
                                          theme.colorScheme.secondaryContainer,
                                          theme.colorScheme
                                              .onSecondaryContainer),
                                    if (widget.isFocusTime)
                                      _buildAnimatedChip(
                                        context,
                                        'Tiempo de enfoque',
                                        theme.colorScheme.tertiaryContainer,
                                        theme.colorScheme.onTertiaryContainer,
                                        icon: Icons.timer_outlined,
                                        iconColor: theme
                                            .colorScheme.onTertiaryContainer,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedChip(BuildContext context, String label,
      Color backgroundColor, Color textColor,
      {IconData? icon, Color? iconColor}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isHovered ? backgroundColor.withOpacity(0.8) : backgroundColor,
        borderRadius: BorderRadius.circular(50),
        border: _isHovered
            ? Border.all(
                color: widget.itemColor.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: iconColor ?? textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
