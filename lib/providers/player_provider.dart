import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _isFallbackMode = false;
  bool _isCompleted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _currentTitle = '';
  String _currentInstructor = '';
  final String _ambientSound = '海浪轻拍';
  String? _currentAudioUrl;
  String? _playbackMessage;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _fallbackTimer;

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
      if (_isFallbackMode) {
        return;
      }

      _isLoading =
          state.processingState == ProcessingState.loading ||
          (state.processingState == ProcessingState.buffering &&
              !state.playing);
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isLoading = false;
        _isPlaying = false;
        _isCompleted = true;
        _position = _duration;
      }
      notifyListeners();
    });
  }

  bool get isPlaying => _isPlaying;
  bool get isExpanded => _isExpanded;
  bool get isLoading => _isLoading;
  bool get isFallbackMode => _isFallbackMode;
  bool get isCompleted => _isCompleted;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentTitle => _currentTitle;
  String get currentInstructor => _currentInstructor;
  String get ambientSound => _ambientSound;
  String? get playbackMessage => _playbackMessage;
  bool get hasActiveSession =>
      _currentAudioUrl != null || _currentTitle.isNotEmpty;
  bool get canControl => hasActiveSession && !_isLoading;
  String get statusLabel {
    if (_isLoading) {
      return '正在加载音频';
    }
    if (_isCompleted) {
      return '练习已完成';
    }
    if (_playbackMessage != null) {
      return _playbackMessage!;
    }
    return '背景音景 · $_ambientSound';
  }

  double get progress => _duration.inSeconds > 0
      ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  Future<void> togglePlay() async {
    if (!canControl) {
      return;
    }

    if (_isCompleted) {
      _isCompleted = false;
      if (_isFallbackMode) {
        _position = Duration.zero;
      } else {
        await _audioPlayer.seek(Duration.zero);
      }
    }

    if (_isFallbackMode) {
      if (_isPlaying) {
        _pauseFallbackTimer();
      } else {
        _startFallbackTimer();
      }
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void seekTo(double value) {
    if (_duration.inMilliseconds <= 0) {
      return;
    }

    final target = Duration(seconds: (value * _duration.inSeconds).round());
    _seekToPosition(target);
  }

  void seekBy(Duration offset) {
    if (_duration.inMilliseconds <= 0) {
      return;
    }

    _seekToPosition(_position + offset);
  }

  Future<void> play(
    String title,
    String instructor,
    int durationMinutes, {
    String? audioUrl,
  }) async {
    final normalizedAudioUrl = audioUrl?.trim();
    final hasAudioUrl =
        normalizedAudioUrl != null && normalizedAudioUrl.isNotEmpty;

    _fallbackTimer?.cancel();
    await _audioPlayer.stop();

    _currentTitle = title;
    _currentInstructor = instructor;
    _isExpanded = true;
    _isPlaying = false;
    _isCompleted = false;
    _isFallbackMode = false;
    _isLoading = hasAudioUrl;
    _position = Duration.zero;
    _duration = Duration(minutes: durationMinutes);
    _currentAudioUrl = hasAudioUrl ? normalizedAudioUrl : null;
    _playbackMessage = null;
    notifyListeners();

    if (hasAudioUrl) {
      try {
        final loadedDuration = await _audioPlayer.setUrl(normalizedAudioUrl);
        if (loadedDuration != null) {
          _duration = loadedDuration;
        }
        _isLoading = false;
        notifyListeners();
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Audio load failed: $e');
        _startFallbackMode('音频暂不可用，使用计时模式');
      }
    } else {
      _startFallbackMode('暂无音频，使用计时模式');
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
    _fallbackTimer?.cancel();
    _isPlaying = false;
    _isExpanded = false;
    _isLoading = false;
    _isFallbackMode = false;
    _isCompleted = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _currentTitle = '';
    _currentInstructor = '';
    _currentAudioUrl = null;
    _playbackMessage = null;
    notifyListeners();
  }

  void _seekToPosition(Duration target) {
    final clampedTarget = _clampToDuration(target);

    if (_isFallbackMode) {
      _position = clampedTarget;
      _isCompleted = _position >= _duration;
      if (_isCompleted) {
        _pauseFallbackTimer(notify: false);
      }
      notifyListeners();
      return;
    }

    _audioPlayer.seek(clampedTarget);
  }

  void _startFallbackMode(String message) {
    _isLoading = false;
    _isFallbackMode = true;
    _playbackMessage = message;
    _position = Duration.zero;
    _startFallbackTimer(notify: false);
    notifyListeners();
  }

  void _startFallbackTimer({bool notify = true}) {
    _fallbackTimer?.cancel();
    _isPlaying = true;
    _isCompleted = false;
    _fallbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final nextPosition = _position + const Duration(seconds: 1);
      if (nextPosition >= _duration) {
        _position = _duration;
        _isPlaying = false;
        _isCompleted = true;
        _fallbackTimer?.cancel();
      } else {
        _position = nextPosition;
      }
      notifyListeners();
    });

    if (notify) {
      notifyListeners();
    }
  }

  void _pauseFallbackTimer({bool notify = true}) {
    _fallbackTimer?.cancel();
    _isPlaying = false;

    if (notify) {
      notifyListeners();
    }
  }

  Duration _clampToDuration(Duration target) {
    if (target < Duration.zero) {
      return Duration.zero;
    }
    if (target > _duration) {
      return _duration;
    }
    return target;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _fallbackTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
