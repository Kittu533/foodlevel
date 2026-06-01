import 'package:flutter/widgets.dart';

import 'package:foodlevel/core/theme/motion_preference.dart';

/// Custom [PageRouteBuilder] that provides the Vibrant Earth page transition.
///
/// When motion is enabled the transition combines a fade with a subtle upward
/// slide (6% of screen height).  When the system reduce-motion flag is set
/// only a simple fade is used, keeping the experience accessible.
///
/// Durations:
///   • forward  : 320 ms
///   • reverse  : 240 ms
///
/// Requirements: 8.1, 8.2, 8.3, 8.4
class VibrantPageRoute<T> extends PageRouteBuilder<T> {
  VibrantPageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (ctx, _, __) => builder(ctx),
          transitionsBuilder: (ctx, anim, _, child) {
            final reduced = MotionPreference.disabled(ctx);

            if (reduced) {
              // Reduced-motion path: fade only, equivalent to 150 ms feel.
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            }

            // Full-motion path: fade + subtle slide from 6% below.
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return FadeTransition(
              opacity: CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(
                position: anim.drive(slide),
                child: child,
              ),
            );
          },
        );
}
