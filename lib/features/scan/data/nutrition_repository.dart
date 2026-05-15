import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/nutrition_item.dart';
import '../domain/nutrition_level.dart';

abstract class NutritionRepository {
  List<NutritionItem> get items;

  NutritionItem? findBySlug(String slug);
}

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return LocalNutritionRepository();
});

class LocalNutritionRepository implements NutritionRepository {
  LocalNutritionRepository();

  static const List<NutritionItem> _items = [
    NutritionItem(
      name: 'Air Mineral',
      slug: 'air_mineral',
      category: 'Minuman',
      servingSize: '330 ml',
      calories: 0,
      sugarGram: 0,
      sodiumMg: 5,
      fatGram: 0,
      proteinGram: 0,
      carbsGram: 0,
      level: NutritionLevel.a,
    ),
    NutritionItem(
      name: 'Es Teh Manis',
      slug: 'es_teh_manis',
      category: 'Minuman',
      servingSize: '300 ml',
      calories: 120,
      sugarGram: 25,
      sodiumMg: 10,
      fatGram: 0,
      proteinGram: 0,
      carbsGram: 30,
      level: NutritionLevel.d,
    ),
    NutritionItem(
      name: 'Kopi Susu',
      slug: 'kopi_susu',
      category: 'Minuman',
      servingSize: '250 ml',
      calories: 180,
      sugarGram: 22,
      sodiumMg: 90,
      fatGram: 6,
      proteinGram: 5,
      carbsGram: 28,
      level: NutritionLevel.d,
    ),
    NutritionItem(
      name: 'Nasi Putih',
      slug: 'nasi_putih',
      category: 'Makanan',
      servingSize: '1 porsi',
      calories: 260,
      sugarGram: 0.2,
      sodiumMg: 2,
      fatGram: 0.4,
      proteinGram: 5,
      carbsGram: 57,
      level: NutritionLevel.b,
    ),
    NutritionItem(
      name: 'Nasi Goreng',
      slug: 'nasi_goreng',
      category: 'Makanan',
      servingSize: '1 porsi',
      calories: 520,
      sugarGram: 6,
      sodiumMg: 780,
      fatGram: 18,
      proteinGram: 16,
      carbsGram: 72,
      level: NutritionLevel.c,
    ),
    NutritionItem(
      name: 'Mie Goreng',
      slug: 'mie_goreng',
      category: 'Makanan',
      servingSize: '1 porsi',
      calories: 560,
      sugarGram: 7,
      sodiumMg: 920,
      fatGram: 21,
      proteinGram: 14,
      carbsGram: 78,
      level: NutritionLevel.d,
    ),
    NutritionItem(
      name: 'Ayam Geprek',
      slug: 'ayam_geprek',
      category: 'Makanan',
      servingSize: '1 porsi',
      calories: 610,
      sugarGram: 4,
      sodiumMg: 1100,
      fatGram: 28,
      proteinGram: 32,
      carbsGram: 58,
      level: NutritionLevel.d,
    ),
    NutritionItem(
      name: 'Bakso',
      slug: 'bakso',
      category: 'Makanan',
      servingSize: '1 mangkuk',
      calories: 380,
      sugarGram: 3,
      sodiumMg: 840,
      fatGram: 13,
      proteinGram: 22,
      carbsGram: 45,
      level: NutritionLevel.c,
    ),
    NutritionItem(
      name: 'Burger',
      slug: 'burger',
      category: 'Makanan',
      servingSize: '1 pcs',
      calories: 480,
      sugarGram: 9,
      sodiumMg: 760,
      fatGram: 22,
      proteinGram: 24,
      carbsGram: 46,
      level: NutritionLevel.c,
    ),
    NutritionItem(
      name: 'Salad',
      slug: 'salad',
      category: 'Makanan',
      servingSize: '1 bowl',
      calories: 180,
      sugarGram: 5,
      sodiumMg: 210,
      fatGram: 8,
      proteinGram: 7,
      carbsGram: 18,
      level: NutritionLevel.a,
    ),
  ];

  @override
  List<NutritionItem> get items => _items;

  @override
  NutritionItem? findBySlug(String slug) {
    for (final item in _items) {
      if (item.slug == slug) {
        return item;
      }
    }
    return null;
  }
}
