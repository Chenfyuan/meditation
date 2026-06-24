import 'dart:async';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  bool _isPlaying = false;
  bool _isExpanded = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 15);
  String _currentTitle = '深度放松';
  String _currentInstructor = 'Liam';
  final String _ambientSound = '海浪轻拍';
  Timer? _timer;

  bool get isPlaying => _isPlaying;
  bool get isExpanded => _isExpanded;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentInstructor => _currentInstructor;
  String get ambientSound => _ambientSound;
  bool get hasActiveSession => _isPlaying || _position > Duration.zero;
  double get progress => _position.inSeconds / _duration.inSeconds;

  void togglePlay() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void seekTo(double value) {
    _position = Duration(seconds: (value * _duration.inSeconds).round());
    notifyListeners();
  }

  void play(String title, String instructor, int durationMinutes) {
    _currentTitle = title;
    _currentInstructor = instructor;
    _duration = Duration(minutes: durationMinutes);
    _position = Duration.zero;
    _isPlaying = true;
    _isExpanded = true;
    _startTimer();
    notifyListeners();
  }

  void expand() {
    if (_isExpanded || !hasActiveSession) {
      return;
    }
    _isExpanded = true;
    notifyListeners();
  }

  void collapse() {
    if (!_isExpanded) {
      return;
    }
    _isExpanded = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isPlaying = false;
    _isExpanded = false;
    _position = Duration.zero;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_position < _duration) {
        _position += const Duration(seconds: 1);
        notifyListeners();
      } else {
        _isPlaying = false;
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
