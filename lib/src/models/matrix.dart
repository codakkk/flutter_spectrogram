import 'dart:typed_data';

import 'package:flutter_spectrogram/src/models/sampled_xy.dart';

class Matrix extends SampledXY {
  Matrix({
    required super.xmin,
    required super.xmax,
    required super.numberOfSamples,
    required super.samplingPeriod,
    required super.timeOfFirstSample,
    required super.ymin,
    required super.ymax,
    required super.numberOfChannels,
    required this.amplitudes,
  });

  // z
  List<Float64List> amplitudes;
}
