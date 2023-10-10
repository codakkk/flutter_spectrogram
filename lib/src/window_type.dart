import 'dart:math' as math;

import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';

enum WindowType {
  hanning,
  hamming,
  bartlett,
  blackman,
  gaussian;

  const WindowType();

  Float64List apply(int size) => switch (this) {
        WindowType.hanning => Window.hanning(size),
        WindowType.hamming => Window.hamming(size),
        WindowType.bartlett => Window.bartlett(size),
        WindowType.blackman => Window.blackman(size),
        WindowType.gaussian => _gaussian(size),
      };
}

Float64List _gaussian(
  int bufferSize, {
  double alpha = 0.25,
}) {
  final res = Float64List(bufferSize);
  final samplingPeriods = (bufferSize - 1) * 0.5;
  final standardDeviation = (alpha * (bufferSize - 1)) * 0.5;
  for (int i = 0; i < bufferSize; i++) {
    res[i] = math
        .pow(
          math.e,
          -0.5 *
              math.pow(
                (i - samplingPeriods) / standardDeviation,
                2,
              ),
        )
        .toDouble();
  }
  return res;
}
