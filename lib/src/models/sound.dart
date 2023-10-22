import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wav/wav.dart';

part 'sound.freezed.dart';

/*

The sampling time is the time interval between successive samples, 
also called the sampling interval or the sampling period, and denoted T
.

The sampling rate is the number of samples per second. 
It is the reciprocal of the sampling time, i.e. 1/T
, also called the sampling frequency, and denoted Fs
.

The frequency axis for the FFT is linked to the number N
 of points in the DFT and the sampling rate Fs
. It is defined as f=k⋅FsN
. With k
 going up to N
 https://dsp.stackexchange.com/questions/30552/sampling-rate-vs-sampling-time-of-fft

 */

// This is the same as Praat's Sound object.
@freezed
class Sound with _$Sound {
  const factory Sound({
    required double xmin, // Seconds
    required double xmax, // Seconds
    required int numberOfSamples, // nx
    required double
        samplingPeriod, // Time interval between two successive sampling points (my dx)
    required double timeOfFirstSample, // Seconds (x1)
    @Default(1) int ymin, // Left or only channel
    required int ymax, // right or only channels
    required int numberOfChannels, // ny
    required Float64List monoAmplitudes,
    required List<Float64List> amplitudes, // z
    // List of List<double> because it's based on multiple channels. We usally expect a mono sound
  }) = _Sound;

  static Sound fromWav(Wav wav) {
    final mono = wav.toMono();
    final duration = wav.duration;

    final samplingRate = wav.samplesPerSecond;
    final samplingPeriod = 1.0 / samplingRate; // samplingTime
    return Sound(
      xmin: 0.0,
      xmax: duration,
      numberOfSamples: wav.channels[0].length,
      samplingPeriod: samplingPeriod,
      timeOfFirstSample: 0.5 / samplingPeriod,
      ymin: 1,
      ymax: 0,
      numberOfChannels: wav.channels.length,
      amplitudes: wav.channels,
      monoAmplitudes: mono,
    );
  }
}
