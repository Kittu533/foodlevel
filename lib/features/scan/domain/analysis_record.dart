import 'food_prediction.dart';
import 'nutrition_item.dart';

class AnalysisRecord {
  const AnalysisRecord({
    required this.id,
    required this.imagePath,
    required this.predictions,
    required this.nutritionItem,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final List<FoodPrediction> predictions;
  final NutritionItem nutritionItem;
  final DateTime createdAt;

  FoodPrediction get topPrediction => predictions.first;

  bool get isLowConfidence => topPrediction.confidence < 0.7;
}
