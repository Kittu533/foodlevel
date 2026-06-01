/// Reference maximums for nutrition metrics used to compute display ratios.
///
/// These values represent the upper bounds for a single-meal portion,
/// used by [AnimatedNutritionBar] to normalise raw nutrient values into
/// a 0.0–1.0 range (Requirement 6.2).
abstract final class MetricMaxReference {
  /// Maximum reference calories per meal (kcal).
  static const double calories = 700.0;

  /// Maximum reference sugar per meal (grams).
  static const double sugarGram = 25.0;

  /// Maximum reference sodium per meal (milligrams).
  static const double sodiumMg = 1500.0;

  /// Maximum reference fat per meal (grams).
  static const double fatGram = 25.0;

  /// Maximum reference protein per meal (grams).
  static const double proteinGram = 30.0;

  /// Maximum reference carbohydrates per meal (grams).
  static const double carbsGram = 80.0;

  /// Returns [value] divided by [max], clamped to [0.0, 1.0].
  ///
  /// Example:
  /// ```dart
  /// MetricMaxReference.ratio(350, MetricMaxReference.calories); // 0.5
  /// MetricMaxReference.ratio(900, MetricMaxReference.calories); // 1.0
  /// ```
  static double ratio(double value, double max) =>
      (value / max).clamp(0.0, 1.0);
}
