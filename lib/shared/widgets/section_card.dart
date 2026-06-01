import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.tone,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Optional border radius override. When null, the radius is read from
  /// [Theme.of(context).cardTheme.shape] if that shape is a
  /// [RoundedRectangleBorder]; otherwise defaults to [BorderRadius.circular(16)].
  final BorderRadius? borderRadius;

  /// Optional background color override. When null, falls back to
  /// [Theme.of(context).cardTheme.color] ?? [ColorScheme.surfaceContainerLow].
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Resolve border radius: explicit param → cardTheme shape → default 16dp
    final BorderRadius resolvedRadius;
    if (borderRadius != null) {
      resolvedRadius = borderRadius!;
    } else {
      final shape = cardTheme.shape;
      if (shape is RoundedRectangleBorder) {
        final br = shape.borderRadius;
        resolvedRadius =
            br is BorderRadius ? br : BorderRadius.circular(16);
      } else {
        resolvedRadius = BorderRadius.circular(16);
      }
    }

    // Resolve color: explicit param → cardTheme.color → surfaceContainerLow
    final Color resolvedColor =
        tone ?? cardTheme.color ?? colorScheme.surfaceContainerLow;

    // Resolve elevation: cardTheme.elevation → 0
    final double resolvedElevation = cardTheme.elevation ?? 0;

    return Card(
      elevation: resolvedElevation,
      color: resolvedColor,
      shape: RoundedRectangleBorder(borderRadius: resolvedRadius),
      child: Padding(padding: padding, child: child),
    );
  }
}
