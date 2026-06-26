import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_stats.dart';
import '../repositories/content_repository.dart';
import '../repositories/practice_history_repository.dart';
import '../services/api_exception.dart';

class ProfileProvider extends ChangeNotifier {
  final ContentRepository _repository;
  final PracticeHistoryRepository _historyRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserStats? _baselineStats;
  UserStats? _userStats;

  ProfileProvider({
    required ContentRepository repository,
    required PracticeHistoryRepository historyRepository,
  }) : _repository = repository,
       _historyRepository = historyRepository {
    _historyRepository.addListener(_handleHistoryChanged);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserStats? get userStats => _userStats;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _baselineStats = await _repository.fetchUserStats();
      await _refreshMergedStats(notify: false);
    } catch (error) {
      _errorMessage = _buildErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  void _handleHistoryChanged() {
    unawaited(_refreshMergedStats());
  }

  Future<void> _refreshMergedStats({bool notify = true}) async {
    final baselineStats = _baselineStats;
    if (baselineStats == null) {
      return;
    }

    try {
      final localSummary = await _historyRepository.fetchSummary();
      _userStats = localSummary.mergeWith(baselineStats);
    } catch (error) {
      debugPrint('Local practice stats load failed: $error');
      _userStats = baselineStats;
    }

    if (notify) {
      notifyListeners();
    }
  }

  String _buildErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '个人统计加载失败，请稍后重试';
  }

  @override
  void dispose() {
    _historyRepository.removeListener(_handleHistoryChanged);
    super.dispose();
  }
}
