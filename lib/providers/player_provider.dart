import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/practice_session_record.dart';
import '../repositories/practice_history_repository.dart';

class PlayerProvider extends ChangeNotifier {
  static const sleepTimerOptions = [15, 30, 45, 60];

  final AudioPlayer _audioPlayer = AudioPlayer();
  final PracticeHistoryRepository? _historyRepository;
  final DateTime Function() _now;

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
  PracticeSource _currentSource = PracticeSource.unknown;
  String? _currentAudioUrl;
  String? _playbackMessage;
  int _plannedDurationSeconds = 0;
  int _maxListenedSeconds = 0;
  bool _hasRecordedCurrentSession = false;
  int? _sleepTimerMinutes;
  DateTime? _sleepTimerEndsAt;
  Duration _sleepTimerRemaining = Duration.zero;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _fallbackTimer;
  Timer? _sleepTimerTicker;

  PlayerProvider({
    PracticeHistoryRepository? historyRepository,
    DateTime Function()? now,
  }) : _historyRepository = historyRepository,
       _now = now ?? DateTime.now {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      _trackListenedPosition(pos);
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
        _trackListenedPosition(_duration);
        unawaited(_recordCurrentSession(PracticeCompletionReason.finished));
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
  int? get sleepTimerMinutes => _sleepTimerMinutes;
  Duration get sleepTimerRemaining => _sleepTimerRemaining;
  bool get hasActiveSession =>
      _currentAudioUrl != null || _currentTitle.isNotEmpty;
  bool get canControl => hasActiveSession && !_isLoading;
  bool get hasSleepTimer => _sleepTimerMinutes != null;
  String get sleepTimerRemainingLabel => _formatTimer(_sleepTimerRemaining);
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
    PracticeSource source = PracticeSource.unknown,
  }) async {
    final normalizedAudioUrl = audioUrl?.trim();
    final hasAudioUrl =
        normalizedAudioUrl != null && normalizedAudioUrl.isNotEmpty;

    _fallbackTimer?.cancel();
    _clearSleepTimer(notify: false);
    await _audioPlayer.stop();

    _currentTitle = title;
    _currentInstructor = instructor;
    _currentSource = source;
    _isExpanded = true;
    _isPlaying = false;
    _isCompleted = false;
    _isFallbackMode = false;
    _isLoading = hasAudioUrl;
    _position = Duration.zero;
    _duration = Duration(minutes: durationMinutes);
    _currentAudioUrl = hasAudioUrl ? normalizedAudioUrl : null;
    _playbackMessage = null;
    _plannedDurationSeconds = durationMinutes * 60;
    _maxListenedSeconds = 0;
    _hasRecordedCurrentSession = false;
    notifyListeners();

    if (hasAudioUrl) {
      try {
        final loadedDuration = await _audioPlayer.setUrl(normalizedAudioUrl);
        if (loadedDuration != null) {
          _duration = loadedDuration;
          _plannedDurationSeconds = loadedDuration.inSeconds;
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
    if (_completionThresholdMet) {
      unawaited(_recordCurrentSession(PracticeCompletionReason.threshold));
    }
    _audioPlayer.stop();
    _fallbackTimer?.cancel();
    _clearSleepTimer(notify: false);
    _isPlaying = false;
    _isExpanded = false;
    _isLoading = false;
    _isFallbackMode = false;
    _isCompleted = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _currentTitle = '';
    _currentInstructor = '';
    _currentSource = PracticeSource.unknown;
    _currentAudioUrl = null;
    _playbackMessage = null;
    _plannedDurationSeconds = 0;
    _maxListenedSeconds = 0;
    _hasRecordedCurrentSession = false;
    notifyListeners();
  }

  void setSleepTimerMinutes(int? minutes) {
    if (!hasActiveSession) {
      return;
    }

    if (minutes == null) {
      _clearSleepTimer();
      return;
    }

    _sleepTimerTicker?.cancel();
    _sleepTimerMinutes = minutes;
    _sleepTimerRemaining = Duration(minutes: minutes);
    _sleepTimerEndsAt = _now().add(_sleepTimerRemaining);
    _sleepTimerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateSleepTimer();
    });
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
        unawaited(_recordCurrentSession(PracticeCompletionReason.finished));
      } else {
        _position = nextPosition;
        _trackListenedPosition(_position);
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

  void _trackListenedPosition(Duration position) {
    if (position.inSeconds > _maxListenedSeconds) {
      _maxListenedSeconds = position.inSeconds;
    }
  }

  bool get _completionThresholdMet {
    final durationSeconds = _currentDurationSeconds;
    if (durationSeconds <= 0) {
      return false;
    }
    return _currentListenedSeconds >= (durationSeconds * 0.8).ceil();
  }

  int get _currentDurationSeconds {
    if (_duration.inSeconds > 0) {
      return _duration.inSeconds;
    }
    return _plannedDurationSeconds;
  }

  int get _currentListenedSeconds {
    final durationSeconds = _currentDurationSeconds;
    final currentSeconds = _position.inSeconds > _maxListenedSeconds
        ? _position.inSeconds
        : _maxListenedSeconds;
    if (durationSeconds <= 0) {
      return currentSeconds;
    }
    return currentSeconds > durationSeconds ? durationSeconds : currentSeconds;
  }

  Future<void> _recordCurrentSession(PracticeCompletionReason reason) async {
    final historyRepository = _historyRepository;
    if (historyRepository == null ||
        _hasRecordedCurrentSession ||
        !hasActiveSession) {
      return;
    }

    final durationSeconds = _currentDurationSeconds;
    if (durationSeconds <= 0) {
      return;
    }

    final listenedSeconds = _listenedSecondsFor(reason, durationSeconds);
    if (listenedSeconds <= 0) {
      return;
    }

    final completedAt = _now();
    final record = PracticeSessionRecord(
      id: '${completedAt.microsecondsSinceEpoch}-${_currentTitle.hashCode.abs()}',
      title: _currentTitle,
      subtitle: _currentInstructor.trim().isEmpty
          ? _sourceLabel(_currentSource)
          : _currentInstructor,
      durationSeconds: durationSeconds,
      listenedSeconds: listenedSeconds,
      completedAt: completedAt,
      completionReason: reason,
      source: _currentSource,
    );
    _hasRecordedCurrentSession = true;

    try {
      await historyRepository.addRecord(record);
    } catch (error) {
      debugPrint('Practice history record failed: $error');
    }
  }

  int _listenedSecondsFor(
    PracticeCompletionReason reason,
    int durationSeconds,
  ) {
    if (reason == PracticeCompletionReason.finished) {
      return durationSeconds;
    }

    var listenedSeconds = _currentListenedSeconds;
    if (reason == PracticeCompletionReason.sleepTimer) {
      final timerSeconds = (_sleepTimerMinutes ?? 0) * 60;
      if (timerSeconds > listenedSeconds) {
        listenedSeconds = timerSeconds;
      }
    }

    if (listenedSeconds > durationSeconds) {
      return durationSeconds;
    }
    return listenedSeconds;
  }

  String _sourceLabel(PracticeSource source) {
    switch (source) {
      case PracticeSource.meditation:
        return '引导冥想';
      case PracticeSource.sleepStory:
        return '睡眠故事';
      case PracticeSource.soundscape:
        return '自然音景';
      case PracticeSource.unknown:
        return '静';
    }
  }

  void _clearSleepTimer({bool notify = true}) {
    _sleepTimerTicker?.cancel();
    _sleepTimerTicker = null;
    _sleepTimerMinutes = null;
    _sleepTimerEndsAt = null;
    _sleepTimerRemaining = Duration.zero;

    if (notify) {
      notifyListeners();
    }
  }

  void _updateSleepTimer() {
    final endsAt = _sleepTimerEndsAt;
    if (endsAt == null) {
      return;
    }

    final remaining = endsAt.difference(_now());
    if (remaining <= Duration.zero) {
      unawaited(_expireSleepTimer());
      return;
    }

    _sleepTimerRemaining = remaining;
    notifyListeners();
  }

  Future<void> _expireSleepTimer() async {
    if (!hasActiveSession) {
      _clearSleepTimer();
      return;
    }

    await _recordCurrentSession(PracticeCompletionReason.sleepTimer);
    await _audioPlayer.stop();
    _fallbackTimer?.cancel();
    _clearSleepTimer(notify: false);
    _isPlaying = false;
    _isExpanded = false;
    _isLoading = false;
    _isFallbackMode = false;
    _isCompleted = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _currentTitle = '';
    _currentInstructor = '';
    _currentSource = PracticeSource.unknown;
    _currentAudioUrl = null;
    _playbackMessage = null;
    _plannedDurationSeconds = 0;
    _maxListenedSeconds = 0;
    _hasRecordedCurrentSession = false;
    notifyListeners();
  }

  String _formatTimer(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _fallbackTimer?.cancel();
    _sleepTimerTicker?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
