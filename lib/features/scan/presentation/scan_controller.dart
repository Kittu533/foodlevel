import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../data/nutrition_repository.dart';
import '../data/prediction_repository.dart';
import '../domain/analysis_record.dart';
import 'scan_state.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  Future<AnalysisRecord?> pickAndAnalyze(ImageSource source) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final picker = ref.read(imagePickerProvider);
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );

      if (image == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }

      return analyzeImagePath(image.path);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membuka kamera atau galeri. Coba lagi ya.',
      );
      return null;
    }
  }

  Future<AnalysisRecord?> analyzeImagePath(String imagePath) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final predictions = await ref
          .read(predictionRepositoryProvider)
          .predictImage(imagePath);
      final topPrediction = predictions.firstOrNull;

      if (topPrediction == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Belum ada prediksi yang bisa ditampilkan.',
        );
        return null;
      }

      final nutritionItem = ref
          .read(nutritionRepositoryProvider)
          .findBySlug(topPrediction.slug);

      if (nutritionItem == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Data nutrisi untuk ${topPrediction.label} belum ada.',
        );
        return null;
      }

      final record = AnalysisRecord(
        id: const Uuid().v4(),
        imagePath: imagePath,
        predictions: predictions,
        nutritionItem: nutritionItem,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(isLoading: false, latestRecord: record);
      return record;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Analisis gagal. Coba pakai foto lain.',
      );
      return null;
    }
  }
}
