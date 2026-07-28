import 'package:flutter/material.dart';

class AppTheme {
  static const Color brand = Color(0xFF2563EB);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: brand,
      onPrimary: Colors.white,
      secondary: Color(0xFFE85D75),
      onSecondary: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF17181C),
      error: Color(0xFFB3261E),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
    cardColor: const Color(0xFFFFFFFF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF6F7FB),
      foregroundColor: Color(0xFF17181C),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: const Color(0x1F17181C),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: brand,
      onPrimary: Colors.black,
      secondary: Color(0xFFFFB74D),
      onSecondary: Colors.black,
      surface: Color(0xFF18191C),
      onSurface: Colors.white,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
    scaffoldBackgroundColor: const Color(0xFF111214),
    cardColor: const Color(0xFF18191C),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111214),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: const Color(0x1FFFFFFF),
  );
}

extension AppThemeContext on BuildContext {
  Color get appBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get appSurface => Theme.of(this).colorScheme.surface;
  Color get appText => Theme.of(this).colorScheme.onSurface;
  Color get appMutedText => appText.withValues(alpha: 0.65);
  Color get appSubtleText => appText.withValues(alpha: 0.45);
  Color get appFaintText => appText.withValues(alpha: 0.24);
  Color get appBorder => appText.withValues(alpha: 0.14);
  Color get appAccent => Theme.of(this).colorScheme.primary;
  Color get appOnAccent => Theme.of(this).colorScheme.onPrimary;
}
