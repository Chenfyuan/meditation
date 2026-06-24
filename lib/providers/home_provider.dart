import 'package:flutter/material.dart';

import '../models/home_data.dart';
import '../repositories/content_repository.dart';
import '../services/api_exception.dart';

class HomeProvider extends ChangeNotifier {
  final ContentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  HomeData? _homeData;

  HomeProvider({required ContentRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  HomeData? get homeData => _homeData;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homeData = await _repository.fetchHomeData();
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
    return '首页内容加载失败，请稍后重试';
  }
}
