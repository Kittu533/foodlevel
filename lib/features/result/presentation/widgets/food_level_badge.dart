import 'package:flutter/material.dart';

import '../../../../core/theme/animation_budget.dart';
import '../../../../core/theme/motion_preference.dart';
import '../../../../core/theme/vibrant_palette.dart';
import '../../../scan/domain/nutrition_level.dart';

/// Animated badge that displays a nutrition level grade (A–D).
///
/// The badge supports a three-phase reveal when [animateReveal] is `true`
/// and [MotionPreference] is not disabled:
///
/// 1. **Reveal** — scale from 0.6 → 1.0 with [Curves.elasticOut] over
///    [AnimationBudget.badgeReveal].
/// 2. **Glow** (when [glowOnReveal] is `true`) — [BoxShadow] opacity tween
///    0 → 0.4 → 0 over [AnimationBudget.badgeGlow].
/// 3. **Shake** (level D only) — horizontal ±4 px translation over
///    [AnimationBudget.badgeShake] after the reveal completes.
///
/// When [MotionPreference.disabled] returns `true` or [animateReveal] is
/// `false`, the badge is rendered at its final state immediately with no
/// animation.
///
/// Requirements: 3.2, 3.5, 6.3, 6.4, 12.1, 12.5, 13.2, 13.3, 14.3
class FoodLevelBadge extends StatefulWidget {
  const FoodLevelBadge({
    required this.level,
    this.size = 56,
    this.animateReveal = true,
    this.glowOnReveal = true,
    super.key,
  });

  /// The nutrition level grade to display.
  final NutritionLevel level;

  /// Side length of the square badge in logical pixels. Defaults to 56.
  final double size;

  /// Whether to run the reveal (scale-in + glow + shake) animation.
  ///
  /// Set to `false` in informational contexts (e.g. GuideScreen) where the
  /// badge should appear static.
  final bool animateReveal;

  /// Whether to show the glow ring after the reveal animation.
  ///
  /// Only relevant when [animateReveal] is `true` and motion is enabled.
  final bool glowOnReveal;

  @override
  State<FoodLevelBadge> createState() => _FoodLevelBadgeState();
}

class _FoodLevelBadgeState extends State<FoodLevelBadge>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────────────

  /// Drives scale 0.6 → 1.0 with elasticOut for the badge reveal.
  late final AnimationController _revealCtrl;

  /// Drives BoxShadow opacity 0 → 0.4 → 0 for the glow ring.
  late final AnimationController _glowCtrl;

  /// Drives horizontal shake ±4 px for NutritionLevel.d.
  late final AnimationController _shakeCtrl;

  // ── Animations ───────────────────────────────────────────────────────────────

  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowOpacityAnim;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _revealCtrl = AnimationController(
      vsync: this,
      duration: AnimationBudget.badgeReveal,
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: AnimationBudget.badgeGlow,
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: AnimationBudget.badgeShake,
    );

    // Scale 0.6 → 1.0 with elasticOut curve.
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _revealCtrl, curve: AnimationBudget.revealCurve),
    );

    // Glow opacity: 0 → 0.4 (first half) → 0 (second half).
    _glowOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.4),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 0.0),
        weight: 50,
      ),
    ]).animate(_glowCtrl);

    // Shake: oscillates between -4 and +4 px using a sine-like TweenSequence.
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -4.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.0, end: 4.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 4.0, end: -4.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.0, end: 4.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 4.0, end: -4.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.0, end: 0.0),
        weight: 10,
      ),
    ]).animate(_shakeCtrl);

    // Register reveal-completion listener to kick off glow + shake.
    _revealCtrl.addStatusListener(_onRevealStatus);

    // Start reveal after the first frame so the widget is in the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeStartReveal();
    });
  }

  @override
  void didUpdateWidget(FoodLevelBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If animateReveal toggled on after being off, restart animation.
    if (widget.animateReveal && !oldWidget.animateReveal) {
      _maybeStartReveal();
    }
  }

  /// Starts the reveal animation if conditions are met (motion enabled + flag).
  void _maybeStartReveal() {
    if (!widget.animateReveal || MotionPreference.disabled(context)) return;
    _revealCtrl.forward(from: 0.0);
  }

  /// Called when reveal completes — triggers glow and (for level D) shake.
  void _onRevealStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    if (widget.glowOnReveal) {
      _glowCtrl.forward(from: 0.0);
    }
    if (widget.level == NutritionLevel.d) {
      _shakeCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _revealCtrl
      ..removeStatusListener(_onRevealStatus)
      ..dispose();
    _glowCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final palette = context.vibrantPalette;
    final bgColor = palette.colorOf(widget.level);
    final textColor = palette.onColorOf(widget.level);

    final bool animate =
        widget.animateReveal && !MotionPreference.disabled(context);

    // Static badge (no animation).
    final badgeWidget = _BadgeBody(
      level: widget.level,
      size: widget.size,
      bgColor: bgColor,
      textColor: textColor,
    );

    if (!animate) {
      return badgeWidget;
    }

    // Animated badge: glow ring underneath + shake + scale on top.
    return AnimatedBuilder(
      animation: Listenable.merge([_revealCtrl, _glowCtrl, _shakeCtrl]),
      builder: (context, _) {
        final glowOpacity = _glowOpacityAnim.value;
        final scale = _scaleAnim.value;
        final shakeX = _shakeAnim.value;

        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.214),
                boxShadow: [
                  // Persistent soft elevation shadow.
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  // Glow ring that pulses 0 → 0.4 → 0.
                  BoxShadow(
                    color: bgColor.withValues(alpha: glowOpacity),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: badgeWidget,
            ),
          ),
        );
      },
    );
  }
}

/// The inner badge: rounded square with level letter, no animation state.
class _BadgeBody extends StatelessWidget {
  const _BadgeBody({
    required this.level,
    required this.size,
    required this.bgColor,
    required this.textColor,
  });

  final NutritionLevel level;
  final double size;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.214),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        level.label,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
