import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  /// Reference palette: an almost-black indigo canvas, translucent periwinkle
  /// panels, and the saturated electric blue used for the active controls.
  // Muted slate-blue brand keeps controls readable without the electric-blue
  // glow that made the dashboard feel overly bright.
  static const Color brand = Color(0xFF292929);
  static const Color midnight = Color(0xFF090909);
  static const Color indigo = Color(0xFF151515);
  static const Color periwinkle = Color(0xFF3A3A3A);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: brand,
      onPrimary: Colors.white,
      secondary: Color(0xFF666666),
      onSecondary: Colors.white,
      surface: Color(0xFFFAFAF8),
      onSurface: Color(0xFF222222),
      error: Color(0xFFB3261E),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F4F2),
    cardColor: const Color(0xFFFFFFFF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF202020),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: const Color(0x1F17181C),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: brand,
      onPrimary: Colors.white,
      secondary: Color(0xFF777777),
      onSecondary: Colors.white,
      surface: Color(0xFF171717),
      onSurface: Color(0xFFF2F2F2),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
    scaffoldBackgroundColor: midnight,
    cardColor: const Color(0xFF1C1C1C),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF2F2F2),
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
  Color get appAccent => isDarkMode ? Colors.white : const Color(0xFF202020);
  Color get appOnAccent => isDarkMode ? const Color(0xFF171717) : Colors.white;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get appCard =>
      isDarkMode ? const Color(0xFF1C1C1C) : const Color(0xFFFFFFFF);
  Color get appCardBorder =>
      isDarkMode ? const Color(0x2FFFFFFF) : const Color(0x1F000000);
  Color get appNavigation =>
      isDarkMode ? const Color(0xE6101010) : const Color(0xEFFFFFFF);
  Color get appPanelTop =>
      isDarkMode ? const Color(0xA6222222) : const Color(0xEFFFFFFF);
  Color get appPanelBottom =>
      isDarkMode ? const Color(0xC70E0E0E) : const Color(0xDDE8E8E6);
  Color get appOnDark => const Color(0xFFF8F9FF);
}

/// Gradient canvas and ambient blue glow used behind every non-video surface.
/// It provides the depth visible in the reference without changing page content.
class AppVisualBackground extends StatelessWidget {
  const AppVisualBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkMode;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [AppTheme.midnight, Color(0xFF101010), Color(0xFF191919)]
              : const [Colors.white, Colors.white, Colors.white],
          stops: const [0, 0.48, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.95, -0.95),
                  radius: 1.05,
                  colors: dark
                      ? const [Color(0x18000000), Colors.transparent]
                      : const [Color(0x0A000000), Colors.transparent],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// The frosted periwinkle panel treatment used throughout the supplied design.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final panelGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.appPanelTop, context.appPanelBottom],
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.22 : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Ink(
                padding: padding,
                decoration: BoxDecoration(
                  gradient: panelGradient,
                  borderRadius: borderRadius,
                  border: Border.all(color: context.appCardBorder),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: context.appAccent.withValues(alpha: 0.38),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.appAccent,
        foregroundColor: context.appOnAccent,
        elevation: 0,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: child,
    ),
  );
}
