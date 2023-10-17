import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
import 'package:flutter_spectrogram/src/colour_gradient.dart';
import 'package:flutter_spectrogram/src/data/spec_options_builder.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wav/wav.dart';
import 'package:image/image.dart' as img;

void main() {
  test(
    'adds one to input values',
    () async {
      final audio = await Wav.readFile("test/assets/IT_CLD_02S06.wav");

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

      final spectrogram = builder.build()!.compute();
      final image = spectrogram.toImageInMemory(300, 100, gradient);

      final png = img.encodePng(image);
      // Write the PNG formatted data to a file.
      await File('test/assets/image.png').writeAsBytes(png);
    },
  );

  late Float64List v;

  group(
    'Spectrogram',
    () {
      setUp(
        () {
          v = Float64List(4);
          v[0] = 1.0;
          v[1] = 2.0;
          v[2] = 4.0;
          v[3] = 1.123;
        },
      );

      test(
        'No x distance',
        () {
          final c = integrate(0.0, 0.0, v);

          expect((c - 0.0).abs(), lessThan(0.0001));
        },
      );

      test(
        'No number boundary',
        () {
          final c = integrate(0.25, 1.0, v);

          expect((c - 0.75).abs(), lessThan(0.0001));
        },
      );

      test(
        'Across one boundary',
        () {
          final c = integrate(0.75, 1.25, v);

          expect((c - 0.75).abs(), lessThan(0.0001));
        },
      );

      test(
        'Other tests',
        () {
          final c = integrate(1.8, 2.6, v);
          expect((c - 2.8).abs(), lessThan(0.0001));
        },
      );

      test(
        'Full range',
        () {
          final c = integrate(0.0, 4.0, v);

          expect((c - 8.123).abs(), lessThan(0.0001));
        },
      );
    },
  );
}
