
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'seasonal_theme.dart';

class SeasonalController extends ChangeNotifier {
  SeasonalController._() {
    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  static final SeasonalController instance = SeasonalController._();

  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;

  SeasonalTheme? _activeTheme;

  bool _musicEnabled = true;
  bool _isPlaying = false;
  bool _hasStartedCurrentTrack = false;
  bool _initialized = false;

  SeasonalTheme? get activeTheme => _activeTheme;
  bool get musicEnabled => _musicEnabled;
  bool get isPlaying => _isPlaying;
  bool get hasSeasonalMusic => _activeTheme != null;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    _activeTheme = SeasonalTheme.byId(
      prefs.getString('pawlink_seasonal_theme'),
    );

    _musicEnabled =
        prefs.getBool('pawlink_seasonal_music') ?? true;

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    if (_activeTheme != null && _musicEnabled) {
      await _playThemeMusic(_activeTheme!);
    }

    notifyListeners();
  }

  Future<void> applyTheme(SeasonalTheme theme) async {
    _activeTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'pawlink_seasonal_theme',
      theme.id.name,
    );

    if (_musicEnabled) {
      await _playThemeMusic(theme);
    } else {
      await _audioPlayer.stop();
      _isPlaying = false;
      _hasStartedCurrentTrack = false;
    }

    notifyListeners();
  }

  Future<void> removeTheme() async {
    _activeTheme = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pawlink_seasonal_theme');

    await _audioPlayer.stop();

    _isPlaying = false;
    _hasStartedCurrentTrack = false;

    notifyListeners();
  }

  Future<void> toggleMusic() {
    return setMusicEnabled(!_musicEnabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('pawlink_seasonal_music', enabled);

    final theme = _activeTheme;

    if (theme == null || !enabled) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _hasStartedCurrentTrack = false;
    } else {
      await _playThemeMusic(theme);
    }

    notifyListeners();
  }

  Future<void> togglePlayback() async {
    final theme = _activeTheme;

    if (theme == null || !_musicEnabled) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else if (_hasStartedCurrentTrack) {
      await _audioPlayer.resume();
      _isPlaying = true;
    } else {
      await _playThemeMusic(theme);
    }

    notifyListeners();
  }

  Future<void> _playThemeMusic(SeasonalTheme theme) async {
    try {
      _isPlaying = false;
      _hasStartedCurrentTrack = false;

      await _audioPlayer.stop();

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      final assetPath = theme.musicAsset.replaceFirst(
        'assets/',
        '',
      );

      await _audioPlayer.play(
        AssetSource(assetPath),
      );

      _hasStartedCurrentTrack = true;

      debugPrint('Seasonal music started: $assetPath');
    } catch (error) {
      _isPlaying = false;
      _hasStartedCurrentTrack = false;

      debugPrint(
        'Seasonal music error (${theme.musicAsset}): $error',
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_playerStateSubscription?.cancel());
    unawaited(_audioPlayer.dispose());

    super.dispose();
  }
}
