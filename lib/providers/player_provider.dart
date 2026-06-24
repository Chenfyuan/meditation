import 'dart:async';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 15);
  String _currentTitle = '深度放松';
  String _currentInstructor = 'Liam';
  String _ambientSound = '海浪轻拍';
  Timer? _timer;

  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentInstructor => _currentInstructor;
  String get ambientSound => _ambientSound;
  double get progress => _position.inSeconds / _duration.inSeconds;

  void togglePlay() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
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
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
