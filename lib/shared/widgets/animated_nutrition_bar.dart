import 'package:flutter/material.dart';
import 'package:foodlevel/core/theme/animation_budget.dart';
import 'package:foodlevel/core/theme/motion_preference.dart';

/// A horizontal bar widget that animates from 0 to [valueRatio] on mount.
///
/// Displays a [label] on the left, an animated fill bar in the centre, and an
/// optional [trailingText] on the right. The fill animation uses a
/// `TweenAnimationBuilder<double>` driven by [duration] and
/// `Curves.easeOutCubic`. When the system "reduce-motion" preference is active,
/// the bar renders at [valueRatio] immediately with no animation.
///
/// An optional [delay] defers the start of the tween. Before the delay
/// expires the bar stays at 0; after it the tween runs from 0 to [valueRatio].
/// This lets parent widgets stagger multiple bars without needing a shared
/// `AnimationController`.
///
/// Requirements: 6.1, 6.2, 13.2, 13.3, 14.5
class AnimatedNutritionBar extends StatefulWidget {
  const AnimatedNutritionBar({
    required this.label,
    required this.valueRatio,
    required this.color,
    this.duration = AnimationBudget.nutritionBar,
    this.delay = Duration.zero,
    this.trailingText,
    super.key,
  }) : assert(valueRatio >= 0.0 && valueRatio <= 1.0,
            'valueRatio must be in [0, 1]');

  /// Left-side label text.
  final String label;

  /// Fill ratio in the range [0, 1].
  final double valueRatio;

  /// Bar fill colour.
  final Color color;

  /// Duration of the fill animation (defaults to [AnimationBudget.nutritionBar]).
  final Duration duration;

  /// Delay before the fill animation starts. The bar stays at 0 until the
  /// delay expires, then animates from 0 to [valueRatio].
  final Duration delay;

  /// Optional text shown on the right side (e.g. "12 g").
  final String? trailingText;

  @override
  State<AnimatedNutritionBar> createState() => _AnimatedNutritionBarState();
}

class _AnimatedNutritionBarState extends State<AnimatedNutritionBar> {
  /// Whether the delay has elapsed and the tween should run to [valueRatio].
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _started = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          setState(() => _started = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final motionOff = MotionPreference.disabled(context);

    // When motion is disabled render the bar at its final value immediately.
    // When motion is enabled but the delay has not yet elapsed, begin/end are
    // both 0 so the builder renders an empty bar while waiting.
    final double tweenEnd = (motionOff || _started) ? widget.valueRatio : 0.0;
    final Duration effectiveDuration =
        motionOff ? Duration.zero : widget.duration;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: tweenEnd),
        duration: effectiveDuration,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return _NutritionBarRow(
            label: widget.label,
            fillRatio: value,
            color: widget.color,
            trailingText: widget.trailingText,
          );
        },
      ),
    );
  }
}

/// Stateless row layout: label | bar | trailingText.
///
/// Kept separate so the [TweenAnimationBuilder] child subtree is as light as
/// possible — only the `LayoutBuilder`/`FractionallySizedBox` fraction changes
/// on each animation tick.
class _NutritionBarRow extends StatelessWidget {
  const _NutritionBarRow({
    required this.label,
    required this.fillRatio,
    required this.color,
    this.trailingText,
  });

  final String label;
  final double fillRatio;
  final Color color;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Label (omitted when empty) ────────────────────────────────────
        if (label.isNotEmpty) ...[
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
        ],

        // ── Animated fill bar ───────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Track (background)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const SizedBox.expand(),
                      ),
                      // Fill
                      FractionallySizedBox(
                        widthFactor: fillRatio.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // ── Trailing text ───────────────────────────────────────────────────
        if (trailingText != null) ...[
          const SizedBox(width: 8),
          Text(
            trailingText!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
