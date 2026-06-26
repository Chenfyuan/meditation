import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_history_summary.dart';
import '../models/practice_session_record.dart';

abstract class PracticeHistoryRepository extends ChangeNotifier {
  Future<List<PracticeSessionRecord>> fetchRecords();

  Future<void> addRecord(PracticeSessionRecord record);

  Future<PracticeHistorySummary> fetchSummary({DateTime? now}) async {
    final records = await fetchRecords();
    return PracticeHistorySummary.fromRecords(records, now: now);
  }
}

class SharedPreferencesPracticeHistoryRepository
    extends PracticeHistoryRepository {
  static const _recordsKey = 'practice_history_records_v1';
  static const _maxRecords = 20;

  @override
  Future<List<PracticeSessionRecord>> fetchRecords() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedRecords = preferences.getStringList(_recordsKey) ?? const [];

    return encodedRecords
        .map(_decodeRecord)
        .whereType<PracticeSessionRecord>()
        .toList(growable: false);
  }

  @override
  Future<void> addRecord(PracticeSessionRecord record) async {
    final preferences = await SharedPreferences.getInstance();
    final records = [record, ...await fetchRecords()].take(_maxRecords);
    final encodedRecords = records
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);

    await preferences.setStringList(_recordsKey, encodedRecords);
    notifyListeners();
  }

  PracticeSessionRecord? _decodeRecord(String encodedRecord) {
    try {
      final json = jsonDecode(encodedRecord);
      if (json is! Map) {
        return null;
      }
      final record = PracticeSessionRecord.fromJson(
        Map<String, dynamic>.from(json),
      );

      if (record.id.isEmpty ||
          record.title.isEmpty ||
          record.listenedSeconds <= 0 ||
          record.completedAt.millisecondsSinceEpoch == 0) {
        return null;
      }

      return record;
    } catch (error) {
      debugPrint('Practice history record decode failed: $error');
      return null;
    }
  }
}

class InMemoryPracticeHistoryRepository extends PracticeHistoryRepository {
  final List<PracticeSessionRecord> _records;

  InMemoryPracticeHistoryRepository({
    List<PracticeSessionRecord> records = const [],
  }) : _records = List<PracticeSessionRecord>.from(records);

  @override
  Future<List<PracticeSessionRecord>> fetchRecords() async {
    return List<PracticeSessionRecord>.unmodifiable(_records);
  }

  @override
  Future<void> addRecord(PracticeSessionRecord record) async {
    _records.insert(0, record);
    if (_records.length > 20) {
      _records.removeRange(20, _records.length);
    }
    notifyListeners();
  }
}
