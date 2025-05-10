import 'package:flutter/material.dart';
import '../constants/accessibility_styles.dart';
import '../constants/app_colors.dart';

/// Widget que proporciona estilos de accesibilidad consistentes para toda la aplicación.
///
/// Este componente envuelve la aplicación con estilos optimizados para accesibilidad,
/// aplicando tamaños de texto adecuados, contrastes y espaciados según las mejores
/// prácticas de accesibilidad.
class AccessibleApp extends StatelessWidget {
  /// El widget hijo (normalmente MaterialApp)
  final Widget child;

  /// Tema base para personalización (opcional)
  final ThemeData? baseTheme;

  /// Si se debe usar contraste alto
  final bool highContrast;

  /// Tamaño de texto relativo (1.0 = tamaño normal)
  final double textScale;

  const AccessibleApp({
    super.key,
    required this.child,
    this.baseTheme,
    this.highContrast = false,
    this.textScale = 1.0,
  });

  /// Construye el tema accesible basado en los parámetros
  ThemeData _buildAccessibleTheme(BuildContext context) {
    // Usar el tema base proporcionado o el tema actual del contexto
    final theme = baseTheme ?? Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores adaptados para alto contraste si es necesario
    final textColor = highContrast
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? AppColors.text : AppColors.text);

    final backgroundColor = highContrast
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? AppColors.base : AppColors.base);

    // Ajustar tamaños de texto según el factor de escala
    final textTheme = theme.textTheme.copyWith(
      headlineLarge: (theme.textTheme.headlineLarge ??
              AccessibilityStyles.accessibleTitleLarge)
          .copyWith(
        fontSize: (theme.textTheme.headlineLarge?.fontSize ??
                AccessibilityStyles.accessibleTitleLarge.fontSize)! *
            textScale,
        color: textColor,
      ),
      bodyLarge:
          (theme.textTheme.bodyLarge ?? AccessibilityStyles.accessibleBodyLarge)
              .copyWith(
        fontSize: (theme.textTheme.bodyLarge?.fontSize ??
                AccessibilityStyles.accessibleBodyLarge.fontSize)! *
            textScale,
        color: textColor,
      ),
    );

    return theme.copyWith(
      // Estilos de texto
      textTheme: textTheme,

      // Estilos de AppBar
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        titleTextStyle: textTheme.headlineLarge,
      ),

      // Estilos de iconos
      iconTheme: theme.iconTheme.copyWith(
        color: textColor,
        size: (theme.iconTheme.size ?? 24) * textScale,
      ),

      // Estilos de tarjetas con mejor espacio para accesibilidad
      cardTheme: theme.cardTheme.copyWith(
        margin: EdgeInsets.all(AccessibilityStyles.spacingMedium * textScale),
      ),

      // Estilos de botones con áreas de toque más grandes para accesibilidad
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * textScale,
            vertical: 16 * textScale,
          ),
          minimumSize: Size(88, 48 * textScale),
        ),
      ),

      // Estilos de campos de entrada con mejor visibilidad
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * textScale,
          vertical: 12 * textScale,
        ),
        labelStyle: TextStyle(
          fontSize: 16 * textScale,
          color: textColor,
        ),
      ),

      // Estilos de listas con mejor espaciado
      listTileTheme: theme.listTileTheme.copyWith(
        contentPadding:
            EdgeInsets.all(AccessibilityStyles.spacingMedium * textScale),
      ),

      // Estilos de diálogos para mejor legibilidad
      dialogTheme: theme.dialogTheme.copyWith(
        titleTextStyle: textTheme.headlineLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),

      // Estilos de snackbars con mejor visibilidad
      snackBarTheme: theme.snackBarTheme.copyWith(
        contentTextStyle: textTheme.bodyLarge,
      ),

      // Estilos de chips más grandes para facilitar el toque
      chipTheme: theme.chipTheme.copyWith(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * textScale,
          vertical: 8 * textScale,
        ),
      ),

      // Separadores más visibles
      dividerTheme: theme.dividerTheme.copyWith(
        space: 16 * textScale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si el hijo ya es un MaterialApp, usar un Builder para obtener el contexto
    if (child is MaterialApp) {
      return Builder(
        builder: (context) {
          final MaterialApp materialApp = child as MaterialApp;

          // Determinar si debemos usar el tema claro u oscuro
          ThemeData? effectiveTheme;

          if (materialApp.themeMode == ThemeMode.dark) {
            // Crear un nuevo contexto con tema oscuro
            final darkTheme = materialApp.darkTheme ?? ThemeData.dark();
            effectiveTheme = _buildAccessibleTheme(context);
            effectiveTheme = darkTheme.copyWith(
              textTheme: effectiveTheme.textTheme,
              appBarTheme: effectiveTheme.appBarTheme,
              iconTheme: effectiveTheme.iconTheme,
              cardTheme: effectiveTheme.cardTheme,
              elevatedButtonTheme: effectiveTheme.elevatedButtonTheme,
              inputDecorationTheme: effectiveTheme.inputDecorationTheme,
              listTileTheme: effectiveTheme.listTileTheme,
              dialogTheme: effectiveTheme.dialogTheme,
              snackBarTheme: effectiveTheme.snackBarTheme,
              chipTheme: effectiveTheme.chipTheme,
              dividerTheme: effectiveTheme.dividerTheme,
            );
          } else if (materialApp.themeMode == ThemeMode.light) {
            // Crear un nuevo contexto con tema claro
            final lightTheme = materialApp.theme ?? ThemeData.light();
            effectiveTheme = _buildAccessibleTheme(context);
            effectiveTheme = lightTheme.copyWith(
              textTheme: effectiveTheme.textTheme,
              appBarTheme: effectiveTheme.appBarTheme,
              iconTheme: effectiveTheme.iconTheme,
              cardTheme: effectiveTheme.cardTheme,
              elevatedButtonTheme: effectiveTheme.elevatedButtonTheme,
              inputDecorationTheme: effectiveTheme.inputDecorationTheme,
              listTileTheme: effectiveTheme.listTileTheme,
              dialogTheme: effectiveTheme.dialogTheme,
              snackBarTheme: effectiveTheme.snackBarTheme,
              chipTheme: effectiveTheme.chipTheme,
              dividerTheme: effectiveTheme.dividerTheme,
            );
          }

          final childBuilder = materialApp.builder;

          return MaterialApp(
            key: materialApp.key,
            navigatorKey: materialApp.navigatorKey,
            scaffoldMessengerKey: materialApp.scaffoldMessengerKey,
            home: materialApp.home,
            initialRoute: materialApp.initialRoute,
            onGenerateRoute: materialApp.onGenerateRoute,
            onUnknownRoute: materialApp.onUnknownRoute,
            routes: materialApp.routes ?? const <String, WidgetBuilder>{},
            navigatorObservers:
                materialApp.navigatorObservers ?? const <NavigatorObserver>[],
            builder: (context, child) {
              final wrappedChild =
                  childBuilder != null ? childBuilder(context, child) : child;

              return Theme(
                data: effectiveTheme ?? _buildAccessibleTheme(context),
                child: wrappedChild!,
              );
            },
            title: materialApp.title,
            onGenerateTitle: materialApp.onGenerateTitle,
            color: materialApp.color,
            locale: materialApp.locale,
            localizationsDelegates: materialApp.localizationsDelegates,
            supportedLocales: materialApp.supportedLocales,
            showPerformanceOverlay: materialApp.showPerformanceOverlay,
            checkerboardRasterCacheImages:
                materialApp.checkerboardRasterCacheImages,
            checkerboardOffscreenLayers:
                materialApp.checkerboardOffscreenLayers,
            showSemanticsDebugger: materialApp.showSemanticsDebugger,
            debugShowCheckedModeBanner: materialApp.debugShowCheckedModeBanner,
            theme: materialApp.theme,
            darkTheme: materialApp.darkTheme,
            themeMode: materialApp.themeMode,
          );
        },
      );
    }

    // De lo contrario, envolver en un MaterialApp propio
    return MaterialApp(
      theme: _buildAccessibleTheme(context),
      home: child,
    );
  }
}
