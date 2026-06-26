enum PracticeCompletionReason { finished, threshold, sleepTimer }

enum PracticeSource { meditation, sleepStory, soundscape, unknown }

class PracticeSessionRecord {
  final String id;
  final String title;
  final String subtitle;
  final int durationSeconds;
  final int listenedSeconds;
  final DateTime completedAt;
  final PracticeCompletionReason completionReason;
  final PracticeSource source;

  const PracticeSessionRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
    required this.listenedSeconds,
    required this.completedAt,
    required this.completionReason,
    required this.source,
  });

  int get listenedMinutes =>
      listenedSeconds <= 0 ? 0 : (listenedSeconds / 60).ceil();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'durationSeconds': durationSeconds,
      'listenedSeconds': listenedSeconds,
      'completedAt': completedAt.toIso8601String(),
      'completionReason': completionReason.name,
      'source': source.name,
    };
  }

  factory PracticeSessionRecord.fromJson(Map<String, dynamic> json) {
    return PracticeSessionRecord(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      durationSeconds: _readInt(json['durationSeconds']),
      listenedSeconds: _readInt(json['listenedSeconds']),
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completionReason: _readCompletionReason(json['completionReason']),
      source: _readSource(json['source']),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

PracticeCompletionReason _readCompletionReason(dynamic value) {
  final name = value as String?;
  return PracticeCompletionReason.values.firstWhere(
    (reason) => reason.name == name,
    orElse: () => PracticeCompletionReason.threshold,
  );
}

PracticeSource _readSource(dynamic value) {
  final name = value as String?;
  return PracticeSource.values.firstWhere(
    (source) => source.name == name,
    orElse: () => PracticeSource.unknown,
  );
}
