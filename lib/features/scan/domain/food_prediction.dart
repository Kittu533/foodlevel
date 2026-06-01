class FoodPrediction {
  const FoodPrediction({
    required this.label,
    required this.slug,
    required this.confidence,
  });

  final String label;
  final String slug;
  final double confidence;

  Map<String, Object?> toJson() {
    return {'label': label, 'slug': slug, 'confidence': confidence};
  }

  factory FoodPrediction.fromJson(Map<String, Object?> json) {
    return FoodPrediction(
      label: json['label'] as String,
      slug: json['slug'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
