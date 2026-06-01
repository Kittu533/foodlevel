import 'package:flutter/material.dart';
import 'package:foodlevel/core/theme/animation_budget.dart';
import 'package:foodlevel/core/theme/motion_preference.dart';
import 'package:foodlevel/core/utils/haptic_controller.dart';

/// A [FilledButton.icon] that pulses with a subtle scale loop when idle and
/// plays a crisp tap-scale animation on press.
///
/// **Public API is unchanged** — constructor signature (`icon`, `label`,
/// `onPressed`, `key`) is identical to the pre-refresh version (Req 12.1).
///
/// Behavior:
/// - Ambient pulse loop (0.98 ↔ 1.02) runs only when
///   `!MotionPreference.disabled(context)` (Req 13.2).
/// - On tap: `HapticController.medium()` → scale 1.0 → 0.94 → 1.0 over
///   `AnimationBudget.fast` (150 ms) → `onPressed` (Req 4.3, 4.4, 11.1).
/// - When motion is disabled, tap skips both animations and calls `onPressed`
///   immediately (Req 12.4, 13.2).
/// - The entire widget is wrapped in `TickerMode` keyed to
///   `ModalRoute.of(context).isCurrent` so the pulse pauses when another
///   route overlaps this screen (Req 14.2).
class PulseIconButton extends StatefulWidget {
  const PulseIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<PulseIconButton> createState() => _PulseIconButtonState();
}

class _PulseIconButtonState extends State<PulseIconButton>
    with TickerProviderStateMixin {
  // ── Pulse controller ─────────────────────────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  // ── Tap-scale controller ─────────────────────────────────────────────────
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  // Merged listenable for a single AnimatedBuilder subscription.
  late final Listenable _animations;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseScale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tap-scale: 1.0 → 0.94 (compress) → 1.0 (spring back)
    _tapController = AnimationController(
      vsync: this,
      duration: AnimationBudget.fast,
    );
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.94),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.94, end: 1.0),
        weight: 50,
      ),
    ]).animate(_tapController);

    _animations = Listenable.merge([_pulseScale, _tapScale]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Req 13.2: start or stop the pulse loop based on the current motion
    // preference.  didChangeDependencies is called on initial mount AND
    // whenever an InheritedWidget dependency (MediaQuery) changes.
    if (!MotionPreference.disabled(context)) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  // ── Tap handler ───────────────────────────────────────────────────────────

  Future<void> _handleTap() async {
    // Req 12.4, 13.2: when motion is off, skip all animation and fire
    // onPressed synchronously.
    if (MotionPreference.disabled(context)) {
      widget.onPressed();
      return;
    }

    // Prevent re-entrant taps while the tap-scale is already running.
    if (_tapController.isAnimating) return;

    // Req 4.4, 11.1: haptic fires before the visual animation.
    await HapticController.medium();
    if (!mounted) return;

    // Req 4.3: 1.0 → 0.94 → 1.0 over AnimationBudget.fast (150 ms).
    await _tapController.forward(from: 0.0);
    if (!mounted) return;

    widget.onPressed();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool motionOff = MotionPreference.disabled(context);

    // Req 14.2: pause the pulse ticker when the screen is not the top-most
    // route (e.g. another route is pushed on top of this one).
    return TickerMode(
      enabled: ModalRoute.of(context)?.isCurrent ?? true,
      child: AnimatedBuilder(
        animation: _animations,
        builder: (context, child) {
          // When motion is disabled the pulse controller is stopped; use only
          // the tap scale (which stays at 1.0 when tap animation is inactive).
          final scale = motionOff
              ? _tapScale.value
              : _pulseScale.value * _tapScale.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: FilledButton.icon(
          onPressed: _handleTap,
          // Req 12.1, 12.2: button color flows from Theme primary (default for
          // FilledButton.icon — no hardcoded color needed).
          icon: Icon(widget.icon),
          label: Text(widget.label),
        ),
      ),
    );
  }
}
