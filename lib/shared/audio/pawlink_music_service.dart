import 'dart:math' as math;
import 'dart:typed_data';
import '../../main.dart';
import 'pawlink_audio_bridge.dart';

class PawLinkMusicService {
  static final PawLinkMusicService instance = PawLinkMusicService._();
  PawLinkMusicService._();

  Uint8List? _cachedChristmasToneWav;
  Uint8List? _cachedNewYearToneWav;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    initAudioPlatform();
    currentThemeNotifier.addListener(_onThemeChanged);
  }

  void playThemeForMode(AdminThemeMode mode) {
    // Immediately stop any currently playing music when theme changes
    stop();

    if (mode == AdminThemeMode.christmas) {
      playChristmasThemeTone();
    } else if (mode == AdminThemeMode.newYear) {
      playNewYearThemeTone();
    }
  }

  void _onThemeChanged() {
    playThemeForMode(currentThemeNotifier.value);
  }

  // Play full relaxing Christmas music-box theme (~18s)
  void playChristmasThemeTone() {
    try {
      _cachedChristmasToneWav ??= _synthesizeMelody(_christmasChimeNotes);
      playThemeToneAudio(_christmasChimeNotes, _cachedChristmasToneWav!);
    } catch (_) {}
  }

  // Play full relaxing New Year celebration theme (~22s)
  void playNewYearThemeTone() {
    try {
      _cachedNewYearToneWav ??= _synthesizeMelody(_newYearChimeNotes);
      playThemeToneAudio(_newYearChimeNotes, _cachedNewYearToneWav!);
    } catch (_) {}
  }

  void stop() {
    stopWavAudio();
  }

  // Soft, relaxing music-box WAV synthesis (pure sine + warm octave harmonic)
  static Uint8List _synthesizeMelody(List<List<double>> notes) {
    const int sampleRate = 22050;

    int totalSamples = 0;
    for (final n in notes) {
      final noteDurationMs = n[1];
      final pauseMs = n[2];
      totalSamples += ((noteDurationMs + pauseMs) * sampleRate / 1000).round();
    }

    final pcmSamples = Int16List(totalSamples);
    int sampleOffset = 0;

    for (final n in notes) {
      final freq = n[0];
      final noteDurationMs = n[1];
      final pauseMs = n[2];

      final noteSamples = (noteDurationMs * sampleRate / 1000).round();
      final pauseSamples = (pauseMs * sampleRate / 1000).round();
      final attackSamples = (sampleRate * 0.025).round(); // 25ms soft swell

      for (int i = 0; i < noteSamples; i++) {
        final t = i / sampleRate;
        final progress = i / noteSamples;

        // Smooth attack to eliminate clicks/pops
        double attack = 1.0;
        if (i < attackSamples) {
          attack = i / attackSamples;
        }

        // Calming, gentle exponential bell decay
        final env = attack * math.exp(-2.8 * progress);

        // Relaxing music-box tone: pure sine fundamental + warm octave overtone
        final wave = 0.85 * math.sin(2 * math.pi * freq * t) +
            0.15 * math.sin(2 * math.pi * (2.0 * freq) * t);

        // Gentle amplitude (peak ~8500 out of 32767, ~26% comfortable volume)
        final sample = (wave * env * 8500).clamp(-32768, 32767).toInt();
        pcmSamples[sampleOffset++] = sample;
      }

      for (int i = 0; i < pauseSamples; i++) {
        pcmSamples[sampleOffset++] = 0;
      }
    }

    final byteData = ByteData(44 + totalSamples * 2);

    // "RIFF"
    byteData.setUint8(0, 0x52);
    byteData.setUint8(1, 0x49);
    byteData.setUint8(2, 0x46);
    byteData.setUint8(3, 0x46);
    byteData.setUint32(4, 36 + totalSamples * 2, Endian.little);

    // "WAVE"
    byteData.setUint8(8, 0x57);
    byteData.setUint8(9, 0x41);
    byteData.setUint8(10, 0x56);
    byteData.setUint8(11, 0x45);

    // "fmt "
    byteData.setUint8(12, 0x66);
    byteData.setUint8(13, 0x6D);
    byteData.setUint8(14, 0x74);
    byteData.setUint8(15, 0x20);
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little); // PCM
    byteData.setUint16(22, 1, Endian.little); // mono
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);

    // "data"
    byteData.setUint8(36, 0x64);
    byteData.setUint8(37, 0x61);
    byteData.setUint8(38, 0x74);
    byteData.setUint8(39, 0x61);
    byteData.setUint32(40, totalSamples * 2, Endian.little);

    final pcmBytes = pcmSamples.buffer.asUint8List();
    final resultBytes = byteData.buffer.asUint8List();
    resultBytes.setRange(44, 44 + pcmBytes.length, pcmBytes);

    return resultBytes;
  }

  // Extended relaxing Christmas music-box motif (~18s full melody)
  // Jingle Bells Chorus & Verse in warm octave 4
  static const List<List<double>> _christmasChimeNotes = [
    // Phrase 1: "Jin-gle bells, jin-gle bells, jin-gle all the way!"
    [329.63, 240, 70], // E4
    [329.63, 240, 70], // E4
    [329.63, 480, 140], // E4
    [329.63, 240, 70], // E4
    [329.63, 240, 70], // E4
    [329.63, 480, 140], // E4
    [329.63, 240, 50], // E4
    [392.00, 240, 50], // G4
    [261.63, 280, 50], // C4
    [293.66, 240, 50], // D4
    [329.63, 560, 180], // E4

    // Phrase 2: "Oh what fun it is to ride in a one-horse open sleigh, hey!"
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [329.63, 240, 50], // E4
    [329.63, 240, 50], // E4
    [329.63, 200, 50], // E4
    [329.63, 200, 50], // E4
    [392.00, 240, 50], // G4
    [392.00, 240, 50], // G4
    [349.23, 240, 50], // F4
    [293.66, 240, 50], // D4
    [261.63, 650, 200], // C4

    // Phrase 3: Reprise of Chorus (Soft Music-Box Echo)
    [329.63, 240, 70], // E4
    [329.63, 240, 70], // E4
    [329.63, 480, 140], // E4
    [329.63, 240, 70], // E4
    [329.63, 240, 70], // E4
    [329.63, 480, 140], // E4
    [329.63, 240, 50], // E4
    [392.00, 240, 50], // G4
    [261.63, 280, 50], // C4
    [293.66, 240, 50], // D4
    [329.63, 560, 180], // E4

    // Phrase 4: Peaceful Warm Finale
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [349.23, 240, 50], // F4
    [329.63, 240, 50], // E4
    [329.63, 240, 50], // E4
    [392.00, 260, 60], // G4
    [392.00, 260, 60], // G4
    [349.23, 260, 60], // F4
    [293.66, 300, 60], // D4
    [261.63, 900, 250], // C4
  ];

  // Extended relaxing New Year celebration motif (~22s full melody)
  // Full Ode to Joy orchestral celebration in gentle music-box chime
  static const List<List<double>> _newYearChimeNotes = [
    // Section 1: Main Theme (Warm & Joyful)
    [329.63, 280, 60], // E4
    [329.63, 280, 60], // E4
    [349.23, 280, 60], // F4
    [392.00, 280, 60], // G4
    [392.00, 280, 60], // G4
    [349.23, 280, 60], // F4
    [329.63, 280, 60], // E4
    [293.66, 280, 60], // D4
    [261.63, 280, 60], // C4
    [261.63, 280, 60], // C4
    [293.66, 280, 60], // D4
    [329.63, 380, 70], // E4
    [329.63, 240, 50], // E4
    [293.66, 240, 50], // D4
    [293.66, 500, 150], // D4

    // Section 2: Theme Cadence
    [329.63, 280, 60], // E4
    [329.63, 280, 60], // E4
    [349.23, 280, 60], // F4
    [392.00, 280, 60], // G4
    [392.00, 280, 60], // G4
    [349.23, 280, 60], // F4
    [329.63, 280, 60], // E4
    [293.66, 280, 60], // D4
    [261.63, 280, 60], // C4
    [261.63, 280, 60], // C4
    [293.66, 280, 60], // D4
    [329.63, 380, 70], // E4
    [293.66, 240, 60], // D4
    [261.63, 650, 180], // C4

    // Section 3: Festive Bridge
    [293.66, 280, 60], // D4
    [293.66, 280, 60], // D4
    [329.63, 280, 60], // E4
    [261.63, 280, 60], // C4
    [293.66, 260, 50], // D4
    [329.63, 180, 40], // E4
    [349.23, 180, 40], // F4
    [329.63, 260, 50], // E4
    [261.63, 280, 60], // C4
    [293.66, 260, 50], // D4
    [329.63, 180, 40], // E4
    [349.23, 180, 40], // F4
    [329.63, 260, 50], // E4
    [293.66, 280, 60], // D4
    [261.63, 280, 60], // C4
    [293.66, 450, 120], // D4

    // Section 4: Celebratory Grand Finale
    [329.63, 280, 60], // E4
    [329.63, 280, 60], // E4
    [349.23, 280, 60], // F4
    [392.00, 280, 60], // G4
    [392.00, 280, 60], // G4
    [349.23, 280, 60], // F4
    [329.63, 280, 60], // E4
    [293.66, 280, 60], // D4
    [261.63, 280, 60], // C4
    [261.63, 280, 60], // C4
    [293.66, 280, 60], // D4
    [329.63, 380, 70], // E4
    [293.66, 260, 70], // D4
    [261.63, 900, 250], // C4
  ];
}
