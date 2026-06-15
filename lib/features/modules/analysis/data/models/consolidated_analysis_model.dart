class ConsolidatedAnalysisModel {
  const ConsolidatedAnalysisModel({
    required this.financialIndicators,
    required this.incoherences,
    required this.narrativeReport,
    required this.incoherencesReviewed,
    required this.raw,
  });

  factory ConsolidatedAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ConsolidatedAnalysisModel(
      financialIndicators: _readMap(json, const [
        'financialIndicators',
        'indicators',
        'kpis',
      ]),
      incoherences: _readList(json, const [
        'incoherences',
        'warnings',
        'alerts',
      ]),
      narrativeReport: _readMap(json, const [
        'narrativeReport',
        'report',
        'narrative',
      ]),
      incoherencesReviewed: _readReviewed(json),
      raw: Map<String, dynamic>.from(json),
    );
  }

  final Map<String, dynamic> financialIndicators;
  final List<Map<String, dynamic>> incoherences;
  final Map<String, dynamic> narrativeReport;
  final bool incoherencesReviewed;
  final Map<String, dynamic> raw;

  bool get hasIndicators => financialIndicators.isNotEmpty;

  bool get hasNarrative => narrativeReport.values.any(
        (value) => value != null && value.toString().trim().isNotEmpty,
      );

  bool get canComplete => hasIndicators && hasNarrative && incoherencesReviewed;

  static Map<String, dynamic> _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static List<Map<String, dynamic>> _readList(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  static bool _readReviewed(Map<String, dynamic> source) {
    for (final key in [
      'incoherencesReviewed',
      'incoherenceReviewCompleted',
      'reviewedIncoherences',
    ]) {
      final value = source[key];
      if (value is bool) return value;
      if (value is String) return value.trim().toLowerCase() == 'true';
    }

    return source['incoherenceReview'] != null ||
        source['incoherencesReview'] != null;
  }
}
