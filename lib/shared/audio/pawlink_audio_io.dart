import 'dart:io';
import 'dart:typed_data';

Process? _currentAudioProcess;
File? _lastWavFile;

void platformInitAudio() {
  // Desktop platform initialization
}

void platformPlayThemeTone(List<List<double>> notes, Uint8List wavBytes) {
  try {
    platformStopAudio();

    // Use gentle music-box WAV through SoundPlayer without harsh console beeps
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final wavFile = File('${tempDir.path}${Platform.pathSeparator}pawlink_tone_$timestamp.wav');
    wavFile.writeAsBytesSync(wavBytes);
    _lastWavFile = wavFile;

    final safeWavPath = wavFile.absolute.path.replaceAll("'", "''");

    Process.start('powershell', [
      '-NoProfile',
      '-WindowStyle',
      'Hidden',
      '-Command',
      "(New-Object System.Media.SoundPlayer '$safeWavPath').PlaySync()",
    ]).then((p) {
      _currentAudioProcess = p;
    }, onError: (Object? _) {});
  } catch (_) {}
}

void platformStopAudio() {
  try {
    if (_currentAudioProcess != null) {
      _currentAudioProcess?.kill();
      _currentAudioProcess = null;
    }
    if (_lastWavFile != null) {
      try {
        if (_lastWavFile!.existsSync()) {
          _lastWavFile!.deleteSync();
        }
      } catch (_) {}
      _lastWavFile = null;
    }
  } catch (_) {}
}
