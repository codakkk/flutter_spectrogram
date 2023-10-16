import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
import 'package:flutter_spectrogram/src/colour_gradient.dart';
import 'package:flutter_spectrogram/src/data/spec_options_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wav/wav.dart';

void main() {
  test(
    'adds one to input values',
    () async {
      final audio = await Wav.readFile("assets/IT_CLD_02S06.wav");

      final samples = audio.toMono();

      const stepSize = 2048;
      const numBins = 2048;

      final gradient = ColourGradient.audacity();

      final builder = SpecOptionsBuilder(
        data: samples,
        sampleRate: audio.samplesPerSecond.toDouble(),
        doNormalize: true,
        numBins: numBins,
        stepSize: stepSize,
        windowFn: WindowType.gaussian.apply(stepSize),
      );

      const overlap = 1.0 - (stepSize / numBins);

      debugPrint("Computing spectrogram...");
      debugPrint("Bins: $numBins");
      debugPrint("Overlap: $overlap");
      debugPrint("Step size: $stepSize");
    },
  );
}
