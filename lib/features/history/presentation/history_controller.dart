import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scan/domain/analysis_record.dart';

final historyControllerProvider =
    NotifierProvider<HistoryController, List<AnalysisRecord>>(
      HistoryController.new,
    );

class HistoryController extends Notifier<List<AnalysisRecord>> {
  @override
  List<AnalysisRecord> build() => const [];

  void addRecord(AnalysisRecord record) {
    final alreadySaved = state.any((item) => item.id == record.id);
    if (alreadySaved) {
      return;
    }

    state = [record, ...state];
  }

  void clear() {
    state = const [];
  }
}
