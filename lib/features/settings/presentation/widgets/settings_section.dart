import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';

/// Widget que representa una sección de configuraciones
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
            child: Text(
              title,
              style: AccessibilityStyles.accessibleTitleLarge,
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

/// Widget que representa un elemento de configuración con múltiples opciones de interacción
class SettingsItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Function()? onTap;
  final Function(bool)? onChanged;
  final bool? value;

  const SettingsItem({
    Key? key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onChanged,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si es un switch
    if (onChanged != null && value != null) {
      return ListTile(
        leading:
            icon != null ? Icon(icon, color: theme.colorScheme.primary) : null,
        title: Text(
          title,
          style: AccessibilityStyles.accessibleBodyLarge,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subtext1,
                  height: 1.4,
                ),
              )
            : null,
        trailing: Switch(
          value: value!,
          onChanged: onChanged!,
        ),
      );
    }

    // Si es un elemento con tap
    return ListTile(
      leading:
          icon != null ? Icon(icon, color: theme.colorScheme.primary) : null,
      title: Text(
        title,
        style: AccessibilityStyles.accessibleBodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.subtext1,
                height: 1.4,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
