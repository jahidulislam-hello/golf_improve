/// One swing the golfer can pick for POST `/swing/compare`.
class CompareSwingOption {
  const CompareSwingOption({
    required this.id,
    required this.label,
    this.videoUrl = '',
    this.thumbnailUrl = '',
    this.clubType = '',
    this.cameraAngle = '',
  });

  final String id;
  final String label;
  final String videoUrl;
  final String thumbnailUrl;
  final String clubType;
  final String cameraAngle;

  factory CompareSwingOption.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final club = (json['clubType'] ?? 'Swing').toString();
    final angle = (json['cameraAngle'] ?? '').toString();
    final label = angle.trim().isEmpty ? club : '$club · $angle';
    return CompareSwingOption(
      id: id,
      label: label,
      videoUrl: (json['videoUrl'] ?? '').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      clubType: club,
      cameraAngle: angle,
    );
  }
}

class ComparedSwing {
  const ComparedSwing({
    required this.id,
    this.videoUrl = '',
    this.thumbnailUrl = '',
    this.clubType = '',
    this.cameraAngle = '',
    this.duration,
    this.overallScore,
  });

  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String clubType;
  final String cameraAngle;
  final double? duration;
  final num? overallScore;

  String get label {
    final angle = cameraAngle.trim();
    if (clubType.trim().isEmpty) return angle;
    if (angle.isEmpty) return clubType;
    return '$clubType · $angle';
  }

  factory ComparedSwing.fromJson(Map<String, dynamic> json) {
    final durationRaw = json['duration'];
    final scoreRaw = json['overallScore'];
    return ComparedSwing(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      videoUrl: (json['videoUrl'] ?? '').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      clubType: (json['clubType'] ?? '').toString(),
      cameraAngle: (json['cameraAngle'] ?? '').toString(),
      duration: durationRaw is num ? durationRaw.toDouble() : null,
      overallScore: scoreRaw is num ? scoreRaw : num.tryParse('$scoreRaw'),
    );
  }
}

class ScoreComparison {
  const ScoreComparison({
    this.scoreA,
    this.scoreB,
    this.diff,
    this.status = '',
    this.percentageChange,
  });

  final num? scoreA;
  final num? scoreB;
  final num? diff;
  final String status;
  final num? percentageChange;

  factory ScoreComparison.fromJson(Map<String, dynamic> json) {
    return ScoreComparison(
      scoreA: _num(json['scoreA']),
      scoreB: _num(json['scoreB']),
      diff: _num(json['diff']),
      status: (json['status'] ?? '').toString(),
      percentageChange: _num(json['percentageChange']),
    );
  }
}

class TempoSpan {
  const TempoSpan({this.swingA, this.swingB, this.diffMs});

  final num? swingA;
  final num? swingB;
  final num? diffMs;

  factory TempoSpan.fromJson(Map<String, dynamic> json) {
    return TempoSpan(
      swingA: _num(json['swingA']),
      swingB: _num(json['swingB']),
      diffMs: _num(json['diffMs']),
    );
  }
}

class TempoComparison {
  const TempoComparison({
    this.tempoA,
    this.tempoB,
    this.diff,
    this.idealRatio,
    this.status = '',
    this.backswingMs,
    this.downswingMs,
    this.followThroughMs,
  });

  final num? tempoA;
  final num? tempoB;
  final num? diff;
  final num? idealRatio;
  final String status;
  final TempoSpan? backswingMs;
  final TempoSpan? downswingMs;
  final TempoSpan? followThroughMs;

  factory TempoComparison.fromJson(Map<String, dynamic> json) {
    return TempoComparison(
      tempoA: _num(json['tempoA']),
      tempoB: _num(json['tempoB']),
      diff: _num(json['diff']),
      idealRatio: _num(json['idealRatio']),
      status: (json['status'] ?? '').toString(),
      backswingMs: _span(json['backswingMs']),
      downswingMs: _span(json['downswingMs']),
      followThroughMs: _span(json['followThroughMs']),
    );
  }
}

class MetricComparison {
  const MetricComparison({
    required this.key,
    required this.title,
    this.valueA = '',
    this.statusA = '',
    this.valueB = '',
    this.statusB = '',
    this.difference = '',
    this.improvement = '',
    this.target = '',
  });

  final String key;
  final String title;
  final String valueA;
  final String statusA;
  final String valueB;
  final String statusB;
  final String difference;
  final String improvement;
  final String target;

  factory MetricComparison.fromJson(Map<String, dynamic> json) {
    return MetricComparison(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? json['key'] ?? 'Metric').toString(),
      valueA: (json['valueA'] ?? '').toString(),
      statusA: (json['statusA'] ?? '').toString(),
      valueB: (json['valueB'] ?? '').toString(),
      statusB: (json['statusB'] ?? '').toString(),
      difference: (json['difference'] ?? '').toString(),
      improvement: (json['improvement'] ?? '').toString(),
      target: (json['target'] ?? '').toString(),
    );
  }
}

class SwingComparisonResult {
  const SwingComparisonResult({
    required this.swingA,
    required this.swingB,
    this.score,
    this.tempo,
    this.metrics = const [],
    this.summary = '',
    this.impactOffsetMs,
  });

  final ComparedSwing swingA;
  final ComparedSwing swingB;
  final ScoreComparison? score;
  final TempoComparison? tempo;
  final List<MetricComparison> metrics;
  final String summary;
  final num? impactOffsetMs;

  factory SwingComparisonResult.fromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final root = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : response);
    final comparison = root['comparison'];
    final comparisonMap = comparison is Map
        ? Map<String, dynamic>.from(comparison)
        : <String, dynamic>{};
    final metricsRaw = comparisonMap['metricComparisons'];
    final sync = comparisonMap['syncKeyframes'];
    final syncMap =
        sync is Map ? Map<String, dynamic>.from(sync) : <String, dynamic>{};

    return SwingComparisonResult(
      swingA: ComparedSwing.fromJson(_map(root['swingA'])),
      swingB: ComparedSwing.fromJson(_map(root['swingB'])),
      score: comparisonMap['scoreComparison'] is Map
          ? ScoreComparison.fromJson(_map(comparisonMap['scoreComparison']))
          : null,
      tempo: comparisonMap['tempoComparison'] is Map
          ? TempoComparison.fromJson(_map(comparisonMap['tempoComparison']))
          : null,
      metrics: metricsRaw is List
          ? metricsRaw
              .whereType<Map>()
              .map((e) => MetricComparison.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      summary: (comparisonMap['summary'] ?? '').toString(),
      impactOffsetMs: _num(syncMap['impactOffsetMs']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

num? _num(dynamic value) {
  if (value is num) return value;
  return num.tryParse('${value ?? ''}');
}

TempoSpan? _span(dynamic value) {
  if (value is! Map) return null;
  return TempoSpan.fromJson(Map<String, dynamic>.from(value));
}
