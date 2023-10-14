import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sound.freezed.dart';

@freezed
class Sound with _$Sound {
  const factory Sound({
    required double xmin, // Seconds
    required double xmax, // Seconds
    required int numberOfSamples, // nx
    required double samplingPeriod, // Seconds (my dx)
    required double timeOfFirstSample, // Seconds (x1)
    @Default(1) int ymin, // Left or only channel
    required int ymax, // right or only channels
    required int numberOfChannels, // ny
    required List<Float64List> amplitudes, // z
    // List of List<double> because it's based on multiple channels. We usally expect a mono sound
  }) = _Sound;
}
