import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/food_prediction.dart';

abstract class PredictionRepository {
  Future<List<FoodPrediction>> predictImage(String imagePath);
}

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return MockPredictionRepository();
});

class MockPredictionRepository implements PredictionRepository {
  const MockPredictionRepository();

  @override
  Future<List<FoodPrediction>> predictImage(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return const [
      FoodPrediction(
        label: 'Nasi Goreng',
        slug: 'nasi_goreng',
        confidence: 0.86,
      ),
      FoodPrediction(label: 'Mie Goreng', slug: 'mie_goreng', confidence: 0.08),
      FoodPrediction(label: 'Nasi Putih', slug: 'nasi_putih', confidence: 0.03),
    ];
  }
}
