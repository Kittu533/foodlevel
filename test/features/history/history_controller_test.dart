import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlevel/features/history/data/history_repository.dart';
import 'package:foodlevel/features/history/presentation/history_controller.dart';
import 'package:foodlevel/features/scan/data/nutrition_repository.dart';
import 'package:foodlevel/features/scan/domain/analysis_record.dart';
import 'package:foodlevel/features/scan/domain/food_prediction.dart';

void main() {
  test('history provider can add record', () {
    final repository = _FakeHistoryRepository();
    final container = ProviderContainer(
      overrides: [historyRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

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
      ],
      nutritionItem: nutrition,
      createdAt: DateTime(2026),
    );

    container.read(historyControllerProvider.notifier).addRecord(record);

    expect(container.read(historyControllerProvider).records, [record]);
    expect(repository.savedRecords, [record]);
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  List<AnalysisRecord> savedRecords = const [];

  @override
  Future<List<AnalysisRecord>> loadRecords() async => const [];

  @override
  Future<void> saveRecords(List<AnalysisRecord> records) async {
    savedRecords = records;
  }
}
