import 'package:flutter_spectrogram/flutter_spectrogram.dart';

abstract class Sampled extends CFunction {
  Sampled({
    required super.xmin,
    required super.xmax,
    required this.numberOfSamples,
    required this.samplingPeriod,
    required this.timeOfFirstSample,
  });

  // nx
  int numberOfSamples;

  // Time interval between two successive sampling points (my dx)
  double samplingPeriod;

  // Seconds (x1)
  double timeOfFirstSample;
}
