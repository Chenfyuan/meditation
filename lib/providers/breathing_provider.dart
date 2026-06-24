import 'dart:async';
import 'package:flutter/material.dart';

enum BreathPhase { inhale, hold, exhale, rest }

class BreathingProvider extends ChangeNotifier {
  BreathPhase _phase = BreathPhase.inhale;
  int _countdown = 4;
  int _currentRound = 3;
  int _totalRounds = 8;
  int _remainingSeconds = 150; // 2:30
  bool _isRunning = false;
  Timer? _timer;

  BreathPhase get phase => _phase;
  int get countdown => _countdown;
  int get currentRound => _currentRound;
  int get totalRounds => _totalRounds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  String get phaseLabel {
    switch (_phase) {
      case BreathPhase.inhale:
        return '吸气';
      case BreathPhase.hold:
        return '屏息';
      case BreathPhase.exhale:
        return '呼气';
      case BreathPhase.rest:
        return '放松';
    }
  }

  String get phaseHint {
    switch (_phase) {
      case BreathPhase.inhale:
        return '跟随圆圈，缓缓地吸气';
      case BreathPhase.hold:
        return '保持，让气息停留';
      case BreathPhase.exhale:
        return '缓缓地呼出';
      case BreathPhase.rest:
        return '放松，自然呼吸';
    }
  }

  int get phaseDuration {
    switch (_phase) {
      case BreathPhase.inhale:
        return 4;
      case BreathPhase.hold:
        return 7;
      case BreathPhase.exhale:
        return 8;
      case BreathPhase.rest:
        return 2;
    }
  }

  void start() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void toggleRunning() {
    if (_isRunning) {
      pause();
    } else {
      start();
    }
  }

  void _tick() {
    if (_remainingSeconds <= 0) {
      _isRunning = false;
      _timer?.cancel();
      notifyListeners();
      return;
    }
    _remainingSeconds--;
    _countdown--;
    if (_countdown <= 0) {
      _advancePhase();
    }
    notifyListeners();
  }

  void _advancePhase() {
    switch (_phase) {
      case BreathPhase.inhale:
        _phase = BreathPhase.hold;
        _countdown = 7;
      case BreathPhase.hold:
        _phase = BreathPhase.exhale;
        _countdown = 8;
      case BreathPhase.exhale:
        _phase = BreathPhase.rest;
        _countdown = 2;
      case BreathPhase.rest:
        _phase = BreathPhase.inhale;
        _countdown = 4;
        if (_currentRound < _totalRounds) _currentRound++;
    }
  }

  String get remainingFormatted {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
