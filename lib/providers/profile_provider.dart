import 'package:flutter/material.dart';

import '../models/user_stats.dart';
import '../repositories/content_repository.dart';
import '../services/api_exception.dart';

class ProfileProvider extends ChangeNotifier {
  final ContentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  UserStats? _userStats;

  ProfileProvider({required ContentRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserStats? get userStats => _userStats;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userStats = await _repository.fetchUserStats();
    } catch (error) {
      _errorMessage = _buildErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  String _buildErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '个人统计加载失败，请稍后重试';
  }
}
