class FoodPrediction {
  const FoodPrediction({
    required this.label,
    required this.slug,
    required this.confidence,
  });

  final String label;
  final String slug;
  final double confidence;
}
