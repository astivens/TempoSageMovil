import 'package:flutter/material.dart';
import '../constants/accessibility_styles.dart';
import '../constants/app_colors.dart';

/// Scaffold adaptado con mejoras de accesibilidad para la aplicación.
///
/// Este widget proporciona una estructura de página accesible con:
/// - Tamaños y espaciados adaptados para mejor legibilidad
/// - Configuraciones para necesidades de accesibilidad
/// - Estilos consistentes en toda la aplicación
class AccessibleScaffold extends StatelessWidget {
  /// Contenido principal del scaffold
  final Widget body;

  /// Título a mostrar en la AppBar
  final String? title;

  /// Acciones adicionales para la AppBar
  final List<Widget>? actions;

  /// Botón de acción flotante
  final Widget? floatingActionButton;

  /// Posición del botón de acción flotante
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Determina si se muestra la AppBar
  final bool showAppBar;

  /// Color de fondo del scaffold
  final Color? backgroundColor;

  /// Drawer (panel lateral) del scaffold
  final Widget? drawer;

  /// Padding personalizado para el cuerpo
  final EdgeInsetsGeometry? padding;

  /// Widget para mostrar en la parte inferior
  final Widget? bottomNavigationBar;

  /// Si debe mostrar botón de regreso en AppBar
  final bool showBackButton;

  /// Acción personalizada para el botón de regreso
  final VoidCallback? onBackPressed;

  /// Si el cuerpo debe ser scrollable
  final bool scrollable;

  const AccessibleScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showAppBar = true,
    this.backgroundColor,
    this.drawer,
    this.padding,
    this.bottomNavigationBar,
    this.showBackButton = false,
    this.onBackPressed,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = _buildBody(context);

    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: bodyWidget,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  /// Construye la AppBar con configuraciones de accesibilidad
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: AccessibilityStyles.accessibleTitleLarge,
            )
          : null,
      actions: actions,
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.base,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  /// Construye el cuerpo del scaffold, opcionalmente con scroll
  Widget _buildBody(BuildContext context) {
    Widget contentWidget = Padding(
      padding:
          padding ?? const EdgeInsets.all(AccessibilityStyles.spacingMedium),
      child: body,
    );

    // Envolver en SingleChildScrollView si es necesario
    if (scrollable) {
      contentWidget = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: contentWidget,
      );
    }

    return SafeArea(child: contentWidget);
  }
}
