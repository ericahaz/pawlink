
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

  static const Duration trialDuration = Duration(days: 30);

  static const String _themeKey = 'pawlink_seasonal_theme';
  static const String _musicKey = 'pawlink_seasonal_music';
  static const String _trialStartKey = 'pawlink_seasonal_trial_start';

  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _trialTimer;

  SeasonalTheme? _activeTheme;

  DateTime? _trialStartDate;

  bool _musicEnabled = true;
  bool _isPlaying = false;
  bool _hasStartedCurrentTrack = false;
  bool _initialized = false;
  bool _isExpiring = false;

  SeasonalTheme? get activeTheme => _activeTheme;
  bool get musicEnabled => _musicEnabled;
  bool get isPlaying => _isPlaying;
  bool get hasSeasonalMusic => _activeTheme != null;

  DateTime? get trialStartDate => _trialStartDate;

  DateTime? get trialEndDate {
    if (_trialStartDate == null) return null;
    return _trialStartDate!.add(trialDuration);
  }

  bool get trialActive {
    final end = trialEndDate;
    return end != null && DateTime.now().isBefore(end);
  }

  Duration get trialRemaining {
    final end = trialEndDate;

    if (end == null) return Duration.zero;

    final remaining = end.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isTrialTheme(SeasonalTheme theme) {
    return SeasonalTheme.trialThemes.any(
      (trialTheme) => trialTheme.id == theme.id,
    );
  }

  bool canUseTheme(SeasonalTheme theme) {
    if (SeasonalTheme.freeThemes.any(
      (freeTheme) => freeTheme.id == theme.id,
    )) {
      return true;
    }

    return isTrialTheme(theme) && trialActive;
  }

  String get trialCountdownLabel {
    if (!trialActive) return 'Trial expired';

    final remaining = trialRemaining;

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    return '$days days, $hours hours, $minutes minutes remaining';
  }

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    // Start the shared trial timer only once.
    int? savedStart = prefs.getInt(_trialStartKey);

    if (savedStart == null) {
      final now = DateTime.now();

      savedStart = now.millisecondsSinceEpoch;

      await prefs.setInt(_trialStartKey, savedStart);
    }

    _trialStartDate =
        DateTime.fromMillisecondsSinceEpoch(savedStart);

    _activeTheme = SeasonalTheme.byId(
      prefs.getString(_themeKey),
    );

    _musicEnabled = prefs.getBool(_musicKey) ?? true;

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Remove an expired trial theme if it was previously applied.
    if (_activeTheme != null &&
        isTrialTheme(_activeTheme!) &&
        !trialActive) {
      _activeTheme = null;

      await prefs.remove(_themeKey);
      await _audioPlayer.stop();

      _isPlaying = false;
      _hasStartedCurrentTrack = false;
    } else if (_activeTheme != null && _musicEnabled) {
      await _playThemeMusic(_activeTheme!);
    }

    // Keep the countdown updated while the app is open.
    _trialTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        _checkTrialExpiration();
      },
    );

    notifyListeners();
  }

  Future<void> _checkTrialExpiration() async {
    if (!trialActive) {
      final theme = _activeTheme;

      if (theme != null &&
          isTrialTheme(theme) &&
          !_isExpiring) {
        _isExpiring = true;

        try {
          await removeTheme();
        } finally {
          _isExpiring = false;
        }
      }
    }

    notifyListeners();
  }

  Future<void> applyTheme(SeasonalTheme theme) async {
    if (!canUseTheme(theme)) return;

    _activeTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeKey,
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

    await prefs.remove(_themeKey);

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

    await prefs.setBool(_musicKey, enabled);

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
    _trialTimer?.cancel();

    unawaited(_playerStateSubscription?.cancel());
    unawaited(_audioPlayer.dispose());

    super.dispose();
  }
}
