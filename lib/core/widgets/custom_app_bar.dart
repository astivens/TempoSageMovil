import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../constants/accessibility_styles.dart';

/// AppBar personalizada con soporte mejorado para accesibilidad.
///
/// Este componente proporciona una barra de aplicación personalizada con
/// soporte para título, subtítulo, botón de regreso y acciones adicionales.
/// Está optimizada para accesibilidad siguiendo los estándares de la aplicación.
///
/// Propiedades:
/// - [title]: Título principal a mostrar.
/// - [subtitle]: Subtítulo opcional bajo el título principal.
/// - [showBackButton]: Si se debe mostrar el botón de regreso.
/// - [actions]: Lista de widgets de acción para mostrar en la derecha.
/// - [onBackPressed]: Acción personalizada para el botón de regreso.
/// - [backgroundColor]: Color de fondo de la barra.
/// - [elevation]: Elevación de la barra.
/// - [titleStyle]: Estilo de texto para el título.
/// - [subtitleStyle]: Estilo de texto para el subtítulo.
/// - [centerTitle]: Si el título debe estar centrado.
/// - [leadingWidth]: Ancho del área leading.
/// - [backIcon]: Icono personalizado para el botón de regreso.
/// - [automaticallyImplyLeading]: Si se debe inferir automáticamente el widget leading.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double elevation;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool centerTitle;
  final double? leadingWidth;
  final IconData backIcon;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.elevation = 0,
    this.titleStyle,
    this.subtitleStyle,
    this.centerTitle = false,
    this.leadingWidth,
    this.backIcon = Icons.arrow_back,
    this.automaticallyImplyLeading = true,
  });

  /// Crea una AppBar para pantallas principales sin botón de regreso
  factory CustomAppBar.main({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      showBackButton: false,
      actions: actions,
      backgroundColor: AppColors.base,
      centerTitle: true,
      titleStyle: AccessibilityStyles.accessibleTitleLarge,
    );
  }

  /// Crea una AppBar para pantallas de detalle con botón de regreso
  factory CustomAppBar.detail({
    Key? key,
    required String title,
    String? subtitle,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
      actions: actions,
      backgroundColor: AppColors.base,
      titleStyle: AppStyles.headlineSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.base,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      leadingWidth: leadingWidth,
      leading: showBackButton
          ? IconButton(
              icon: Icon(backIcon),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: _buildTitle(),
      actions: actions,
    );
  }

  /// Construye el widget de título y subtítulo
  Widget _buildTitle() {
    // Si no hay subtítulo, retornar solo el título
    if (subtitle == null) {
      return Text(
        title,
        style: titleStyle ?? AppStyles.headlineSmall,
      );
    }

    // Si hay subtítulo, retornar una columna con ambos
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle ?? AppStyles.headlineSmall,
        ),
        Text(
          subtitle!,
          style: subtitleStyle ??
              AppStyles.bodySmall.copyWith(
                color: AppColors.overlay0,
              ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
