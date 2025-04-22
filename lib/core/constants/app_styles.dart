import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'accessibility_styles.dart';

class AppStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.text,
    fontFamily: 'Noto Sans',
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Noto Sans',
        colorScheme: const ColorScheme.light(
          primary: AppColors.blue,
          secondary: AppColors.mauve,
          surface: AppColors.base,
          error: AppColors.red,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.text,
          size: 24,
        ),
        textTheme: const TextTheme(
          headlineLarge: AccessibilityStyles.accessibleTitleLarge,
          headlineMedium: headlineMedium,
          headlineSmall: headlineSmall,
          bodyLarge: AccessibilityStyles.accessibleBodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AccessibilityStyles.accessibleButtonStyle,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Noto Sans',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.blue,
          secondary: AppColors.mauve,
          surface: AppColors.base,
          error: AppColors.red,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.text,
          size: 24,
        ),
        textTheme: const TextTheme(
          headlineLarge: AccessibilityStyles.accessibleTitleLarge,
          headlineMedium: headlineMedium,
          headlineSmall: headlineSmall,
          bodyLarge: AccessibilityStyles.accessibleBodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AccessibilityStyles.accessibleButtonStyle,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
}
