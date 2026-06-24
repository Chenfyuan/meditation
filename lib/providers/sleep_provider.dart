import 'package:flutter/material.dart';

import '../models/sleep_content.dart';
import '../repositories/content_repository.dart';
import '../services/api_exception.dart';

class SleepProvider extends ChangeNotifier {
  final ContentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  SleepContent? _sleepContent;

  SleepProvider({required ContentRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SleepContent? get sleepContent => _sleepContent;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sleepContent = await _repository.fetchSleepContent();
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
    return '睡眠内容加载失败，请稍后重试';
  }
}
