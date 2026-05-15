import 'nutrition_level.dart';

class NutritionItem {
  const NutritionItem({
    required this.name,
    required this.slug,
    required this.category,
    required this.servingSize,
    required this.calories,
    required this.sugarGram,
    required this.sodiumMg,
    required this.fatGram,
    required this.proteinGram,
    required this.carbsGram,
    required this.level,
  });

  final String name;
  final String slug;
  final String category;
  final String servingSize;
  final int calories;
  final double sugarGram;
  final int sodiumMg;
  final double fatGram;
  final double proteinGram;
  final double carbsGram;
  final NutritionLevel level;
}
