import 'package:flutter_spectrogram/src/models/sampled.dart';

abstract class SampledXY extends Sampled {
  SampledXY({
    required super.xmin,
    required super.xmax,
    required super.numberOfSamples,
    required super.samplingPeriod,
    required super.timeOfFirstSample,
    required this.ymin,
    required this.ymax,
    required this.numberOfChannels,
    this.dy = 0.0,
    this.y1 = 0.0,
  });

  int ymin; // Left or only channel
  int ymax; // right or only channels

  int numberOfChannels; // ny

  double dy;
  double y1;
}
