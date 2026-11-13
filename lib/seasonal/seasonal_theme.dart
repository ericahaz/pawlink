import 'package:flutter/material.dart';

/// The available seasonal theme identifiers.
///
/// The enum name is saved in SharedPreferences, so keep these names stable
/// after users have applied a theme.
enum SeasonalThemeId {
  christmas,
  halloween,
  summer,
  valentines,
  easter,
}

class SeasonalTheme {
  const SeasonalTheme({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.icon,
    required this.decorations,
    required this.musicAsset,
  });

  final SeasonalThemeId id;
  final String name;
  final String subtitle;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final IconData icon;
  final List<String> decorations;

  /// Asset path for the optional background music.
  ///
  /// Add the corresponding licensed audio file and declare it in pubspec.yaml
  /// before expecting music playback to work.
  final String musicAsset;

  /// Returns the theme saved in SharedPreferences, or null if no valid
  /// theme identifier was saved.
  static SeasonalTheme? byId(String? savedId) {
    if (savedId == null || savedId.isEmpty) return null;

    for (final theme in freeThemes) {
      if (theme.id.name == savedId) return theme;
    }
    return null;
  }

  /// Themes currently available for free in the Seasonal Shop.
  static const List<SeasonalTheme> freeThemes = [
    SeasonalTheme(
      id: SeasonalThemeId.christmas,
      name: 'Christmas Cheer',
      subtitle: 'A warm and festive holiday look.',
      primary: Color(0xFFB83232),
      secondary: Color(0xFF2E7D52),
      background: Color(0xFFFFF8F1),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF382B28),
      textSecondary: Color(0xFF79645D),
      border: Color(0xFFEADBD2),
      icon: Icons.park_rounded,
      decorations: ['🎄', '⭐', '🎁', '❄️'],
      musicAsset: 'assets/music/pawlink_music.mp3/christmas_cheer.mp3',
    ),
    SeasonalTheme(
      id: SeasonalThemeId.halloween,
      name: 'Spooky Season',
      subtitle: 'A playful look for the Halloween season.',
      primary: Color(0xFFE87522),
      secondary: Color(0xFF6D3A8A),
      background: Color(0xFFFFF8F1),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF30243A),
      textSecondary: Color(0xFF74677D),
      border: Color(0xFFE8DDED),
      icon: Icons.brightness_2_rounded,
      decorations: ['🎃', '🦇', '👻', '🕸️'],
      musicAsset: 'assets/music/pawlink_music.mp3/spooky_season.mp3',
    ),
    SeasonalTheme(
      id: SeasonalThemeId.summer,
      name: 'Sunny Days',
      subtitle: 'A bright and cheerful summer look.',
      primary: Color(0xFFE5A000),
      secondary: Color(0xFF2D9C9A),
      background: Color(0xFFFFFCF0),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF3D3216),
      textPrimary: Color(0xFF393321),
      textSecondary: Color(0xFF77704F),
      border: Color(0xFFEDE5C8),
      icon: Icons.wb_sunny_rounded,
      decorations: ['☀️', '🌻', '🌴', '🌊'],
      musicAsset: 'assets/music/pawlink_music.mp3/sunny_day.mp3',
    ),
    SeasonalTheme(
      id: SeasonalThemeId.valentines,
      name: 'Lovely Moments',
      subtitle: 'A soft and sweet look filled with hearts.',
      primary: Color(0xFFD94F82),
      secondary: Color(0xFFB94D79),
      background: Color(0xFFFFF7FA),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF432A35),
      textSecondary: Color(0xFF806675),
      border: Color(0xFFF0DCE5),
      icon: Icons.favorite_rounded,
      decorations: ['💗', '💕', '🌷', '💌'],
      musicAsset: 'assets/music/pawlink_music.mp3/lovely_moments.mp3',
    ),
    SeasonalTheme(
      id: SeasonalThemeId.easter,
      name: 'Spring Bloom',
      subtitle: 'A fresh pastel look inspired by spring.',
      primary: Color(0xFF6A9B69),
      secondary: Color(0xFF8EAF63),
      background: Color(0xFFF7FBF3),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2E3D2B),
      textSecondary: Color(0xFF687A63),
      border: Color(0xFFDDE8D5),
      icon: Icons.local_florist_rounded,
      decorations: ['🌸', '🐣', '🌼', '🦋'],
      musicAsset: 'assets/music/pawlink_music.mp3/spring_bloom.mp3',
    ),
  ];
}
