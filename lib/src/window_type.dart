import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';

enum WindowType {
  hanning,
  hamming,
  bartlett,
  blackman;

  const WindowType();

  Float64List apply(int size) => switch (this) {
        WindowType.hanning => Window.hanning(size),
        WindowType.hamming => Window.hamming(size),
        WindowType.bartlett => Window.bartlett(size),
        WindowType.blackman => Window.blackman(size),
      };
}
