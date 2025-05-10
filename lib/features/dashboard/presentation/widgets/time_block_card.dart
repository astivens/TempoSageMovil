import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_animations.dart';

class TimeBlockCard extends StatefulWidget {
  final String title;
  final String timeRange;
  final String? description;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isCompleted;
  final bool isLoading;

  const TimeBlockCard({
    super.key,
    required this.title,
    required this.timeRange,
    this.description,
    required this.icon,
    this.color,
    this.onTap,
    this.isCompleted = false,
    this.isLoading = false,
  });

  @override
  State<TimeBlockCard> createState() => _TimeBlockCardState();
}

class _TimeBlockCardState extends State<TimeBlockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.smoothCurve,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.smoothCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.color ?? AppColors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppStyles.titleSmall.copyWith(
                                  color: widget.color ?? AppColors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.timeRange,
                                style: AppStyles.bodyMedium.copyWith(
                                  color: AppColors.subtext1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 24,
                          ),
                      ],
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.description!,
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.subtext1,
                        ),
                      ),
                    ],
                    if (widget.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
