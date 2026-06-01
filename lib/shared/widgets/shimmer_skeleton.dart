import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/motion_preference.dart';

/// Shape variant for [ShimmerSkeleton].
enum _SkeletonShape { line, box, circle }

/// A shimmer-animated loading placeholder.
///
/// Three named constructors are provided for common skeleton shapes:
/// - [ShimmerSkeleton.line] — a narrow horizontal bar (e.g. text placeholder).
/// - [ShimmerSkeleton.box]  — a rectangular area (e.g. image / card placeholder).
/// - [ShimmerSkeleton.circle] — a circular avatar/icon placeholder.
///
/// Colors are read from the ambient [ThemeData] so the skeleton always matches
/// the current color scheme:
/// - `baseColor`      = `colorScheme.surfaceContainerHighest`
/// - `highlightColor` = `colorScheme.surfaceContainerHigh` at 60 % opacity
///
/// When [MotionPreference.disabled] is `true` the widget renders a plain
/// [ColoredBox] (no [Shimmer] in the tree) in accordance with the user's
/// system-level reduce-motion preference.
///
/// Wrapped in a [RepaintBoundary] to isolate the continuous shimmer repaint
/// from the rest of the widget tree. (Requirements: 4.2, 13.2, 13.3, 14.5)
class ShimmerSkeleton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Named constructors
  // ---------------------------------------------------------------------------

  /// Creates a line skeleton — a narrow horizontal bar.
  ///
  /// Both [width] and [height] are required so that the layout is always
  /// deterministic. Supply a [borderRadius] to round the corners.
  const ShimmerSkeleton.line({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  })  : _shape = _SkeletonShape.line,
        size = null;

  /// Creates a rectangular box skeleton — useful for image / card placeholders.
  ///
  /// Both [width] and [height] are required. Supply a [borderRadius] to round
  /// the corners.
  const ShimmerSkeleton.box({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  })  : _shape = _SkeletonShape.box,
        size = null;

  /// Creates a circular skeleton — useful for avatar / icon placeholders.
  ///
  /// [size] controls both the width and height; defaults to `40`.
  const ShimmerSkeleton.circle({
    this.size = 40,
    super.key,
  })  : _shape = _SkeletonShape.circle,
        width = null,
        height = null,
        borderRadius = null;

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  final _SkeletonShape _shape;

  /// Width of the skeleton. Required for [line] and [box]; `null` for [circle].
  final double? width;

  /// Height of the skeleton. Required for [line] and [box]; `null` for [circle].
  final double? height;

  /// Diameter of the circle. Only used by [circle]; `null` for [line] and [box].
  final double? size;

  /// Corner radius. Applies to [line] and [box]; ignored for [circle].
  final BorderRadius? borderRadius;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double resolvedWidth;
    final double resolvedHeight;
    BorderRadius resolvedBorderRadius;

    switch (_shape) {
      case _SkeletonShape.line:
      case _SkeletonShape.box:
        resolvedWidth = width!;
        resolvedHeight = height!;
        resolvedBorderRadius = borderRadius ?? BorderRadius.zero;

      case _SkeletonShape.circle:
        final diameter = size ?? 40;
        resolvedWidth = diameter;
        resolvedHeight = diameter;
        resolvedBorderRadius = BorderRadius.circular(diameter / 2);
    }

    final baseColor = colorScheme.surfaceContainerHighest;

    // When the user has opted in to reduced motion, render a plain colored box
    // with no Shimmer widget in the tree at all.
    if (MotionPreference.disabled(context)) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: resolvedBorderRadius,
          child: ColoredBox(
            color: baseColor,
            child: SizedBox(width: resolvedWidth, height: resolvedHeight),
          ),
        ),
      );
    }

    final highlightColor =
        colorScheme.surfaceContainerHigh.withValues(alpha: 0.6);

    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ClipRRect(
          borderRadius: resolvedBorderRadius,
          child: ColoredBox(
            color: baseColor,
            child: SizedBox(width: resolvedWidth, height: resolvedHeight),
          ),
        ),
      ),
    );
  }
}
