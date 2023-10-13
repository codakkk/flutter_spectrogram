import 'package:flutter/foundation.dart';
import 'package:flutter_spectrogram/src/data/sound.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wav/wav_file.dart';

void main() {
  test(
    'Create default sound from Wav',
    () async {
      final file = await Wav.readFile('test/assets/IT_CLD_02S06.wav');
      final mono = file.toMono();

      final channels = file.channels.length;
      final sampleRate = file.samplesPerSecond;
      final duration = mono.length / sampleRate;

      if (mono.isEmpty) {
        throw Exception('Audio file contains 0 samples');
      }

      final sound = Sound(
        numberOfChannels: file.channels.length,
        xmin: 0.0,
        xmax: duration,
        numberOfSamples: (duration * sampleRate).round(),
        samplingPeriod: 1.0 / sampleRate,
        timeOfFirstSample: 0.5 / sampleRate,
        ymax: 0,
        amplitude: mono,
      );

      final spectrogram = SpectrogramData.fromSound(sound)!;

      debugPrint(spectrogram.powerSpectrumDensity.toString());

      debugPrint('ciao');
    },
  );
}
