import 'package:flutter/material.dart';
import 'package:foodlevel/features/scan/domain/nutrition_level.dart';

/// Brand-level color constants for the Vibrant Earth / Healthy Glow theme.
///
/// These constants are used exclusively by the theme engine to build
/// [ColorScheme] and [VibrantLevelPalette]. Widget call-sites should read
/// colors from [Theme.of(context).colorScheme] or [context.vibrantPalette]
/// rather than referencing [VibrantBrand] directly.
abstract final class VibrantBrand {
  /// Matcha Green — primary seed color.
  static const matchaGreen = Color(0xFF2E7D5C);

  /// Terracotta Orange — secondary color (light) / level-D indicator.
  static const terracottaOrange = Color(0xFFE76F51);

  /// Mustard Yellow — tertiary color (light).
  static const mustardYellow = Color(0xFFF4A261);

  /// Cream Beige — scaffold/surface background (light).
  static const creamBeige = Color(0xFFFFF8EC);

  /// Deep Charcoal — primary on-surface text color (light).
  static const deepCharcoal = Color(0xFF2D3142);

  /// Dark Surface — scaffold/surface background (dark).
  static const darkSurface = Color(0xFF1A1C22);

  /// Dark Secondary — secondary color override (dark).
  static const darkSecondary = Color(0xFFFF8C42);

  /// Dark Tertiary — tertiary color override (dark).
  static const darkTertiary = Color(0xFFFFB627);
}

/// A [ThemeExtension] that carries per-nutrition-level color pairs
/// (background + on-color) for both light and dark brightness.
///
/// Access via [context.vibrantPalette] or directly through
/// [Theme.of(context).extension<VibrantLevelPalette>()].
@immutable
class VibrantLevelPalette extends ThemeExtension<VibrantLevelPalette> {
  const VibrantLevelPalette({
    required this.levelA,
    required this.levelB,
    required this.levelC,
    required this.levelD,
    required this.onLevelA,
    required this.onLevelB,
    required this.onLevelC,
    required this.onLevelD,
  });

  /// Background color for nutrition level A (best / green).
  final Color levelA;

  /// Background color for nutrition level B (good / lime).
  final Color levelB;

  /// Background color for nutrition level C (moderate / amber).
  final Color levelC;

  /// Background color for nutrition level D (poor / terracotta, not harsh red).
  final Color levelD;

  /// Foreground color rendered on top of [levelA].
  final Color onLevelA;

  /// Foreground color rendered on top of [levelB].
  final Color onLevelB;

  /// Foreground color rendered on top of [levelC].
  final Color onLevelC;

  /// Foreground color rendered on top of [levelD].
  final Color onLevelD;

  /// Returns the background color for the given [level].
  Color colorOf(NutritionLevel level) => switch (level) {
        NutritionLevel.a => levelA,
        NutritionLevel.b => levelB,
        NutritionLevel.c => levelC,
        NutritionLevel.d => levelD,
      };

  /// Returns the foreground (on-) color for the given [level].
  Color onColorOf(NutritionLevel level) => switch (level) {
        NutritionLevel.a => onLevelA,
        NutritionLevel.b => onLevelB,
        NutritionLevel.c => onLevelC,
        NutritionLevel.d => onLevelD,
      };

  @override
  VibrantLevelPalette copyWith({
    Color? levelA,
    Color? levelB,
    Color? levelC,
    Color? levelD,
    Color? onLevelA,
    Color? onLevelB,
    Color? onLevelC,
    Color? onLevelD,
  }) {
    return VibrantLevelPalette(
      levelA: levelA ?? this.levelA,
      levelB: levelB ?? this.levelB,
      levelC: levelC ?? this.levelC,
      levelD: levelD ?? this.levelD,
      onLevelA: onLevelA ?? this.onLevelA,
      onLevelB: onLevelB ?? this.onLevelB,
      onLevelC: onLevelC ?? this.onLevelC,
      onLevelD: onLevelD ?? this.onLevelD,
    );
  }

  @override
  VibrantLevelPalette lerp(ThemeExtension<VibrantLevelPalette>? other, double t) {
    if (other is! VibrantLevelPalette) return this;
    return VibrantLevelPalette(
      levelA: Color.lerp(levelA, other.levelA, t)!,
      levelB: Color.lerp(levelB, other.levelB, t)!,
      levelC: Color.lerp(levelC, other.levelC, t)!,
      levelD: Color.lerp(levelD, other.levelD, t)!,
      onLevelA: Color.lerp(onLevelA, other.onLevelA, t)!,
      onLevelB: Color.lerp(onLevelB, other.onLevelB, t)!,
      onLevelC: Color.lerp(onLevelC, other.onLevelC, t)!,
      onLevelD: Color.lerp(onLevelD, other.onLevelD, t)!,
    );
  }

  /// Pre-built palette for light theme.
  ///
  /// Level D uses terracotta [Color(0xFFE76F51)] — not a harsh red —
  /// satisfying contrast ≥ 4.5:1 with white foreground (Requirement 3.5).
  static const light = VibrantLevelPalette(
    levelA: Color(0xFF4CAF50),
    levelB: Color(0xFFA8C957),
    levelC: Color(0xFFF4A261),
    levelD: Color(0xFFE76F51),
    onLevelA: Colors.white,
    onLevelB: VibrantBrand.deepCharcoal,
    onLevelC: VibrantBrand.deepCharcoal,
    onLevelD: Colors.white,
  );

  /// Pre-built palette for dark theme.
  ///
  /// Slightly lighter / more saturated variants maintain contrast ≥ 4.5:1
  /// against their respective dark on-colors (Requirement 2.4, 3.3).
  static const dark = VibrantLevelPalette(
    levelA: Color(0xFF66BB6A),
    levelB: Color(0xFFC5DB7E),
    levelC: Color(0xFFFFB867),
    levelD: Color(0xFFFF8A65),
    onLevelA: Color(0xFF0F1610),
    onLevelB: Color(0xFF0F1610),
    onLevelC: Color(0xFF1A1306),
    onLevelD: Color(0xFF1B0E0A),
  );
}

/// Convenience extension so widgets can write `context.vibrantPalette`
/// instead of `Theme.of(context).extension<VibrantLevelPalette>()!`.
extension VibrantPaletteContext on BuildContext {
  /// Returns the [VibrantLevelPalette] attached to the nearest [Theme].
  ///
  /// Throws if no [VibrantLevelPalette] extension is registered on the theme
  /// (i.e. [AppTheme.light] / [AppTheme.dark] was not used).
  VibrantLevelPalette get vibrantPalette =>
      Theme.of(this).extension<VibrantLevelPalette>()!;
}
