import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/theme/animation_budget.dart';
import '../../core/theme/motion_preference.dart';
import '../../core/theme/vibrant_palette.dart';
import '../../core/utils/haptic_controller.dart';

/// Controller for [ConfettiBurst] that decouples the trigger site from the
/// widget rendering the particles.
///
/// [ConfettiBurstController] is a [ChangeNotifier]. Call [play] to signal
/// the associated [ConfettiBurst] widget to emit a one-shot particle burst.
/// The widget checks [MotionPreference] before actually firing; if the user
/// has requested reduced motion, the entire burst — including haptic — is
/// silently skipped (Requirement 6.7).
///
/// Usage:
/// ```dart
/// final _burstCtrl = ConfettiBurstController();
///
/// // Inside build (in a Stack at the topmost layer):
/// ConfettiBurst(controller: _burstCtrl)
///
/// // Trigger the burst from any point in the widget tree:
/// _burstCtrl.play();
///
/// // Clean up:
/// _burstCtrl.dispose();
/// ```
///
/// Requirements: 6.5, 6.7, 10.2, 10.3, 13.2, 13.4
class ConfettiBurstController extends ChangeNotifier {
  bool _pendingPlay = false;

  /// Signals [ConfettiBurst] to fire a one-shot particle burst.
  ///
  /// The actual emission is gated on [MotionPreference] inside the widget's
  /// listener, so calling [play] while reduced motion is enabled is a safe
  /// no-op — neither particles nor haptic feedback will be triggered.
  void play() {
    _pendingPlay = true;
    notifyListeners();
  }

  /// Atomically consumes and returns the pending-play flag.
  ///
  /// Called by [_ConfettiBurstState._onControllerNotified] to prevent
  /// double-firing if the widget rebuilds before the flag is cleared.
  bool _consumePendingPlay() {
    if (_pendingPlay) {
      _pendingPlay = false;
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Overlay widget that fires a one-shot confetti particle burst anchored at
/// the top-center of its parent.
///
/// The burst is triggered by calling [ConfettiBurstController.play] on the
/// provided [controller]. Motion-preference checks are performed inside the
/// listener: if [MotionPreference.disabled] returns `true`, neither confetti
/// particles nor haptic feedback are emitted (Requirement 6.7, 13.4).
///
/// Place this widget at the topmost layer of a [Stack] so particles can fall
/// over the full content area:
///
/// ```dart
/// Stack(
///   children: [
///     // ... screen content ...
///     Positioned.fill(
///       child: ConfettiBurst(controller: _burstCtrl),
///     ),
///   ],
/// )
/// ```
///
/// Requirements: 6.5, 6.7, 10.2, 10.3, 13.2, 13.4, 14.3, 14.5
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    required this.controller,
    super.key,
  });

  /// The controller used to trigger the burst via [ConfettiBurstController.play].
  final ConfettiBurstController controller;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Configure the internal confetti controller for a 1500 ms burst
    // (AnimationBudget.confetti), matching the design-doc spec (Req 10.2).
    _confettiController = ConfettiController(
      duration: AnimationBudget.confetti,
    );
    widget.controller.addListener(_onControllerNotified);
  }

  @override
  void didUpdateWidget(ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Swap listeners if the controller instance changes.
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerNotified);
      widget.controller.addListener(_onControllerNotified);
    }
  }

  /// Listener invoked when [ConfettiBurstController.play] is called.
  ///
  /// Guards emission behind [MotionPreference.disabled]: if the user has
  /// requested reduced motion, both confetti and haptic feedback are skipped
  /// in full (Requirement 6.7, 13.4).
  void _onControllerNotified() {
    if (!widget.controller._consumePendingPlay()) return;
    if (!mounted) return;

    // Reduced-motion gate: skip confetti AND haptic when motion is disabled.
    if (MotionPreference.disabled(context)) return;

    // Heavy haptic fires once at burst start (Requirement 10.3).
    HapticController.heavy();

    // Start the 1500 ms particle emission.
    _confettiController.play();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerNotified);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = context.vibrantPalette;

    // Particle color mix: primary, secondary, tertiary from ColorScheme
    // plus levelA from VibrantLevelPalette (Requirement 10.2).
    final particleColors = <Color>[
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      palette.levelA,
    ];

    // RepaintBoundary isolates the particle animation from the rest of the
    // widget tree so repaints stay confined to this subtree (Requirement 14.5).
    return RepaintBoundary(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          // 360° explosive spread from emission point.
          blastDirectionality: BlastDirectionality.explosive,
          // One-shot burst — does not loop (Requirement 10.2).
          shouldLoop: false,
          colors: particleColors,
          numberOfParticles: 30,
          gravity: 0.3,
          emissionFrequency: 0.05,
          maxBlastForce: 20,
          minBlastForce: 8,
        ),
      ),
    );
  }
}
