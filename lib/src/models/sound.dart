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
  const Sound._();

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
    required List<Float64List> amplitudes, // z
  }) = _Sound;

  static Sound fromWav(Wav wav) {
    final duration = wav.duration;

    final nOfSamples = wav.channels[0].length;
    final samplingRate = wav.samplesPerSecond;
    final samplingPeriod = 1.0 / samplingRate; // samplingTime

    return Sound(
      xmin: 0.0,
      xmax: duration,
      numberOfSamples: nOfSamples,
      samplingPeriod: samplingPeriod,
      timeOfFirstSample: 0.5 * samplingPeriod,
      ymin: 1,
      ymax: 0,
      numberOfChannels: wav.channels.length,
      amplitudes: wav.channels,
    );
  }

  static Sound extractPart({
    required Sound sound,
    required double tmin,
    required double tmax,
    required double relativeWidth,
    required bool preserveTimes,
  }) {
    // Function_unidirectionalAutowindow
    if (tmin >= tmax) {
      tmin = sound.xmin;
      tmax = sound.xmax;
    }

    /*
			Should allow window tails outside specified domain.
		*/
    if (relativeWidth != 1.0) {
      final double margin = 0.5 * (relativeWidth - 1) * (tmax - tmin);
      tmin -= margin;
      tmax += margin;
    }

    /*
			Determine index range. We use all the real or virtual samples that fit within [t1..t2].
		*/
    final int itmin =
        ((tmin - sound.timeOfFirstSample) / sound.samplingPeriod).ceil();
    final int itmax =
        ((tmax - sound.timeOfFirstSample) / sound.samplingPeriod).floor();

    if (itmin > itmax) {
      throw Exception('Extracted Sound would contain no samples.');
    }

    final int numberOfSamples = itmax - itmin + 1;
    Sound extracted = Sound(
      numberOfChannels: sound.numberOfChannels,
      xmin: tmin,
      xmax: tmax,
      numberOfSamples: numberOfSamples,
      samplingPeriod: sound.samplingPeriod,
      timeOfFirstSample:
          sound.timeOfFirstSample + (itmin - 1) * sound.samplingPeriod,
      ymin: 0,
      ymax: 1,
      amplitudes: List.filled(
        sound.numberOfChannels,
        Float64List(numberOfSamples),
      ),
    );

    //
    if (!preserveTimes) {
      extracted = extracted.copyWith(
        xmin: 0.0,
        xmax: extracted.xmax - tmin,
        timeOfFirstSample: extracted.timeOfFirstSample - tmin,
      );
    }

    for (int channel = 0; channel < extracted.numberOfChannels; ++channel) {
      final clippedItMin = itmin < 0 ? 0 : itmin;
      final row = extracted.amplitudes[channel];

      for (int i = 0; i < row.length; ++i) {
        row[i] = sound.amplitudes[channel][clippedItMin + i];
      }
    }
    return extracted;
  }
}
