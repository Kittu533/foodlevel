import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scan/domain/analysis_record.dart';
import '../../scan/domain/nutrition_level.dart';
import '../data/history_repository.dart';

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);

class HistoryState {
  const HistoryState({
    this.records = const [],
    this.isLoading = false,
    this.query = '',
    this.levelFilter,
  });

  final List<AnalysisRecord> records;
  final bool isLoading;
  final String query;
  final NutritionLevel? levelFilter;

  List<AnalysisRecord> get visibleRecords {
    return records.where((record) {
      final matchesQuery =
          query.trim().isEmpty ||
          record.nutritionItem.name.toLowerCase().contains(query.toLowerCase());
      final matchesLevel =
          levelFilter == null || record.nutritionItem.level == levelFilter;
      return matchesQuery && matchesLevel;
    }).toList();
  }

  HistoryState copyWith({
    List<AnalysisRecord>? records,
    bool? isLoading,
    String? query,
    NutritionLevel? levelFilter,
    bool clearLevelFilter = false,
  }) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      levelFilter: clearLevelFilter ? null : levelFilter ?? this.levelFilter,
    );
  }
}

class HistoryController extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    Future.microtask(_loadRecords);
    return const HistoryState(isLoading: true);
  }

  void addRecord(AnalysisRecord record) {
    final alreadySaved = state.records.any((item) => item.id == record.id);
    if (alreadySaved) {
      return;
    }

    final records = [record, ...state.records];
    state = state.copyWith(records: records);
    _persist(records);
  }

  void clear() {
    state = state.copyWith(records: const []);
    _persist(const []);
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setLevelFilter(NutritionLevel? level) {
    state = level == null
        ? state.copyWith(clearLevelFilter: true)
        : state.copyWith(levelFilter: level);
  }

  Future<void> _loadRecords() async {
    final records = await ref.read(historyRepositoryProvider).loadRecords();
    state = state.copyWith(
      records: state.records.isEmpty ? records : state.records,
      isLoading: false,
    );
  }

  Future<void> _persist(List<AnalysisRecord> records) {
    return ref.read(historyRepositoryProvider).saveRecords(records);
  }
}
