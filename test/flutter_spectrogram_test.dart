import 'dart:io';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
import 'package:flutter_spectrogram/src/colour_gradient.dart';
import 'package:flutter_spectrogram/src/data/spec_options_builder.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wav/wav.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

// Reference: https://github.com/psiphi75/sonogram/blob/master/src/lib.rs#L296
void main() {
  test('Spectrogram', () async {
    final wav = await Wav.readFile('test/assets/IT_CLD_02S06.wav');
    final audio = normalizeRmsVolume(wav.toMono(), 0.3);
    const chunkSize = 2048;
    const buckets = 2048;
    final stft = STFT(chunkSize, Window.hanning(chunkSize));
    Uint64List? logItr;
    stft.run(
      audio,
      (Float64x2List chunk) {
        final amp = chunk.discardConjugates().magnitudes();
        logItr ??= linSpace(amp.length, buckets);
        int i0 = 0;
        for (final i1 in logItr!) {
          double power = 0;
          if (i1 != i0) {
            for (int i = i0; i < i1; ++i) {
              power += amp[i];
            }
            power /= i1 - i0;
          }
          stdout.write(gradient(power));
          i0 = i1;
        }
        stdout.write('\n');
      },
      chunkSize ~/ 2,
    );
  });
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
      final image = spectrogram.toImageInMemory(
        spectrogram.width,
        spectrogram.height,
        gradient,
      );

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

Float64List normalizeRmsVolume(List<double> a, double target) {
  final b = Float64List.fromList(a);
  double squareSum = 0;
  for (final x in b) {
    squareSum += x * x;
  }
  double factor = target * math.sqrt(b.length / squareSum);
  for (int i = 0; i < b.length; ++i) {
    b[i] *= factor;
  }
  return b;
}

Uint64List linSpace(int end, int steps) {
  final a = Uint64List(steps);
  for (int i = 1; i < steps; ++i) {
    a[i - 1] = (end * i) ~/ steps;
  }
  a[steps - 1] = end;
  return a;
}

String gradient(double power) {
  const scale = 2;
  const levels = [' ', '░', '▒', '▓', '█'];
  int index = math.log((power * levels.length) * scale).floor();
  if (index < 0) index = 0;
  if (index >= levels.length) index = levels.length - 1;
  return levels[index];
}
