class UserStats {
  final int streakDays;
  final int totalMinutes;
  final int totalSessions;
  final int weeklyCompleted;
  final List<int> weeklyMinutes;

  const UserStats({
    required this.streakDays,
    required this.totalMinutes,
    required this.totalSessions,
    required this.weeklyCompleted,
    required this.weeklyMinutes,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streakDays: _readInt(json['streakDays']),
      totalMinutes: _readInt(json['totalMinutes']),
      totalSessions: _readInt(json['totalSessions']),
      weeklyCompleted: _readInt(json['weeklyCompleted']),
      weeklyMinutes: _normalizeWeeklyMinutes(json['weeklyMinutes'] as List?),
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

List<int> _normalizeWeeklyMinutes(List? values) {
  final normalized = (values ?? const [])
      .map(_readInt)
      .take(7)
      .toList(growable: true);

  while (normalized.length < 7) {
    normalized.add(0);
  }

  return List<int>.unmodifiable(normalized);
}
