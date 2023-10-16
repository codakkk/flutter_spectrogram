import 'dart:typed_data';

import 'package:fftea/fftea.dart';

import 'spectrogram_data.dart';

class SpecCompute {
  SpecCompute({
    required this.numBins,
    required this.data,
    required this.stepSize,
    required this.windowFn,
  }) {
    _fft = FFT(numBins);
    _stft = STFT(numBins, windowFn);
  }

  final int numBins;
  final Float64List data;
  final int stepSize;
  final Float64List windowFn;

  late final FFT _fft;
  late final STFT _stft;

  SpectrogramData compute() {
    final width = (data.length - numBins) ~/ stepSize;
    final height = numBins ~/ 2;

    Float64List spec = Float64List(numBins * width);
    for (int i = 0; i < spec.length; ++i) {
      spec[i] = 0.0;
    }

    int pos = 0;

    _stft.run(
      data,
      (chunk) {
        final n = chunk.discardConjugates().magnitudes();

        for (int i = 0; i < stepSize; ++i) {
          spec[stepSize * pos + i] = n[i];
        }

        pos++;
      },
      stepSize,
    );

    return SpectrogramData(
      width: width,
      height: height,
      spec: spec,
    );
  }
}
