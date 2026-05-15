import 'package:flutter_test/flutter_test.dart';
import 'package:foodlevel/features/scan/data/nutrition_repository.dart';
import 'package:foodlevel/features/scan/data/prediction_repository.dart';
import 'package:foodlevel/features/scan/domain/nutrition_level.dart';

void main() {
  test('mock prediction returns top 3 labels', () async {
    const repository = MockPredictionRepository();

    final predictions = await repository.predictImage('/tmp/food.jpg');

    expect(predictions, hasLength(3));
    expect(predictions.first.slug, 'nasi_goreng');
    expect(predictions.first.confidence, greaterThan(0.7));
  });

  test('nutrition lookup returns item by slug', () {
    final repository = LocalNutritionRepository();

    final item = repository.findBySlug('es_teh_manis');

    expect(item, isNotNull);
    expect(item!.name, 'Es Teh Manis');
    expect(item.level, NutritionLevel.d);
  });
}
