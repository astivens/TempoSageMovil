import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_animations.dart';

class MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isLoading;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AppAnimations.fast,
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppAnimations.smoothCurve,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Iniciar animación de entrada con retraso
    Future.delayed(Duration(milliseconds: 200 + (widget.title.hashCode % 300)),
        () {
      if (mounted) {
        _pulseController.forward().then((_) {
          if (mounted) _pulseController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _scaleController.reverse();
    }
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _shimmerController.repeat();
    } else {
      _shimmerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.text;
    final subtextColor = textColor.withOpacity(0.7);
    final cardColor = Theme.of(context).cardColor;
    final effectiveColor = widget.color ?? primaryColor;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _pulseController]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: cardColor,
                boxShadow: _isHovered || widget.onTap != null
                    ? [
                        BoxShadow(
                          color: effectiveColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                border: _isHovered
                    ? Border.all(
                        color: effectiveColor.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  if (_isHovered)
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Transform.translate(
                            offset: Offset(_shimmerAnimation.value * 100, 0),
                            child: Container(
                              width: 100,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    effectiveColor.withOpacity(0.1),
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
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: effectiveColor
                                    .withOpacity(_isHovered ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                widget.icon,
                                color: effectiveColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: AppStyles.titleSmall.copyWith(
                                  color: effectiveColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (widget.isLoading)
                          Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: effectiveColor,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: AppStyles.headlineLarge.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _isHovered ? 28 : 26,
                                ),
                                child: Text(
                                  widget.value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  style: AppStyles.bodySmall.copyWith(
                                    color: subtextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
