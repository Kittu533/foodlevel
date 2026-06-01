import 'food_prediction.dart';
import 'nutrition_item.dart';

class AnalysisRecord {
  const AnalysisRecord({
    required this.id,
    required this.imagePath,
    required this.predictions,
    required this.nutritionItem,
    required this.createdAt,
    this.portionLabel = 'Normal',
    this.portionMultiplier = 1,
    this.wasCorrected = false,
  });

  final String id;
  final String imagePath;
  final List<FoodPrediction> predictions;
  final NutritionItem nutritionItem;
  final DateTime createdAt;
  final String portionLabel;
  final double portionMultiplier;
  final bool wasCorrected;

  FoodPrediction get topPrediction => predictions.first;

  bool get isLowConfidence => topPrediction.confidence < 0.7;

  AnalysisRecord copyWith({
    String? id,
    String? imagePath,
    List<FoodPrediction>? predictions,
    NutritionItem? nutritionItem,
    DateTime? createdAt,
    String? portionLabel,
    double? portionMultiplier,
    bool? wasCorrected,
  }) {
    return AnalysisRecord(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      predictions: predictions ?? this.predictions,
      nutritionItem: nutritionItem ?? this.nutritionItem,
      createdAt: createdAt ?? this.createdAt,
      portionLabel: portionLabel ?? this.portionLabel,
      portionMultiplier: portionMultiplier ?? this.portionMultiplier,
      wasCorrected: wasCorrected ?? this.wasCorrected,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'predictions': predictions
          .map((prediction) => prediction.toJson())
          .toList(),
      'nutritionItem': nutritionItem.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'portionLabel': portionLabel,
      'portionMultiplier': portionMultiplier,
      'wasCorrected': wasCorrected,
    };
  }

  factory AnalysisRecord.fromJson(Map<String, Object?> json) {
    return AnalysisRecord(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      predictions: (json['predictions'] as List<Object?>)
          .map((item) => FoodPrediction.fromJson(item! as Map<String, Object?>))
          .toList(),
      nutritionItem: NutritionItem.fromJson(
        json['nutritionItem']! as Map<String, Object?>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      portionLabel: json['portionLabel'] as String? ?? 'Normal',
      portionMultiplier: (json['portionMultiplier'] as num?)?.toDouble() ?? 1,
      wasCorrected: json['wasCorrected'] as bool? ?? false,
    );
  }
}
