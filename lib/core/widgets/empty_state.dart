import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'accessible_button.dart';

/// Widget para mostrar estados vacíos de manera consistente en la aplicación.
///
/// Sigue las especificaciones de diseño de TempoSage con ilustraciones
/// y mensajes motivacionales.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double? iconSize;
  final Widget? customIllustration;
  final EdgeInsets padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize,
    this.customIllustration,
    this.padding = const EdgeInsets.all(32.0),
  });

  /// Factory para estado vacío de actividades
  factory EmptyState.activities({
    Key? key,
    VoidCallback? onCreateActivity,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.assignment_outlined,
      title: 'No hay actividades',
      message:
          'Comienza creando tu primera actividad\npara organizar tu tiempo',
      actionLabel: 'Crear Actividad',
      onAction: onCreateActivity,
    );
  }

  /// Factory para estado vacío de hábitos
  factory EmptyState.habits({
    Key? key,
    VoidCallback? onCreateHabit,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.auto_awesome_outlined,
      title: 'Sin hábitos por seguir',
      message: 'Desarrolla hábitos positivos\nque mejoren tu rutina diaria',
      actionLabel: 'Agregar Hábito',
      onAction: onCreateHabit,
    );
  }

  /// Factory para estado vacío de bloques de tiempo
  factory EmptyState.timeBlocks({
    Key? key,
    VoidCallback? onCreateBlock,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.schedule_outlined,
      title: 'Agenda vacía',
      message: 'Planifica tu día creando\nbloques de tiempo enfocados',
      actionLabel: 'Crear Bloque',
      onAction: onCreateBlock,
    );
  }

  /// Factory para estado vacío de dashboard
  factory EmptyState.dashboard({
    Key? key,
    VoidCallback? onGetStarted,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.dashboard_outlined,
      title: '¡Bienvenido a TempoSage!',
      message:
          'Comienza organizando tu tiempo\ny desarrollando mejores hábitos',
      actionLabel: 'Empezar',
      onAction: onGetStarted,
    );
  }

  /// Factory para estado sin resultados de búsqueda
  factory EmptyState.noResults({
    Key? key,
    String? searchTerm,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.search_off,
      title: 'Sin resultados',
      message: searchTerm != null
          ? 'No encontramos coincidencias\npara "$searchTerm"'
          : 'No hay elementos que mostrar',
    );
  }

  /// Factory para estado sin conexión
  factory EmptyState.noConnection({
    Key? key,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.wifi_off,
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet\ne intenta nuevamente',
      actionLabel: 'Reintentar',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor =
        AppColors.getCatppuccinColor(context, colorName: 'blue');
    final subtextColor =
        AppColors.getCatppuccinColor(context, colorName: 'subtext1');

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ilustración o ícono
          Container(
            width: iconSize ?? 200,
            height: iconSize ?? 200,
            decoration: BoxDecoration(
              color: (iconColor ?? primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: customIllustration ??
                Icon(
                  icon,
                  size: (iconSize ?? 200) * 0.5,
                  color: (iconColor ?? primaryColor).withOpacity(0.4),
                ),
          ),
          const SizedBox(height: 32),

          // Título
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Mensaje
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtextColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Botón de acción (opcional)
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 32),
            AccessibleButton.primary(
              text: actionLabel!,
              onPressed: onAction!,
              icon: _getActionIcon(),
            ),
          ],
        ],
      ),
    );
  }

  IconData? _getActionIcon() {
    if (actionLabel == null) return null;

    switch (actionLabel!.toLowerCase()) {
      case 'crear actividad':
        return Icons.add;
      case 'agregar hábito':
        return Icons.add;
      case 'crear bloque':
        return Icons.add;
      case 'empezar':
        return Icons.play_arrow;
      case 'reintentar':
        return Icons.refresh;
      default:
        return Icons.add;
    }
  }
}

/// Widget para estados de carga con skeleton screens
class LoadingState extends StatelessWidget {
  final String? message;
  final bool showSkeleton;
  final int skeletonItems;

  const LoadingState({
    super.key,
    this.message,
    this.showSkeleton = false,
    this.skeletonItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor =
        AppColors.getCatppuccinColor(context, colorName: 'blue');

    if (showSkeleton) {
      return Column(
        children: List.generate(skeletonItems, (index) => _SkeletonItem()),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.getCatppuccinColor(context,
                    colorName: 'subtext1'),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para estados de error
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title = 'Algo salió mal',
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = AppColors.getCatppuccinColor(context, colorName: 'red');

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: errorColor.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  AppColors.getCatppuccinColor(context, colorName: 'subtext1'),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Item de skeleton para efectos de carga
class _SkeletonItem extends StatefulWidget {
  @override
  State<_SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<_SkeletonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        AppColors.getCatppuccinColor(context, colorName: 'surface0');

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 150,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
