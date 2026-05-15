import '../domain/analysis_record.dart';

class ScanState {
  const ScanState({
    this.isLoading = false,
    this.errorMessage,
    this.latestRecord,
  });

  final bool isLoading;
  final String? errorMessage;
  final AnalysisRecord? latestRecord;

  ScanState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    AnalysisRecord? latestRecord,
  }) {
    return ScanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      latestRecord: latestRecord ?? this.latestRecord,
    );
  }
}
