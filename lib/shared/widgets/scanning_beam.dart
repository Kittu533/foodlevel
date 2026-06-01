import 'package:flutter/material.dart';
import '../../core/theme/animation_budget.dart';
import '../../core/theme/motion_preference.dart';

/// Animated scanning beam overlay.
///
/// Renders a translucent horizontal stripe that travels vertically from top
/// (position 0) to bottom (position [fullHeight]) in a continuous loop while
/// [active] is `true` and the user has not requested reduced motion.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     ImagePreview(...),
///     Positioned.fill(
///       child: ScanningBeam(active: state.isLoading),
///     ),
///   ],
/// )
/// ```
///
/// The beam pauses automatically when the app enters the background
/// ([AppLifecycleState.paused]) and resumes when the app returns to the
/// foreground ([AppLifecycleState.resumed]).
///
/// Requirements: 4.1, 13.2, 14.2, 14.3, 14.4, 14.5
class ScanningBeam extends StatefulWidget {
  const ScanningBeam({
    required this.active,
    this.color,
    super.key,
  });

  /// Whether the scanning beam animation is running.
  ///
  /// When `false`, the animation is stopped and the widget renders nothing.
  final bool active;

  /// Override color for the beam gradient. Defaults to
  /// [ColorScheme.primary] with alpha 0.20 when not provided.
  final Color? color;

  @override
  State<ScanningBeam> createState() => _ScanningBeamState();
}

class _ScanningBeamState extends State<ScanningBeam>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Height of the gradient stripe in logical pixels.
  static const double _beamHeight = 80.0;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationBudget.beamLoop,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-evaluate on dependency changes (e.g. MediaQuery.disableAnimations).
    _syncAnimation();
  }

  @override
  void didUpdateWidget(ScanningBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _syncAnimation();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Stop the loop to conserve battery while the app is in the background.
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      // Restart only if the widget is still active and motion is allowed.
      _syncAnimation();
    }
  }

  /// Starts or stops the beam loop based on [widget.active] and the current
  /// motion preference.
  void _syncAnimation() {
    if (!mounted) return;
    final motionDisabled = MotionPreference.disabled(context);
    if (widget.active && !motionDisabled) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.color ?? Theme.of(context).colorScheme.primary;
    // Beam center color: primary at alpha 0.20, as specified in the design.
    final beamColor = primary.withValues(alpha: 0.20);

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fullHeight = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Tween the top of the stripe from 0 to fullHeight over the loop.
              final top = _controller.value * fullHeight;

              return Stack(
                // Clip the stripe so it doesn't bleed outside the overlay area.
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    height: _beamHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            beamColor,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
