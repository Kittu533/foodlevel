import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlevel/features/result/presentation/result_screen.dart';
import 'package:foodlevel/features/scan/data/nutrition_repository.dart';
import 'package:foodlevel/features/scan/domain/analysis_record.dart';
import 'package:foodlevel/features/scan/domain/food_prediction.dart';

void main() {
  testWidgets('result screen renders nutrition and predictions', (
    tester,
  ) async {
    final nutrition = LocalNutritionRepository().findBySlug('nasi_goreng')!;
    final record = AnalysisRecord(
      id: 'record-1',
      imagePath: '/tmp/food.jpg',
      predictions: const [
        FoodPrediction(
          label: 'Nasi Goreng',
          slug: 'nasi_goreng',
          confidence: 0.86,
        ),
        FoodPrediction(
          label: 'Mie Goreng',
          slug: 'mie_goreng',
          confidence: 0.08,
        ),
        FoodPrediction(
          label: 'Nasi Putih',
          slug: 'nasi_putih',
          confidence: 0.03,
        ),
      ],
      nutritionItem: nutrition,
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: ResultScreen(record: record)),
      ),
    );

    expect(find.text('Nasi Goreng'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Top prediksi'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Top prediksi'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('520 kkal'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('520 kkal'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Simpan ke History'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Simpan ke History'), findsOneWidget);
  });
}
