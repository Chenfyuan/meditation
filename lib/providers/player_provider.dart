import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isExpanded = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _currentTitle = '';
  String _currentInstructor = '';
  final String _ambientSound = '海浪轻拍';
  String? _currentAudioUrl;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  PlayerProvider() {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
    _stateSub = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = _duration;
      }
      notifyListeners();
    });
  }

  bool get isPlaying => _isPlaying;
  bool get isExpanded => _isExpanded;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentInstructor => _currentInstructor;
  String get ambientSound => _ambientSound;
  bool get hasActiveSession => _currentAudioUrl != null || _currentTitle.isNotEmpty;
  double get progress =>
      _duration.inSeconds > 0 ? _position.inSeconds / _duration.inSeconds : 0.0;

  void togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void seekTo(double value) {
    final target = Duration(seconds: (value * _duration.inSeconds).round());
    _audioPlayer.seek(target);
  }

  Future<void> play(
    String title,
    String instructor,
    int durationMinutes, {
    String? audioUrl,
  }) async {
    _currentTitle = title;
    _currentInstructor = instructor;
    _isExpanded = true;
    _currentAudioUrl = audioUrl;
    notifyListeners();

    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
      } catch (e) {
        debugPrint('Audio load failed: $e');
        _duration = Duration(minutes: durationMinutes);
        notifyListeners();
      }
    } else {
      _duration = Duration(minutes: durationMinutes);
      _position = Duration.zero;
      notifyListeners();
    }
  }

  void expand() {
    if (_isExpanded || !hasActiveSession) return;
    _isExpanded = true;
    notifyListeners();
  }

  void collapse() {
    if (!_isExpanded) return;
    _isExpanded = false;
    notifyListeners();
  }

  void reset() {
    _audioPlayer.stop();
    _isPlaying = false;
    _isExpanded = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _currentTitle = '';
    _currentInstructor = '';
    _currentAudioUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
