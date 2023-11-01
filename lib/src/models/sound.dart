import 'dart:typed_data';

import 'package:flutter_spectrogram/src/models/vector.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wav/wav.dart';

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
class Sound extends Vector {
  Sound({
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

  (int nt, int itmin, int itmax) getWindowSamples(double xmin, double xmax) {
    final ixminReal =
        ((xmin - timeOfFirstSample) / samplingPeriod).ceilToDouble();
    final ixmaxReal =
        ((xmax - timeOfFirstSample) / samplingPeriod).floorToDouble();

    final itmin = ixminReal < 0.0 ? 0 : ixminReal.toInt();
    final itmax = ixmaxReal > numberOfSamples.toDouble()
        ? numberOfSamples
        : ixmaxReal.toInt();

    int nt = itmin > itmax ? 0 : itmax - itmin;
    return (nt, itmin, itmax);
  }

  double indexToX(int index) => timeOfFirstSample + index * samplingPeriod;
  double xToIndex(double x) => (x - timeOfFirstSample) / samplingPeriod;

  int xToLowIndex(double x) =>
      ((x - timeOfFirstSample) / samplingPeriod).floor();

  int xToHighIndex(double x) =>
      ((x - timeOfFirstSample) / samplingPeriod).ceil();

  int xToNearestIndex(double x) =>
      ((x - timeOfFirstSample) / samplingPeriod).round();

  (int numberOfFrames, double firstTime) shortTermAnalysis(
    double windowDuration,
    double timeStep,
  ) {
    assert(windowDuration > 0.0);
    assert(timeStep > 0.0);
    double myDuration = samplingPeriod *
        numberOfSamples; // volatile, because we need to truncate to 64 bits
    if (windowDuration > myDuration) {
      throw Exception(": shorter than window length.");
    }

    int numberOfFrames = ((myDuration - windowDuration) / timeStep).floor() + 1;
    assert(numberOfFrames >= 1);

    double ourMidTime =
        timeOfFirstSample - 0.5 * samplingPeriod + 0.5 * myDuration;
    double thyDuration = numberOfFrames * timeStep;
    double firstTime = ourMidTime - 0.5 * thyDuration + 0.5 * timeStep;

    return (numberOfFrames, firstTime);
  }

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
      extracted.xmin = 0.0;
      extracted.xmax = extracted.xmax - tmin;
      extracted.timeOfFirstSample = extracted.timeOfFirstSample - tmin;
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
