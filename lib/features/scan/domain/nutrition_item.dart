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

  NutritionItem scaledBy(double multiplier, String servingLabel) {
    return NutritionItem(
      name: name,
      slug: slug,
      category: category,
      servingSize: servingLabel,
      calories: (calories * multiplier).round(),
      sugarGram: _roundOne(sugarGram * multiplier),
      sodiumMg: (sodiumMg * multiplier).round(),
      fatGram: _roundOne(fatGram * multiplier),
      proteinGram: _roundOne(proteinGram * multiplier),
      carbsGram: _roundOne(carbsGram * multiplier),
      level: level,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'slug': slug,
      'category': category,
      'servingSize': servingSize,
      'calories': calories,
      'sugarGram': sugarGram,
      'sodiumMg': sodiumMg,
      'fatGram': fatGram,
      'proteinGram': proteinGram,
      'carbsGram': carbsGram,
      'level': level.label,
    };
  }

  factory NutritionItem.fromJson(Map<String, Object?> json) {
    return NutritionItem(
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      servingSize: json['servingSize'] as String,
      calories: json['calories'] as int,
      sugarGram: (json['sugarGram'] as num).toDouble(),
      sodiumMg: json['sodiumMg'] as int,
      fatGram: (json['fatGram'] as num).toDouble(),
      proteinGram: (json['proteinGram'] as num).toDouble(),
      carbsGram: (json['carbsGram'] as num).toDouble(),
      level: NutritionLevel.fromLabel(json['level'] as String),
    );
  }

  static double _roundOne(double value) {
    return double.parse(value.toStringAsFixed(1));
  }
}
