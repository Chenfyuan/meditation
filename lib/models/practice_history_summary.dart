import 'practice_session_record.dart';
import 'user_stats.dart';

class PracticeHistorySummary {
  final int streakDays;
  final int totalMinutes;
  final int totalSessions;
  final int weeklyCompleted;
  final List<int> weeklyMinutes;

  const PracticeHistorySummary({
    required this.streakDays,
    required this.totalMinutes,
    required this.totalSessions,
    required this.weeklyCompleted,
    required this.weeklyMinutes,
  });

  factory PracticeHistorySummary.empty() {
    return const PracticeHistorySummary(
      streakDays: 0,
      totalMinutes: 0,
      totalSessions: 0,
      weeklyCompleted: 0,
      weeklyMinutes: [0, 0, 0, 0, 0, 0, 0],
    );
  }

  factory PracticeHistorySummary.fromRecords(
    List<PracticeSessionRecord> records, {
    DateTime? now,
  }) {
    if (records.isEmpty) {
      return PracticeHistorySummary.empty();
    }

    final referenceDate = now ?? DateTime.now();
    final weekStart = _startOfWeek(referenceDate);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weeklyMinutes = List<int>.filled(7, 0);
    var weeklyCompleted = 0;
    var totalMinutes = 0;

    for (final record in records) {
      totalMinutes += record.listenedMinutes;

      if (!record.completedAt.isBefore(weekStart) &&
          record.completedAt.isBefore(weekEnd)) {
        final dayIndex = record.completedAt.difference(weekStart).inDays;
        if (dayIndex >= 0 && dayIndex < 7) {
          weeklyMinutes[dayIndex] += record.listenedMinutes;
          weeklyCompleted += 1;
        }
      }
    }

    return PracticeHistorySummary(
      streakDays: _deriveStreakDays(records, referenceDate),
      totalMinutes: totalMinutes,
      totalSessions: records.length,
      weeklyCompleted: weeklyCompleted,
      weeklyMinutes: List<int>.unmodifiable(weeklyMinutes),
    );
  }

  UserStats mergeWith(UserStats baseline) {
    return UserStats(
      streakDays: baseline.streakDays > streakDays
          ? baseline.streakDays
          : streakDays,
      totalMinutes: baseline.totalMinutes + totalMinutes,
      totalSessions: baseline.totalSessions + totalSessions,
      weeklyCompleted: baseline.weeklyCompleted + weeklyCompleted,
      weeklyMinutes: List<int>.unmodifiable(
        List<int>.generate(7, (index) {
          final baselineValue = index < baseline.weeklyMinutes.length
              ? baseline.weeklyMinutes[index]
              : 0;
          final localValue = index < weeklyMinutes.length
              ? weeklyMinutes[index]
              : 0;
          return baselineValue + localValue;
        }),
      ),
    );
  }
}

DateTime _startOfWeek(DateTime date) {
  final startOfDay = DateTime(date.year, date.month, date.day);
  return startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
}

int _deriveStreakDays(List<PracticeSessionRecord> records, DateTime now) {
  final practiceDays = records.map((record) {
    final completedAt = record.completedAt;
    return DateTime(completedAt.year, completedAt.month, completedAt.day);
  }).toSet();

  if (practiceDays.isEmpty) {
    return 0;
  }

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  var cursor = practiceDays.contains(today) ? today : yesterday;

  if (!practiceDays.contains(cursor)) {
    return 0;
  }

  var streak = 0;
  while (practiceDays.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}
