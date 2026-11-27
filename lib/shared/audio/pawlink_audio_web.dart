// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

js.JsObject? _audioContext;
js.JsObject? _masterGain;
bool _listenersAttached = false;
html.AudioElement? _currentAudioElement;
String? _currentBlobUrl;
final List<js.JsObject> _activeOscillators = [];

void platformInitAudio() {
  _attachGestureUnlock();
}

void _attachGestureUnlock() {
  if (_listenersAttached) return;
  _listenersAttached = true;

  void unlock(html.Event e) {
    try {
      _getAudioContext();
    } catch (_) {}
  }

  html.window.addEventListener('pointerdown', unlock, true);
  html.window.addEventListener('mousedown', unlock, true);
  html.window.addEventListener('touchstart', unlock, true);
  html.window.addEventListener('click', unlock, true);
  html.window.addEventListener('keydown', unlock, true);
  html.document.addEventListener('pointerdown', unlock, true);
  html.document.addEventListener('click', unlock, true);
}

js.JsObject? _getAudioContext() {
  try {
    if (_audioContext != null) {
      final state = _audioContext!['state'];
      if (state == 'suspended') {
        _audioContext!.callMethod('resume');
      }
      return _audioContext;
    }
    final ctor = js.context['AudioContext'] ?? js.context['webkitAudioContext'];
    if (ctor != null) {
      _audioContext = js.JsObject(ctor as js.JsFunction);
      if (_audioContext!['state'] == 'suspended') {
        _audioContext!.callMethod('resume');
      }
      return _audioContext;
    }
  } catch (_) {}
  return null;
}

js.JsObject _getMasterGain(js.JsObject ctx) {
  if (_masterGain == null) {
    _masterGain = ctx.callMethod('createGain') as js.JsObject;
    _masterGain!.callMethod('connect', [ctx['destination']]);
  }
  return _masterGain!;
}

void platformPlayThemeTone(List<List<double>> notes, Uint8List wavBytes) {
  try {
    _attachGestureUnlock();
    // Stop any existing music immediately before playing the new one
    platformStopAudio();

    final ctx = _getAudioContext();
    if (ctx != null) {
      if (ctx['state'] == 'suspended') {
        ctx.callMethod('resume');
      }
      _scheduleRelaxingMelody(ctx, notes);
      return;
    }

    _playFallbackWav(wavBytes);
  } catch (_) {
    _playFallbackWav(wavBytes);
  }
}

void _scheduleRelaxingMelody(js.JsObject ctx, List<List<double>> notes) {
  try {
    final master = _getMasterGain(ctx);
    final masterGainParam = master['gain'] as js.JsObject;
    final currentTime = (ctx['currentTime'] as num).toDouble();
    masterGainParam.callMethod('setValueAtTime', [1.0, currentTime]);

    double offsetSec = 0.04;

    for (final n in notes) {
      final freq = n[0];
      final durSec = n[1] / 1000.0;
      final pauseSec = n[2] / 1000.0;
      final startTime = currentTime + offsetSec;
      final stopTime = startTime + durSec;
      final attackTime = startTime + 0.025; // 25ms soft swell

      // 1. Primary fundamental: warm, pure sine wave (celeste / music-box)
      final osc1 = ctx.callMethod('createOscillator') as js.JsObject;
      final gain1 = ctx.callMethod('createGain') as js.JsObject;
      osc1['type'] = 'sine';

      final freqParam1 = osc1['frequency'] as js.JsObject;
      freqParam1.callMethod('setValueAtTime', [freq, startTime]);

      final gainParam1 = gain1['gain'] as js.JsObject;
      gainParam1.callMethod('setValueAtTime', [0.0001, startTime]);
      gainParam1.callMethod('linearRampToValueAtTime', [0.18, attackTime]);
      gainParam1.callMethod('exponentialRampToValueAtTime', [0.0001, stopTime]);

      osc1.callMethod('connect', [gain1]);
      gain1.callMethod('connect', [master]);
      osc1.callMethod('start', [startTime]);
      osc1.callMethod('stop', [stopTime]);

      _activeOscillators.add(osc1);

      // 2. Subtle octave harmonic (2.0x frequency) for gentle chime sheen
      final osc2 = ctx.callMethod('createOscillator') as js.JsObject;
      final gain2 = ctx.callMethod('createGain') as js.JsObject;
      osc2['type'] = 'sine';

      final freqParam2 = osc2['frequency'] as js.JsObject;
      freqParam2.callMethod('setValueAtTime', [freq * 2.0, startTime]);

      final gainParam2 = gain2['gain'] as js.JsObject;
      gainParam2.callMethod('setValueAtTime', [0.0001, startTime]);
      gainParam2.callMethod('linearRampToValueAtTime', [0.035, attackTime]);
      gainParam2.callMethod('exponentialRampToValueAtTime', [0.0001, stopTime]);

      osc2.callMethod('connect', [gain2]);
      gain2.callMethod('connect', [master]);
      osc2.callMethod('start', [startTime]);
      osc2.callMethod('stop', [stopTime]);

      _activeOscillators.add(osc2);

      offsetSec += (durSec + pauseSec);
    }
  } catch (_) {}
}

void _playFallbackWav(Uint8List wavBytes) {
  try {
    if (_currentBlobUrl != null) {
      html.Url.revokeObjectUrl(_currentBlobUrl!);
      _currentBlobUrl = null;
    }
    final blob = html.Blob([wavBytes], 'audio/wav');
    final url = html.Url.createObjectUrlFromBlob(blob);
    _currentBlobUrl = url;

    final audio = html.AudioElement(url)..volume = 0.35;
    _currentAudioElement = audio;
    audio.play().then((_) {
      audio.onEnded.first.then((_) {
        audio.remove();
        if (_currentBlobUrl == url) {
          html.Url.revokeObjectUrl(url);
          _currentBlobUrl = null;
        }
      });
    }).catchError((Object? _) {
      audio.remove();
    });
  } catch (_) {}
}

void platformStopAudio() {
  try {
    // 1. Immediately drop master gain to 0 and disconnect to kill all audio instantly
    if (_masterGain != null && _audioContext != null) {
      try {
        final gainParam = _masterGain!['gain'] as js.JsObject;
        final now = (_audioContext!['currentTime'] as num).toDouble();
        gainParam.callMethod('setValueAtTime', [0.0, now]);
        _masterGain!.callMethod('disconnect');
      } catch (_) {}
      _masterGain = null;
    }

    // 2. Disconnect and stop any oscillators
    for (final osc in _activeOscillators) {
      try {
        osc.callMethod('disconnect');
        osc.callMethod('stop', [0]);
      } catch (_) {}
    }
    _activeOscillators.clear();

    // 3. Stop fallback HTML5 AudioElement
    if (_currentAudioElement != null) {
      _currentAudioElement?.pause();
      _currentAudioElement?.currentTime = 0;
      _currentAudioElement?.remove();
      _currentAudioElement = null;
    }
    if (_currentBlobUrl != null) {
      html.Url.revokeObjectUrl(_currentBlobUrl!);
      _currentBlobUrl = null;
    }
  } catch (_) {}
}
