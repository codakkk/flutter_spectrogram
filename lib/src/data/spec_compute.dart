import 'dart:core';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';

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

    int p = 0;

    for (var w = 0; w < width; w++) {
      final it = data
          .skip(p)
          .take(numBins)
          .indexed
          .map((e) => e.$2 * windowFn[e.$1])
          .map(
            (e) => Float64x2(e, 0.0),
          );

      final buf = Float64x2List.fromList(it.toList());

      _fft.inPlaceFft(buf);
      // Normalize the spectrogram and write to the output

      norm(Float64x2 e) => e.x * e.x + e.y * e.y;
      buf.sublist(0, height).reversed.map(norm).toList().asMap().forEach(
        (i, value) {
          spec[w + i * width] = value;
        },
      );

      p += stepSize;
    }

    debugPrint('Data: ${spec[0]} ${spec[1]} ${spec[2]}');

    return SpectrogramData(
      width: width,
      height: height,
      spec: spec,
    );
  }
}
