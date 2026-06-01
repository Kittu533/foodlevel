import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../scan/domain/analysis_record.dart';

abstract class HistoryRepository {
  Future<List<AnalysisRecord>> loadRecords();

  Future<void> saveRecords(List<AnalysisRecord> records);
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return SharedPreferencesHistoryRepository();
});

class SharedPreferencesHistoryRepository implements HistoryRepository {
  static const _storageKey = 'foodlevel.analysis.history.v1';

  @override
  Future<List<AnalysisRecord>> loadRecords() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded.map((item) {
      return AnalysisRecord.fromJson(Map<String, Object?>.from(item! as Map));
    }).toList();
  }

  @override
  Future<void> saveRecords(List<AnalysisRecord> records) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await preferences.setString(_storageKey, encoded);
  }
}
