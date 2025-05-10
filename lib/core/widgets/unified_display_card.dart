import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../constants/app_styles.dart'; // Asumiendo que AppStyles es necesario para los estilos de texto base
// Asegúrate de que las extensiones de tema estén disponibles si las usas directamente aquí
// import '../theme/theme_extensions.dart';

class UnifiedDisplayCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final bool isDarkMode = theme.brightness == Brightness.dark; // Ya no se necesita si usamos theme.colorScheme

    final String displayTitle = prefix != null ? '\$prefix\$title' : title;

    return Slidable(
      key: key ?? ValueKey(title + (timeRange ?? '')), // Usar una clave única
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5, // Ajusta cuánto se desliza para mostrar las acciones
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              icon: Icons.edit,
              label: 'Editar',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              icon: Icons.delete,
              label: 'Eliminar',
              borderRadius: onEdit == null
                  ? const BorderRadius.horizontal(left: Radius.circular(12))
                  : BorderRadius.zero,
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Checkbox o indicador de completado (opcional)
                          if (onToggleComplete != null) ...[
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isCompleted,
                                onChanged: (_) => onToggleComplete!(),
                                activeColor: itemColor,
                                side: BorderSide(
                                    color: theme.colorScheme.outline,
                                    width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: itemColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              displayTitle,
                              style: AppStyles.titleSmall.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                decoration:
                                    isCompleted && onToggleComplete == null
                                        ? TextDecoration.lineThrough
                                        : null,
                                decorationColor: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (timeRange != null && timeRange!.isNotEmpty) ...[
                      const SizedBox(width: 8), // Espacio antes de la hora
                      Text(
                        timeRange!,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12, // Un poco más pequeño para la hora
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ]
                  ],
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(
                        left: (onToggleComplete != null)
                            ? 32
                            : 20), // Alinear con el título
                    child: Text(
                      description!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: isCompleted && onToggleComplete == null
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (category != null || isFocusTime)
                  Padding(
                    padding: EdgeInsets.only(
                        left: (onToggleComplete != null)
                            ? 32
                            : 20), // Alinear con el título
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (category != null && category!.isNotEmpty)
                          _buildChip(
                              context,
                              category!,
                              theme.colorScheme.secondaryContainer,
                              theme.colorScheme.onSecondaryContainer),
                        if (isFocusTime)
                          _buildChip(
                            context,
                            'Tiempo de enfoque',
                            theme.colorScheme.tertiaryContainer,
                            theme.colorScheme.onTertiaryContainer,
                            icon:
                                Icons.timer_outlined, // Usar un icono outlined
                            iconColor: theme.colorScheme.onTertiaryContainer,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color backgroundColor,
      Color textColor,
      {IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
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
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12, // Tamaño consistente para chips
            ),
          ),
        ],
      ),
    );
  }
}
