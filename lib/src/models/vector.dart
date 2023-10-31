import 'dart:typed_data';

import 'matrix.dart';

/*
  Vector inherits from Matrix 
  A Vector is a horizontal Matrix. 
  The rows are 'channels'. There will often be only one channel, but e.g. a stereo sound has two.
*/
class Vector extends Matrix {
  Vector({
    required super.xmin,
    required super.xmax,
    required super.numberOfSamples,
    required super.samplingPeriod,
    required super.timeOfFirstSample,
    required super.ymin,
    required super.ymax,
    required super.numberOfChannels,
    required super.amplitudes,
  });

  Float64List getChannel(int channel) {
    return amplitudes[channel];
  }
}
