import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../data/audio_manifest.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  StreamSubscription<void>? _effectCompleteSub;
  int _playToken = 0;
  bool _backgroundEnabled = true;
  bool _initialized = false;

  bool get isBackgroundEnabled => _backgroundEnabled;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      await _effectPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(0.6);
    } catch (_) {
      return;
    }

    if (_backgroundEnabled) {
      await ensureBackgroundPlayback();
    }
  }

  Future<void> setBackgroundEnabled(bool enabled) async {
    _backgroundEnabled = enabled;
    try {
      if (enabled) {
        await ensureBackgroundPlayback();
      } else {
        await _backgroundPlayer.pause();
      }
    } catch (_) {
      return;
    }
  }

  Future<void> toggleBackgroundEnabled() async {
    await setBackgroundEnabled(!_backgroundEnabled);
  }

  Future<void> ensureBackgroundPlayback() async {
    if (!_backgroundEnabled) {
      return;
    }

    final path = audioPath('background_music');
    if (path == null) {
      return;
    }

    if (_backgroundPlayer.state != PlayerState.playing) {
      try {
        await _backgroundPlayer.play(AssetSource(path));
      } catch (_) {
        return;
      }
    }
  }

  Future<void> pauseBackground() async {
    try {
      await _backgroundPlayer.pause();
    } catch (_) {
      return;
    }
  }

  Future<void> play(String name, {Future<void> Function()? onComplete}) async {
    final path = _resolve(name);
    if (path == null) {
      if (onComplete != null) {
        await onComplete();
      }
      return;
    }

    _effectCompleteSub?.cancel();
    _effectCompleteSub = null;

    final myToken = ++_playToken;
    if (onComplete != null) {
      _effectCompleteSub = _effectPlayer.onPlayerComplete.listen((_) async {
        if (myToken != _playToken) {
          return;
        }
        await onComplete();
      });
    }

    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource(path));
    } catch (_) {
      return;
    }
  }

  Future<void> stopEffect() async {
    _effectCompleteSub?.cancel();
    _effectCompleteSub = null;
    _playToken++;
    try {
      await _effectPlayer.stop();
    } catch (_) {
      return;
    }
  }

  String? _resolve(String name) {
    final candidates = <String>{name, name.toLowerCase(), name.toUpperCase()};

    for (final candidate in candidates) {
      final found = audioPath(candidate);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  Future<void> dispose() async {
    try {
      await _effectCompleteSub?.cancel();
      await _effectPlayer.dispose();
      await _backgroundPlayer.dispose();
    } catch (_) {
      return;
    }
  }
}
