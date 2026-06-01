import 'package:flutter/animation.dart';

/// Standard animation durations and curves for the Vibrant Earth UI refresh.
///
/// All call-sites must read durations from this class rather than using
/// magic number literals. This ensures cross-screen consistency and makes
/// global timing adjustments trivial.
abstract final class AnimationBudget {
  // ── Base durations ──────────────────────────────────────────────────────────

  /// Micro-interactions: tap scale, icon swap. 150 ms.
  static const fast = Duration(milliseconds: 150);

  /// Standard transitions and reveals. 300 ms.
  static const base = Duration(milliseconds: 300);

  /// Complex enter animations and hero transitions. 500 ms.
  static const slow = Duration(milliseconds: 500);

  /// Shared-element (Hero) transitions between screens. 450 ms.
  static const hero = Duration(milliseconds: 450);

  // ── Named durations (cross-screen consistency) ───────────────────────────────

  /// ScanningBeam loop period. 1500 ms.
  static const beamLoop = Duration(milliseconds: 1500);

  /// Shimmer skeleton loop period. 1200 ms.
  static const shimmerLoop = Duration(milliseconds: 1200);

  /// AnimatedNutritionBar fill tween. 800 ms.
  static const nutritionBar = Duration(milliseconds: 800);

  /// FoodLevelBadge scale reveal. 600 ms.
  static const badgeReveal = Duration(milliseconds: 600);

  /// FoodLevelBadge glow ring opacity tween. 1200 ms.
  static const badgeGlow = Duration(milliseconds: 1200);

  /// FoodLevelBadge level-D horizontal shake. 400 ms.
  static const badgeShake = Duration(milliseconds: 400);

  /// ConfettiBurst emission duration. 1500 ms.
  static const confetti = Duration(milliseconds: 1500);

  /// SwipeToDeleteTile collapse after dismiss. 300 ms.
  static const swipeCollapse = Duration(milliseconds: 300);

  /// History counter TweenAnimationBuilder. 400 ms.
  static const counterTween = Duration(milliseconds: 400);

  /// Fallback fade when reduced motion is active. 200 ms.
  static const reducedMotionFade = Duration(milliseconds: 200);

  // ── Curve constants ──────────────────────────────────────────────────────────

  /// Default curve for most transitions: smooth deceleration.
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Badge / element reveal: spring-like overshoot.
  static const Curve revealCurve = Curves.elasticOut;

  /// Spring-back / indicator bounce: slight overshoot and settle.
  static const Curve bounceCurve = Curves.easeOutBack;
}
