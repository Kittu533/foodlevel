import 'package:flutter/material.dart';

import '../../../../shared/widgets/animated_nutrition_bar.dart';
import '../../../scan/domain/food_prediction.dart';

/// Displays a vertical list of food predictions with their confidence values.
///
/// Each row uses an [AnimatedNutritionBar]-style confidence bar that animates
/// in over 500ms with [Curves.easeOutCubic]. Rows are staggered at 60ms ×
/// index so they cascade in sequence on mount.
///
/// When [MotionPreference] is disabled, all bars render at their final values
/// immediately (handled internally by [AnimatedNutritionBar]).
///
/// Requirements: 6.6, 6.1, 13.2, 13.3
class PredictionConfidenceList extends StatelessWidget {
  const PredictionConfidenceList({required this.predictions, super.key});

  final List<FoodPrediction> predictions;

  /// Stagger gap between consecutive bars (60 ms × index).
  static const Duration _staggerStep = Duration(milliseconds: 60);

  /// Duration for each confidence bar fill animation.
  static const Duration _barDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (int i = 0; i < predictions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedNutritionBar(
              label: predictions[i].label,
              valueRatio: predictions[i].confidence,
              color: colorScheme.primary,
              duration: _barDuration,
              delay: _staggerStep * i,
              trailingText: _percent(predictions[i].confidence),
            ),
          ),
      ],
    );
  }

  String _percent(double value) => '${(value * 100).round()}%';
}
