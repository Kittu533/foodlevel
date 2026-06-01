import 'package:flutter/material.dart';

import '../../../../core/theme/animation_budget.dart';
import '../../../../shared/widgets/animated_nutrition_bar.dart';
import 'metric_max_reference.dart';

/// A metric display tile that shows an icon, numeric value, label, and an
/// animated bar representing the value relative to a reference maximum.
///
/// Internally uses [AnimatedNutritionBar] so the bar fill animates from
/// 0 → [valueRatio] on mount, respecting [MotionPreference].
///
/// Requirements: 6.1, 6.2, 13.2, 13.3
class NutritionMetricTile extends StatelessWidget {
  const NutritionMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.rawValue,
    required this.maxReference,
    this.delay = Duration.zero,
    super.key,
  });

  /// Human-readable label, e.g. "Kalori".
  final String label;

  /// Formatted display string, e.g. "350 kkal".
  final String value;

  /// Icon to show at the top of the tile.
  final IconData icon;

  /// Raw numeric value (unformatted) used to compute the bar ratio.
  final double rawValue;

  /// Reference maximum from [MetricMaxReference] for ratio calculation.
  final double maxReference;

  /// Delay before the bar fill animation starts (for stagger effects).
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = MetricMaxReference.ratio(rawValue, maxReference);

    // Bar color: use secondary for high values, primary otherwise.
    final Color barColor = ratio >= 0.8
        ? colorScheme.error
        : ratio >= 0.6
            ? colorScheme.secondary
            : colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            // Animated bar showing ratio relative to reference max.
            AnimatedNutritionBar(
              label: '',
              valueRatio: ratio,
              color: barColor,
              duration: AnimationBudget.nutritionBar,
              delay: delay,
            ),
          ],
        ),
      ),
    );
  }
}
