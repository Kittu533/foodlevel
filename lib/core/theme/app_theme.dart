import 'package:flutter/material.dart';
import 'package:foodlevel/core/theme/vibrant_palette.dart';

/// Builds [ThemeData] for the Vibrant Earth / Healthy Glow theme.
///
/// Call-sites should use [AppTheme.light] and [AppTheme.dark] for
/// [MaterialApp.theme] and [MaterialApp.darkTheme] respectively.
/// All colors are sourced from [VibrantBrand] and [VibrantLevelPalette];
/// no hardcoded [Color] values appear outside [vibrant_palette.dart].
class AppTheme {
  const AppTheme._();

  /// Returns the light [ThemeData] using Matcha Green as the seed color with
  /// Cream Beige surface and Terracotta / Mustard accent overrides.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: VibrantBrand.matchaGreen,
      brightness: Brightness.light,
    ).copyWith(
      secondary: VibrantBrand.terracottaOrange,
      tertiary: VibrantBrand.mustardYellow,
      surface: VibrantBrand.creamBeige,
      onSurface: VibrantBrand.deepCharcoal,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: VibrantBrand.creamBeige,
      extensions: const [VibrantLevelPalette.light],
    );
  }

  /// Returns the dark [ThemeData] using Matcha Green as the seed color with
  /// dark-optimised secondary / tertiary overrides and a deep charcoal surface.
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: VibrantBrand.matchaGreen,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: VibrantBrand.darkSecondary,
      tertiary: VibrantBrand.darkTertiary,
      surface: VibrantBrand.darkSurface,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: VibrantBrand.darkSurface,
      extensions: const [VibrantLevelPalette.dark],
    );
  }

  /// Shared base [ThemeData] builder that wires [AppBarTheme], [CardTheme],
  /// [NavigationBarThemeData], [FilledButtonThemeData], and
  /// [OutlinedButtonThemeData] from the provided [scheme].
  static ThemeData _baseTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
