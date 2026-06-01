import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:foodlevel/core/theme/motion_preference.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays an empty-state illustration (Lottie animation) above
/// a descriptive message.
///
/// Attempts to load a Lottie asset from [assetPath]. If the asset is missing
/// (e.g. the `.json` file has not been added to the bundle), it falls back to
/// an implicit animation: the `restaurant_menu` icon gently rocking ±5°.
///
/// Lifecycle behaviour:
/// - The loop is started after the first frame (via [didChangeDependencies])
///   once the [BuildContext] is available for [MotionPreference] checks.
/// - The loop is stopped by a [Timer] after [maxLoopDuration] to conserve
///   battery (Requirement 10.4).
/// - [WidgetsBindingObserver] pauses the loop when the app enters
///   [AppLifecycleState.paused] and resumes it when it returns to
///   [AppLifecycleState.resumed] — provided the [Timer] has not expired yet
///   (Requirement 14.4).
/// - When [MotionPreference.disabled] is true, the controller is left at
///   value 0 and never repeated (Requirements 10.5, 13.2).
///
/// Wrapped in [RepaintBoundary] to limit repaint scope (Requirements 14.2, 14.5).
///
/// Requirements: 10.1, 10.4, 10.5, 13.2, 14.2, 14.3, 14.4
class EmptyStateIllustration extends StatefulWidget {
  const EmptyStateIllustration({
    required this.assetPath,
    required this.message,
    this.maxLoopDuration = const Duration(seconds: 30),
    super.key,
  });

  /// Path to the Lottie JSON asset (e.g. `'assets/animations/empty_history.json'`).
  final String assetPath;

  /// Descriptive message rendered below the illustration.
  final String message;

  /// Duration after which the animation loop is stopped to save battery.
  /// Defaults to 30 seconds (Requirement 10.4).
  final Duration maxLoopDuration;

  @override
  State<EmptyStateIllustration> createState() => _EmptyStateIllustrationState();
}

class _EmptyStateIllustrationState extends State<EmptyStateIllustration>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ctrl;

  /// True once the Lottie asset load fails; switches to fallback widget.
  bool _useFallback = false;

  /// True once [_maxLoopTimer] fires — prevents resuming on foreground.
  bool _loopExpired = false;

  /// Whether [didChangeDependencies] has run at least once (context is ready).
  bool _dependenciesReady = false;

  Timer? _maxLoopTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ctrl = AnimationController(vsync: this);
    // Animation start is deferred to didChangeDependencies so that
    // MotionPreference.disabled(context) can be evaluated correctly.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesReady) {
      _dependenciesReady = true;
      _startIfAppropriate();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _maxLoopTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _ctrl.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (!_loopExpired && mounted) {
        _startIfAppropriate();
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Starts the Lottie loop (or no-ops when reduced motion is active).
  void _startIfAppropriate() {
    if (!mounted) return;
    if (MotionPreference.disabled(context)) {
      // Req 10.5: show first frame, do not animate.
      _ctrl.value = 0;
      return;
    }
    if (_loopExpired) return;

    if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }

    // Req 10.4: stop loop after [maxLoopDuration] (start timer only once).
    _maxLoopTimer ??= Timer(widget.maxLoopDuration, () {
      _loopExpired = true;
      if (mounted) _ctrl.stop();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIllustration(context),
          const SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    if (_useFallback) {
      return _FallbackIllustration(
        motionDisabled: MotionPreference.disabled(context),
      );
    }

    return _LottieIllustration(
      assetPath: widget.assetPath,
      controller: _ctrl,
      onError: () {
        if (mounted) {
          setState(() => _useFallback = true);
          // The fallback TweenAnimationBuilder manages its own loop;
          // cancel the Lottie-specific timer so it doesn't fire spuriously.
          _maxLoopTimer?.cancel();
          _maxLoopTimer = null;
          _loopExpired = false;
        }
      },
    );
  }
}

// ── Lottie illustration ────────────────────────────────────────────────────

/// Internal widget that renders the Lottie animation.
///
/// Catches [FlutterError] for missing assets (and decode errors) and calls
/// [onError] so the parent can switch to the fallback.
class _LottieIllustration extends StatefulWidget {
  const _LottieIllustration({
    required this.assetPath,
    required this.controller,
    required this.onError,
  });

  final String assetPath;
  final AnimationController controller;
  final VoidCallback onError;

  @override
  State<_LottieIllustration> createState() => _LottieIllustrationState();
}

class _LottieIllustrationState extends State<_LottieIllustration> {
  bool _errored = false;

  void _handleError() {
    if (_errored) return;
    _errored = true;
    // Schedule the state update outside of the current build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        widget.onError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errored) {
      // Empty box — parent will replace us with the fallback.
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 200,
      height: 200,
      child: _buildLottie(),
    );
  }

  Widget _buildLottie() {
    try {
      return Lottie.asset(
        widget.assetPath,
        controller: widget.controller,
        fit: BoxFit.contain,
        onLoaded: (composition) {
          // Bind the controller duration to the composition length so that
          // repeat() covers exactly one animation cycle.
          widget.controller.duration = composition.duration;
        },
        errorBuilder: (context, error, stackTrace) {
          // errorBuilder is called for decode errors and (in some Lottie
          // versions) for missing-asset errors.
          _handleError();
          return const SizedBox.shrink();
        },
      );
    } on FlutterError catch (_) {
      // Synchronous throw path: older Lottie versions / asset-bundle errors.
      _handleError();
      return const SizedBox.shrink();
    }
  }
}

// ── Fallback illustration ──────────────────────────────────────────────────

/// Fallback shown when the Lottie asset is missing.
///
/// When motion is enabled: the `restaurant_menu` icon rocks ±5° in a
/// continuous reverse loop driven by a [TweenAnimationBuilder] (Requirement 10.1).
/// When motion is disabled: renders the icon statically (Requirement 10.5, 13.2).
class _FallbackIllustration extends StatefulWidget {
  const _FallbackIllustration({required this.motionDisabled});

  final bool motionDisabled;

  @override
  State<_FallbackIllustration> createState() => _FallbackIllustrationState();
}

class _FallbackIllustrationState extends State<_FallbackIllustration> {
  // Toggle the tween direction on each completion to create a seamless loop.
  bool _forward = true;

  void _onAnimationEnd() {
    if (mounted && !widget.motionDisabled) {
      setState(() => _forward = !_forward);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final icon = Icon(Icons.restaurant_menu, size: 96, color: color);

    if (widget.motionDisabled) {
      // Requirement 10.5 / 13.2: static icon, no animation.
      return icon;
    }

    return TweenAnimationBuilder<double>(
      tween: _forward
          ? Tween<double>(begin: -5, end: 5)
          : Tween<double>(begin: 5, end: -5),
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOut,
      onEnd: _onAnimationEnd,
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: angle * math.pi / 180,
          child: child,
        );
      },
      child: icon,
    );
  }
}
