import 'package:flutter/material.dart';
import '../constants/accessibility_styles.dart';
import '../constants/app_colors.dart';

/// Botón accesible y adaptable con soporte para diferentes estilos y estados
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isFullWidth;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AccessibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isFullWidth = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.padding,
  });

  /// Crea un botón primario con estilo predefinido
  factory AccessibleButton.primary({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    bool isFullWidth = false,
    double? width,
    double? height,
  }) {
    return AccessibleButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppColors.blue,
      textColor: AppColors.text,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
      height: height,
      borderRadius: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: AppColors.surface0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: textColor ?? AppColors.text,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: AccessibilityStyles.spacingSmall),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
