import 'package:flutter/material.dart';
import 'package:foodlevel/core/theme/motion_preference.dart';

class AnimatedEntry extends StatelessWidget {
  const AnimatedEntry({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 16),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    // Requirements: 13.2, 13.3 — when reduced motion is requested, skip the
    // fade/translate animation entirely and render the child at its final
    // (fully-visible, zero-offset) state immediately.
    if (MotionPreference.disabled(context)) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayedValue = _normalizeDelayedValue(value);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - delayedValue),
              offset.dy * (1 - delayedValue),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  double _normalizeDelayedValue(double value) {
    if (delay == Duration.zero) {
      return value;
    }

    final delayRatio = delay.inMilliseconds / (420 + delay.inMilliseconds);
    if (value <= delayRatio) {
      return 0;
    }

    return ((value - delayRatio) / (1 - delayRatio)).clamp(0, 1);
  }
}
