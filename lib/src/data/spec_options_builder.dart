import 'dart:typed_data';

import 'package:quiver/core.dart';

import 'spec_compute.dart';

class SpecOptionsBuilder {
  SpecOptionsBuilder({
    required this.data,
    required this.sampleRate,
    required this.doNormalize,
    required this.numBins,
    required this.stepSize,
    required this.windowFn,
    this.downsampleDivisor = const Optional.absent(),
    this.scaleFactor = const Optional.absent(),
  });

  final Float64List data; // Time domain (samples)
  final double sampleRate;
  final Optional<double> scaleFactor;
  final Optional<int> downsampleDivisor;

  final bool doNormalize; // Normalize samples between -1.0 and 1.0

  final int numBins; // Number of FFT Bins
  final int stepSize; // How far to step between each window function
  final Float64List windowFn;

  SpecCompute? build() {
    if (downsampleDivisor.isPresent) {
      if (downsampleDivisor.value <= 0) {
        return null;
      }

      // Do down-sample
      if (downsampleDivisor.value > 1) {
        // implement downsample if any
      }
    }

    if (doNormalize) {
      final max = data.reduce((max, x) => x > max ? x : max);

      final norm = 1.0 / max;
      for (int i = 0; i < data.length; ++i) {
        data[i] = data[i] * norm;
      }
    }

    if (scaleFactor.isPresent) {
      for (int i = 0; i < data.length; ++i) {
        data[i] = data[i] * scaleFactor.value;
      }
    }

    return SpecCompute(
      numBins: numBins,
      stepSize: stepSize,
      data: data,
      windowFn: windowFn,
    );
  }
}
