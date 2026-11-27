import 'dart:typed_data';
import 'pawlink_audio_stub.dart'
    if (dart.library.html) 'pawlink_audio_web.dart'
    if (dart.library.io) 'pawlink_audio_io.dart';

void initAudioPlatform() {
  platformInitAudio();
}

void playThemeToneAudio(List<List<double>> notes, Uint8List wavBytes) {
  platformPlayThemeTone(notes, wavBytes);
}

void stopWavAudio() {
  platformStopAudio();
}
