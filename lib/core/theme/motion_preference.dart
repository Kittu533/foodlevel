import 'package:flutter/widgets.dart';

/// Utility class for respecting the system-level "reduce motion" preference.
///
/// All animation sites should gate their motion through this class so that
/// users who have enabled *Reduce Motion* (iOS) or *Remove Animations*
/// (Android Accessibility) experience a fully accessible UI.
///
/// Requirements: 13.1
abstract final class MotionPreference {
  /// Returns `true` when the user has requested that animations be disabled.
  ///
  /// Reads [MediaQueryData.disableAnimations] from the nearest [MediaQuery]
  /// ancestor. Falls back to `false` (motion enabled) when no [MediaQuery] is
  /// present in the tree.
  static bool disabled(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Returns [full] unchanged when motion is enabled, or [Duration.zero] when
  /// the user has requested reduced motion.
  ///
  /// Use this to scale any animation duration at its call-site:
  /// ```dart
  /// AnimationController(
  ///   duration: MotionPreference.scaled(context, AnimationBudget.base),
  ///   vsync: this,
  /// );
  /// ```
  static Duration scaled(BuildContext context, Duration full) =>
      disabled(context) ? Duration.zero : full;

  /// Executes [fn] only when motion is enabled.
  ///
  /// Use this to guard fire-and-forget animation triggers (e.g. starting a
  /// one-shot particle burst) that should be completely skipped for users who
  /// prefer reduced motion.
  static void runIfMotion(BuildContext context, VoidCallback fn) {
    if (!disabled(context)) fn();
  }
}
