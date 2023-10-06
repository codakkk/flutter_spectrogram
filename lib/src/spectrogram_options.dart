import 'package:flutter/foundation.dart';

import 'window_type.dart';

@immutable
class SpectrogramOptions {
  const SpectrogramOptions({
    this.chunkSize = 1024,
    this.chunkStride = 512,
    this.windowType = WindowType.hanning,
  });

  final int chunkSize;

  // usually half the chunk size
  final int chunkStride;

  final WindowType windowType;
}
