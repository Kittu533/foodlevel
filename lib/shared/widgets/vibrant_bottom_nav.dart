import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/motion_preference.dart';
import '../../core/utils/haptic_controller.dart';

/// Data class describing one destination in [VibrantBottomNav].
///
/// [icon] is shown when the tab is inactive; [selectedIcon] when active.
///
/// Requirements: 7.4
class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// Icon shown while this tab is **not** selected.
  final IconData icon;

  /// Icon shown while this tab **is** selected.
  final IconData selectedIcon;

  /// Text label rendered beneath the icon.
  final String label;
}

/// A custom bottom navigation bar with spring-animated indicator pill and
/// scale micro-interactions on each tab.
///
/// ## Behaviour
/// - A rounded pill indicator slides between tabs driven by a
///   [SpringSimulation] (stiffness 180, damping 20). Requirements: 7.1
/// - The icon of the newly selected tab scales 1.0 → 1.15 → 1.0 over 250 ms
///   with [Curves.easeOutBack]. Requirements: 7.2
/// - [HapticController.selection] is called on every tap. Requirements: 7.3
/// - Active indicator uses [ColorScheme.primary]; inactive icons use
///   [ColorScheme.onSurfaceVariant]. Requirements: 7.4
/// - When [MotionPreference.disabled] is `true` the indicator jumps instantly
///   to the new position and the scale animation is skipped. Requirements: 7.5,
///   13.2
/// - All [AnimationController] instances are disposed in [State.dispose].
///   Requirements: 14.3
class VibrantBottomNav extends StatefulWidget {
  const VibrantBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  }) : assert(items.length > 0, 'items must not be empty');

  /// Navigation destinations. Typically 3 items.
  final List<BottomNavItem> items;

  /// Index of the currently active tab.
  final int currentIndex;

  /// Called when the user taps a tab with the tapped index.
  final ValueChanged<int> onTap;

  @override
  State<VibrantBottomNav> createState() => _VibrantBottomNavState();
}

class _VibrantBottomNavState extends State<VibrantBottomNav>
    with TickerProviderStateMixin {
  // ── Indicator spring controller ────────────────────────────────────────────

  /// Drives the horizontal position of the pill indicator.
  ///
  /// The value is the **pixel offset from the left edge** of the nav bar.
  /// It is initialised lazily once we have layout information the first time.
  late final AnimationController _indicatorCtrl;

  /// Whether [_indicatorCtrl] has been seeded with an initial pixel position.
  bool _indicatorInitialised = false;

  // ── Per-tab scale controllers ──────────────────────────────────────────────

  /// One [AnimationController] per tab for the 1.0 → 1.15 → 1.0 scale bounce.
  late final List<AnimationController> _scaleCtrl;

  /// Animations derived from [_scaleCtrl] using [Curves.easeOutBack].
  late final List<Animation<double>> _scaleAnim;

  // ── Spring parameters ─────────────────────────────────────────────────────

  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 20,
  );

  @override
  void initState() {
    super.initState();

    // Indicator controller — upper bound is deliberately huge; the real
    // [upper] does not matter because we drive it with [animateWith].
    _indicatorCtrl = AnimationController.unbounded(vsync: this);

    // Per-tab scale controllers: 250 ms, easeOutBack.
    _scaleCtrl = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      ),
    );

    _scaleAnim = _scaleCtrl.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 50,
        ),
      ]).animate(ctrl);
    }).toList();
  }

  @override
  void dispose() {
    _indicatorCtrl.dispose();
    for (final ctrl in _scaleCtrl) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Tab-tap handler ────────────────────────────────────────────────────────

  void _onTabTap(int index, double tabWidth) {
    if (index == widget.currentIndex) return;

    final motionOff = MotionPreference.disabled(context);

    // 1. Haptic — always fires regardless of motion preference (Req 13.4).
    HapticController.selection();

    // 2. Indicator movement.
    final double targetX = index * tabWidth;
    if (motionOff) {
      // Instant jump — no spring.
      _indicatorCtrl.value = targetX;
    } else {
      final double fromX = _indicatorCtrl.value;
      const double initialVelocity = 0.0;
      _indicatorCtrl.animateWith(
        SpringSimulation(_spring, fromX, targetX, initialVelocity),
      );
    }

    // 3. Scale animation on the newly tapped icon.
    if (!motionOff) {
      _scaleCtrl[index]
        ..reset()
        ..forward();
    }

    // 4. Notify parent.
    widget.onTap(index);
  }

  // ── Indicator initialisation helper ──────────────────────────────────────

  /// Seeds the indicator position once we know the tab width.
  void _initialiseIndicator(double tabWidth) {
    if (_indicatorInitialised) return;
    _indicatorInitialised = true;
    // Jump to starting position without animation.
    _indicatorCtrl.value = widget.currentIndex * tabWidth;
  }

  // ── didUpdateWidget — respond to parent-driven index changes ──────────────

  @override
  void didUpdateWidget(VibrantBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Parent changed the index externally (e.g. deep-link). Use the last
      // known tab width if available; otherwise the indicator will snap on the
      // next build.
      if (_indicatorInitialised && _lastTabWidth != null) {
        _onIndicatorMoveTo(widget.currentIndex, _lastTabWidth!);
      }
    }
  }

  double? _lastTabWidth;

  /// Moves the indicator to [index] × [tabWidth]. Used for external index
  /// changes where we should not fire haptic or scale.
  void _onIndicatorMoveTo(int index, double tabWidth) {
    final motionOff = MotionPreference.disabled(context);
    final double targetX = index * tabWidth;
    if (motionOff) {
      _indicatorCtrl.value = targetX;
    } else {
      _indicatorCtrl.animateWith(
        SpringSimulation(_spring, _indicatorCtrl.value, targetX, 0.0),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double tabWidth = totalWidth / widget.items.length;

        // Cache for didUpdateWidget.
        _lastTabWidth = tabWidth;

        // Seed indicator position once.
        _initialiseIndicator(tabWidth);

        return Material(
          color: colorScheme.surface,
          elevation: 0,
          child: SizedBox(
            height: 72,
            child: Stack(
              children: [
                // ── Pill indicator layer ──────────────────────────────────
                AnimatedBuilder(
                  animation: _indicatorCtrl,
                  builder: (context, _) {
                    return Positioned(
                      left: _indicatorCtrl.value,
                      bottom: 8,
                      width: tabWidth,
                      height: 3,
                      child: Center(
                        child: Container(
                          width: tabWidth * 0.4,
                          height: 3,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ── Tab items layer ───────────────────────────────────────
                Row(
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final bool isSelected = index == widget.currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onTabTap(index, tabWidth),
                        child: Semantics(
                          label: item.label,
                          selected: isSelected,
                          button: true,
                          child: _TabItem(
                            icon: item.icon,
                            selectedIcon: item.selectedIcon,
                            label: item.label,
                            isSelected: isSelected,
                            scaleAnimation: _scaleAnim[index],
                            activeColor: colorScheme.primary,
                            inactiveColor: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Stateless widget that renders a single tab destination.
///
/// Displays the icon (with scale animation when selected) and the text label.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.scaleAnimation,
    required this.activeColor,
    required this.inactiveColor,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Animation<double> scaleAnimation;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final iconData = isSelected ? selectedIcon : icon;
    final iconColor = isSelected ? activeColor : inactiveColor;
    final labelColor = isSelected ? activeColor : inactiveColor;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with scale animation.
        AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleAnimation.value,
              child: child,
            );
          },
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        const SizedBox(height: 4),
        // Label text.
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: labelColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
