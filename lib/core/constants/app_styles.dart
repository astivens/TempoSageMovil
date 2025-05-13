import 'package:flutter/material.dart';
import 'app_colors.dart';

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

  /// Tema claro basado en Catppuccin Latte
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Noto Sans',
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.latte.blue,
          secondary: AppColors.latte.mauve,
          tertiary: AppColors.latte.peach,
          background: AppColors.latte.base,
          surface: AppColors.latte.mantle,
          error: AppColors.latte.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: AppColors.latte.text,
          onSurface: AppColors.latte.text,
          onError: Colors.white,
          surfaceVariant: AppColors.latte.crust,
          onSurfaceVariant: AppColors.latte.subtext0,
          outlineVariant: AppColors.latte.overlay0,
        ),
        scaffoldBackgroundColor: AppColors.latte.base,
        cardColor: AppColors.latte.mantle,
        canvasColor: AppColors.latte.base,
        dialogBackgroundColor: AppColors.latte.mantle,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.latte.mantle,
          foregroundColor: AppColors.latte.text,
          elevation: 0,
        ),
        iconTheme: IconThemeData(
          color: AppColors.latte.text,
          size: 24,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.latte.text,
            letterSpacing: 0.5,
            height: 1.3,
            fontFamily: 'Noto Sans',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: AppColors.latte.text,
            letterSpacing: 0.3,
            height: 1.5,
            fontFamily: 'Noto Sans',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.latte.text,
            fontFamily: 'Noto Sans',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.latte.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(88, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.latte.blue,
            side: BorderSide(color: AppColors.latte.blue, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(88, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.latte.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.latte.mantle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2,
          shadowColor: AppColors.latte.overlay0.withOpacity(0.6),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.latte.mantle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.latte.subtext0, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.latte.subtext0, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.latte.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: TextStyle(
              color: AppColors.latte.subtext1, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: AppColors.latte.subtext0),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.latte.mantle,
          selectedItemColor: AppColors.latte.blue,
          unselectedItemColor: AppColors.latte.subtext1,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showUnselectedLabels: true,
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.latte.crust,
          thickness: 1,
          space: 1,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.latte.blue;
            }
            return AppColors.latte.mantle;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(color: AppColors.latte.subtext0, width: 1.5),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.latte.blue;
            }
            return AppColors.latte.mantle;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.latte.blue.withOpacity(0.4);
            }
            return AppColors.latte.subtext0.withOpacity(0.4);
          }),
          trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.transparent;
            }
            return AppColors.latte.subtext0;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.latte.blue;
            }
            return AppColors.latte.subtext0;
          }),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: AppColors.latte.blue,
          textColor: AppColors.latte.text,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: AppColors.latte.mantle,
          selectedTileColor: AppColors.latte.crust,
        ),
      );

  /// Tema oscuro basado en Catppuccin Mocha
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Noto Sans',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.mocha.blue,
          secondary: AppColors.mocha.mauve,
          tertiary: AppColors.mocha.peach,
          background: AppColors.mocha.base,
          surface: AppColors.mocha.mantle,
          error: AppColors.mocha.red,
          onPrimary: AppColors.mocha.base,
          onSecondary: AppColors.mocha.base,
          onBackground: AppColors.mocha.text,
          onSurface: AppColors.mocha.text,
          onError: AppColors.mocha.base,
          surfaceVariant: AppColors.mocha.crust,
          onSurfaceVariant: AppColors.mocha.subtext0,
          outline: AppColors.mocha.overlay1,
          outlineVariant: AppColors.mocha.overlay0,
        ),
        scaffoldBackgroundColor: AppColors.mocha.base,
        cardColor: AppColors.mocha.mantle,
        canvasColor: AppColors.mocha.base,
        dialogBackgroundColor: AppColors.mocha.mantle,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.mocha.mantle,
          foregroundColor: AppColors.mocha.text,
          elevation: 0,
        ),
        iconTheme: IconThemeData(
          color: AppColors.mocha.text,
          size: 24,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.mocha.text,
            letterSpacing: 0.5,
            height: 1.3,
            fontFamily: 'Noto Sans',
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: AppColors.mocha.text,
            letterSpacing: 0.3,
            height: 1.5,
            fontFamily: 'Noto Sans',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.mocha.text,
            fontFamily: 'Noto Sans',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mocha.blue,
            foregroundColor: AppColors.mocha.base,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(88, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.mocha.blue,
            side: BorderSide(color: AppColors.mocha.blue, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(88, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mocha.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.mocha.mantle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2,
          shadowColor: AppColors.mocha.overlay0.withOpacity(0.6),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.mocha.mantle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.mocha.subtext0, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.mocha.subtext0, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.mocha.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: TextStyle(
            color: AppColors.mocha.subtext1,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: AppColors.mocha.subtext0),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.mocha.mantle,
          selectedItemColor: AppColors.mocha.blue,
          unselectedItemColor: AppColors.mocha.subtext1,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showUnselectedLabels: true,
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.mocha.crust,
          thickness: 1,
          space: 1,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.mocha.blue;
            }
            return AppColors.mocha.mantle;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(color: AppColors.mocha.subtext0, width: 1.5),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.mocha.blue;
            }
            return AppColors.mocha.mantle;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.mocha.blue.withOpacity(0.4);
            }
            return AppColors.mocha.subtext0.withOpacity(0.4);
          }),
          trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.transparent;
            }
            return AppColors.mocha.subtext0;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.mocha.blue;
            }
            return AppColors.mocha.subtext0;
          }),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: AppColors.mocha.blue,
          textColor: AppColors.mocha.text,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: AppColors.mocha.mantle,
          selectedTileColor: AppColors.mocha.crust,
        ),
      );
}
