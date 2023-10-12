import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
import 'dart:math' as math;

import 'sound.dart';

// https://github.com/praat/praat/issues/345 ?
class SpectrogramData {
  SpectrogramData({
    required this.tmin, // tmin or xmin
    required this.tmax, // tmax or xmax
    required this.numberOfTimeSlices, //nx or nt
    required this.timeBetweenTimeSlices, // dt or dx
    required this.centerOfFirstTimeSlice, // t1 or x1
    required this.minFrequencyHz, // ymin or fmin
    required this.maxFrequencyHz, // ymax or fmax
    required this.frequencyStepHz, // df or dy
    required this.centerOfFirstFrequencyBandHz, // y1 or f1
  });

  final double tmin;
  final double tmax;

  final int numberOfTimeSlices;

  final double timeBetweenTimeSlices;

  final double centerOfFirstTimeSlice;

  final double minFrequencyHz;
  final double maxFrequencyHz;
  final double frequencyStepHz;
  final double centerOfFirstFrequencyBandHz;

  late final List<List<double>> powerSpectrumDensity;

  double get totalDuration => tmax - tmin;
  double get totalBandwidth => maxFrequencyHz - minFrequencyHz;

  static SpectrogramData? fromSound(
    Sound me, {
    double effectiveAnalysisWidth = 0.005,
    double fmax = 5000.0,
    double minimumTimeStep1 = 0.002,
    double minimumFreqStep1 = 20.0,
    WindowType windowType = WindowType.gaussian,
    double maximumTimeOversampling = 8.0,
    double maximumFreqOversampling = 8.0,
  }) {
    final nyquist = 0.5 / me.samplingPeriod;
    final physicalAnalysisWidth = (windowType == WindowType.gaussian
        ? 2.0 * effectiveAnalysisWidth
        : effectiveAnalysisWidth);

    final effectiveTimeWidth = effectiveAnalysisWidth / math.sqrt(math.pi);
    final effectiveFreqWidth = 1.0 / effectiveTimeWidth;

    double minimumTimeStep2 = effectiveTimeWidth / maximumTimeOversampling;
    double minimumFreqStep2 = effectiveFreqWidth / maximumFreqOversampling;
    double timeStep = math.max(minimumTimeStep1, minimumTimeStep2);
    double freqStep = math.max(minimumFreqStep1, minimumFreqStep2);
    // double physicalDuration = my dx * my nx;
    double physicalDuration = 9999;
    /*
			Compute the time sampling.
		*/
    final approximateNumberOfSamplesPerWindow =
        (physicalAnalysisWidth / me.samplingPeriod).floor();
    final halfnsamp_window = approximateNumberOfSamplesPerWindow / 2 - 1;
    final nsamp_window = halfnsamp_window * 2;

    if (nsamp_window < 1) {
      throw Exception(
          "Your analysis window is too short: less than two samples.");
    }

    if (physicalAnalysisWidth > physicalDuration) {
      throw Exception(
          "Your sound is too short: it should be at least as long as ${windowType == WindowType.gaussian ? "two window lengths." : "one window length."}");
    }

    final numberOfTimes = 1 +
        ((physicalDuration - physicalAnalysisWidth) / timeStep).floor(); // >= 1

    final double t1 = me.timeOfFirstSample +
        0.5 *
            ((me.numberOfSamples - 1) * me.samplingPeriod -
                (numberOfTimes - 1) * timeStep); // centre of first frame

    /*
			Compute the frequency sampling of the FFT spectrum.
		*/
    if (fmax <= 0.0 || fmax > nyquist) {
      fmax = nyquist;
    }

    int numberOfFreqs = (fmax / freqStep).floor();
    if (numberOfFreqs < 1) return null;

    int nsampFFT = 1;
    while (nsampFFT < nsamp_window ||
        nsampFFT < 2 * numberOfFreqs * (nyquist / fmax)) {
      nsampFFT *= 2;
    }

    final half_nsampFFT = nsampFFT / 2;

    /*
			Compute the frequency sampling of the spectrogram.
		*/
    int binWidth_samples =
        math.max(1, (freqStep * me.samplingPeriod * nsampFFT).floor());
    double binWidth_hertz = 1.0 / (me.samplingPeriod * nsampFFT);
    freqStep = binWidth_samples * binWidth_hertz;
    numberOfFreqs = (fmax / freqStep).floor();
    if (numberOfFreqs < 1) {
      return null;
    }

    final thee = SpectrogramData(
      tmin: me.xmin,
      tmax: me.xmax,
      numberOfTimeSlices: numberOfTimes,
      timeBetweenTimeSlices: timeStep,
      centerOfFirstTimeSlice: t1,
      minFrequencyHz: 0.0,
      maxFrequencyHz: fmax,
      centerOfFirstFrequencyBandHz: 0.5 * (freqStep - binWidth_hertz),
      frequencyStepHz: freqStep,
    );

    // List<double>.generate(nsamp_window.toInt(), (index) => 0.0);
    final window = Float64List(nsamp_window.toInt());

    double windowssq = 0.0;
    for (int i = 0; i < nsamp_window; ++i) {
      final nSamplesPerWindowF = physicalAnalysisWidth / me.samplingPeriod;

      switch (windowType) {
        default:
          final double imid = 0.5 * (nsamp_window + 1);
          final double edge = math.exp(-12.0);
          final double phase =
              (i.toDouble() - imid) / nSamplesPerWindowF; // -0.5 .. +0.5
          window[i] = (math.exp(-48.0 * phase * phase) - edge) / (1.0 - edge);
          break;
      }
      windowssq += window[i] * window[i];
    }
    final double oneByBinWidth = 1.0 / windowssq / binWidth_samples;

    debugPrint("Sound to Spectrogram...");

    final STFT stft = STFT(
      nsamp_window.toInt(),
      window,
    );

    final fftResult = <Float64List>[];
    final spectrum = List<double>.filled(half_nsampFFT.toInt() + 1, 0.0);
    int currentFrame = 0;
    thee.powerSpectrumDensity = List<List<double>>.filled(
      numberOfFreqs,
      List<double>.filled(me.amplitude.length, 0.0),
    );
    stft.run(
      me.amplitude,
      (chunk) {
        Float64List amplitudes = chunk.discardConjugates().magnitudes();

        /*
          Binning
        */
        for (int iframe = 0; iframe < chunk.length; ++iframe) {
          for (int iband = 0; iband < numberOfFreqs; ++iband) {
            final int lowerSample = (iband - 1) * binWidth_samples + 1;
            final int higherSample = lowerSample + binWidth_samples;

            final part = spectrum.sublist(lowerSample, higherSample);
            final power = pairwiseSum(part);

            thee.powerSpectrumDensity[iband][currentFrame + iframe] =
                power * oneByBinWidth;
          }
        }

        fftResult.add(amplitudes);
      },
    );

    return thee;
  }

  static double pairwiseSum(List<double> a) {
    int n = a.length;
    int i = 0, j = 0, b = 0;
    double sum = 0.0;
    final sums = List<double>.filled(32, 0.0);

    for (i = 0; i + 7 < n; i += 8) {
      b = i ^ (i + 8);
      if (b == 8) {
        sums[3] = (((a[i] + a[i + 1]) + (a[i + 2] + a[i + 3])) +
            ((a[i + 4] + a[i + 5]) + (a[i + 6] + a[i + 7])));
      } else {
        sums[3] += (((a[i] + a[i + 1]) + (a[i + 2] + a[i + 3])) +
            ((a[i + 4] + a[i + 5]) + (a[i + 6] + a[i + 7])));
        for (j = 4; (b >> (j + 1)) == 1; j++) {
          sums[j] += sums[j - 1];
        }
        sums[j] = sums[j - 1];
      }
    }
    for (; i < n; i++) {
      b = i ^ (i + 1);
      if (b == 1) {
        sums[0] = a[i];
      } else {
        sums[0] += a[i];
        for (j = 1; (b >> (j + 1)) == 1; j++) {
          sums[j] += sums[j - 1];
        }
        sums[j] = sums[j - 1];
      }
    }
    for (i = 0; i < 32; i++) {
      if ((n >> i) & 1 == 1) sum += sums[i];
    }
    return sum;
  }
}
