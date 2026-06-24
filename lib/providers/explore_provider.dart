import 'package:flutter/material.dart';

import '../models/meditation.dart';
import '../repositories/content_repository.dart';
import '../services/api_exception.dart';

class ExploreProvider extends ChangeNotifier {
  final ContentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Meditation> _allMeditations = const [];
  String _selectedFilter = '全部';
  String _searchQuery = '';

  ExploreProvider({required ContentRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  List<String> get filters => [
    '全部',
    ...{
      for (final meditation in _allMeditations)
        if (meditation.category.isNotEmpty) meditation.category,
    },
  ];

  List<Meditation> get meditations {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    return _allMeditations
        .where((meditation) {
          final matchesFilter =
              _selectedFilter == '全部' || meditation.category == _selectedFilter;
          if (!matchesFilter) {
            return false;
          }

          if (normalizedQuery.isEmpty) {
            return true;
          }

          final searchableText = [
            meditation.title,
            meditation.subtitle,
            meditation.instructor,
            meditation.category,
          ].join(' ').toLowerCase();

          return searchableText.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMeditations = await _repository.fetchMeditations();
    } catch (error) {
      _errorMessage = _buildErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter == filter) {
      return;
    }
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) {
      return;
    }
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> retry() => load();

  String _buildErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '探索内容加载失败，请稍后重试';
  }
}
