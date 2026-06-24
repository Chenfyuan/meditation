class HomeData {
  final String dateText;
  final String greetingName;
  final String greetingLine;
  final HomeSession featuredSession;
  final ContinueSession? continueSession;
  final List<TopicSummary> topicSummaries;

  const HomeData({
    required this.dateText,
    required this.greetingName,
    required this.greetingLine,
    required this.featuredSession,
    required this.continueSession,
    required this.topicSummaries,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      dateText: json['dateText'] as String? ?? '',
      greetingName: json['greetingName'] as String? ?? '',
      greetingLine: json['greetingLine'] as String? ?? '',
      featuredSession: HomeSession.fromJson(
        Map<String, dynamic>.from(json['featuredSession'] as Map? ?? const {}),
      ),
      continueSession: json['continueSession'] is Map
          ? ContinueSession.fromJson(
              Map<String, dynamic>.from(json['continueSession'] as Map),
            )
          : null,
      topicSummaries: (json['topicSummaries'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => TopicSummary.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

class HomeSession {
  final String id;
  final String title;
  final String subtitle;
  final String instructor;
  final int durationMinutes;
  final String themeKey;

  const HomeSession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instructor,
    required this.durationMinutes,
    required this.themeKey,
  });

  factory HomeSession.fromJson(Map<String, dynamic> json) {
    return HomeSession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      durationMinutes: _readInt(json['durationMinutes']),
      themeKey: json['themeKey'] as String? ?? 'bronze',
    );
  }
}

class ContinueSession {
  final String id;
  final String title;
  final String instructor;
  final int durationMinutes;
  final int remainingSeconds;
  final String themeKey;

  const ContinueSession({
    required this.id,
    required this.title,
    required this.instructor,
    required this.durationMinutes,
    required this.remainingSeconds,
    required this.themeKey,
  });

  String get remainingLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '剩 ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory ContinueSession.fromJson(Map<String, dynamic> json) {
    return ContinueSession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      durationMinutes: _readInt(json['durationMinutes']),
      remainingSeconds: _readInt(json['remainingSeconds']),
      themeKey: json['themeKey'] as String? ?? 'sage',
    );
  }
}

class TopicSummary {
  final String name;
  final int sessionCount;
  final String themeKey;

  const TopicSummary({
    required this.name,
    required this.sessionCount,
    required this.themeKey,
  });

  factory TopicSummary.fromJson(Map<String, dynamic> json) {
    return TopicSummary(
      name: json['name'] as String? ?? '',
      sessionCount: _readInt(json['sessionCount']),
      themeKey: json['themeKey'] as String? ?? 'sand',
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
