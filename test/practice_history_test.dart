import 'package:flutter_test/flutter_test.dart';
import 'package:meditation/models/practice_history_summary.dart';
import 'package:meditation/models/practice_session_record.dart';
import 'package:meditation/models/user_stats.dart';
import 'package:meditation/repositories/practice_history_repository.dart';

void main() {
  group('PracticeSessionRecord', () {
    test('round-trips through JSON', () {
      final completedAt = DateTime(2026, 6, 26, 21, 30);
      final record = PracticeSessionRecord(
        id: 'session-1',
        title: '海边的黄昏',
        subtitle: 'Sarah',
        durationSeconds: 600,
        listenedSeconds: 480,
        completedAt: completedAt,
        completionReason: PracticeCompletionReason.threshold,
        source: PracticeSource.meditation,
      );

      final decoded = PracticeSessionRecord.fromJson(record.toJson());

      expect(decoded.id, 'session-1');
      expect(decoded.title, '海边的黄昏');
      expect(decoded.subtitle, 'Sarah');
      expect(decoded.durationSeconds, 600);
      expect(decoded.listenedSeconds, 480);
      expect(decoded.completedAt, completedAt);
      expect(decoded.completionReason, PracticeCompletionReason.threshold);
      expect(decoded.source, PracticeSource.meditation);
    });
  });

  group('PracticeHistorySummary', () {
    test('summarizes local records into totals and weekly stats', () {
      final now = DateTime(2026, 6, 26, 12);
      final summary = PracticeHistorySummary.fromRecords([
        _record('today', now, 600),
        _record('yesterday', DateTime(2026, 6, 25, 8), 480),
        _record('tuesday', DateTime(2026, 6, 23, 9), 120),
        _record('older', DateTime(2026, 6, 10, 9), 300),
      ], now: now);

      expect(summary.totalMinutes, 25);
      expect(summary.totalSessions, 4);
      expect(summary.weeklyCompleted, 3);
      expect(summary.weeklyMinutes, [0, 2, 0, 8, 10, 0, 0]);
      expect(summary.streakDays, 2);
    });

    test('merges local stats with repository baseline stats', () {
      final baseline = const UserStats(
        streakDays: 7,
        totalMinutes: 120,
        totalSessions: 10,
        weeklyCompleted: 3,
        weeklyMinutes: [10, 0, 20, 0, 15, 0, 0],
      );
      final local = PracticeHistorySummary.fromRecords([
        _record('today', DateTime(2026, 6, 26, 12), 600),
        _record('yesterday', DateTime(2026, 6, 25, 8), 480),
      ], now: DateTime(2026, 6, 26, 12));

      final merged = local.mergeWith(baseline);

      expect(merged.streakDays, 7);
      expect(merged.totalMinutes, 138);
      expect(merged.totalSessions, 12);
      expect(merged.weeklyCompleted, 5);
      expect(merged.weeklyMinutes, [10, 0, 20, 8, 25, 0, 0]);
    });
  });

  group('InMemoryPracticeHistoryRepository', () {
    test('keeps the most recent 20 records', () async {
      final repository = InMemoryPracticeHistoryRepository();

      for (var index = 0; index < 25; index += 1) {
        await repository.addRecord(
          _record('record-$index', DateTime(2026, 6, 26, 12, index), 60),
        );
      }

      final records = await repository.fetchRecords();

      expect(records.length, 20);
      expect(records.first.id, 'record-24');
      expect(records.last.id, 'record-5');
    });
  });
}

PracticeSessionRecord _record(
  String id,
  DateTime completedAt,
  int listenedSeconds,
) {
  return PracticeSessionRecord(
    id: id,
    title: '练习 $id',
    subtitle: '静',
    durationSeconds: 600,
    listenedSeconds: listenedSeconds,
    completedAt: completedAt,
    completionReason: PracticeCompletionReason.finished,
    source: PracticeSource.meditation,
  );
}
