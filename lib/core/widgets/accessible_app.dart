import 'package:flutter/material.dart';
import '../constants/accessibility_styles.dart';
import '../constants/app_colors.dart';

class AccessibleApp extends StatelessWidget {
  final Widget child;

  const AccessibleApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
        // Estilos de texto
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: AccessibilityStyles.accessibleTitleLarge,
              bodyLarge: AccessibilityStyles.accessibleBodyLarge,
            ),

        // Estilos de AppBar
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.base,
          foregroundColor: AppColors.text,
          titleTextStyle: AccessibilityStyles.accessibleTitleLarge,
        ),

        // Estilos de iconos
        iconTheme: const IconThemeData(
          color: AppColors.text,
          size: 24,
        ),

        // Estilos de tarjetas
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.all(AccessibilityStyles.spacingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Estilos de botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            minimumSize: const Size(88, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Estilos de campos de entrada
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
            color: AppColors.text,
          ),
        ),

        // Estilos de listas
        listTileTheme: ListTileThemeData(
          contentPadding:
              const EdgeInsets.all(AccessibilityStyles.spacingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Estilos de diálogos
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: AccessibilityStyles.accessibleTitleLarge,
          contentTextStyle: AccessibilityStyles.accessibleBodyLarge,
        ),

        // Estilos de snackbars
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentTextStyle: AccessibilityStyles.accessibleBodyLarge,
        ),

        // Estilos de chips
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),

        // Estilos de divisores
        dividerTheme: const DividerThemeData(
          space: 16,
          thickness: 1,
        ),
      ),
      home: child,
    );
  }
}
