import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
import 'package:flutter_spectrogram/src/data/fft/fft_table.dart';
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
    required this.numberOfFreqs, // nf
    required this.frequencyStepHz, // df or dy
    required this.centerOfFirstFrequencyBandHz, // y1 or f1
  })  : powerSpectrumDensity = List<List<double>>.filled(
          numberOfFreqs,
          List<double>.filled(numberOfTimeSlices, 0.0),
        ),
        assert(numberOfTimeSlices > 0),
        assert(numberOfFreqs > 0),
        assert(timeBetweenTimeSlices > 0),
        assert(frequencyStepHz > 0);

  final double tmin;
  final double tmax;

  final int numberOfTimeSlices;
  final int numberOfFreqs;

  final double timeBetweenTimeSlices;

  final double centerOfFirstTimeSlice;

  final double minFrequencyHz;
  final double maxFrequencyHz;
  final double frequencyStepHz;
  final double centerOfFirstFrequencyBandHz;

  final List<List<double>> powerSpectrumDensity;

  double get totalDuration => tmax - tmin;
  double get totalBandwidth => maxFrequencyHz - minFrequencyHz;

  double indexToX(int index) {
    return (centerOfFirstTimeSlice + (index) * timeBetweenTimeSlices);
  }

  int xToLowIndex(Sound sound, double x) {
    return ((x - sound.timeOfFirstSample) / sound.samplingPeriod + 1.0).floor();
  }

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
    final double nyquist = 0.5 / me.samplingPeriod;
    final double physicalAnalysisWidth = (windowType == WindowType.gaussian
        ? 2.0 * effectiveAnalysisWidth
        : effectiveAnalysisWidth);

    final double effectiveTimeWidth =
        effectiveAnalysisWidth / math.sqrt(math.pi);
    final double effectiveFreqWidth = 1.0 / effectiveTimeWidth;

    final double minimumTimeStep2 =
        effectiveTimeWidth / maximumTimeOversampling;
    final double minimumFreqStep2 =
        effectiveFreqWidth / maximumFreqOversampling;

    final double timeStep = math.max(minimumTimeStep1, minimumTimeStep2);
    double freqStep = math.max(minimumFreqStep1, minimumFreqStep2);
    double physicalDuration = me.samplingPeriod * me.numberOfSamples;

    /*
			Compute the time sampling.
		*/
    final int approximateNumberOfSamplesPerWindow =
        (physicalAnalysisWidth / me.samplingPeriod).floor();
    final int halfnsampWindow = approximateNumberOfSamplesPerWindow ~/ 2 - 1;
    final int nsampWindow = halfnsampWindow * 2;

    if (nsampWindow < 1) {
      throw Exception(
          "Your analysis window is too short: less than two samples.");
    }

    if (physicalAnalysisWidth > physicalDuration) {
      throw Exception(
          "Your sound is too short: it should be at least as long as ${windowType == WindowType.gaussian ? "two window lengths." : "one window length."}");
    }

    final int numberOfTimes = 1 +
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
    if (numberOfFreqs < 1) {
      return null;
    }

    int nsampFFT = 1;
    while (nsampFFT < nsampWindow ||
        nsampFFT < 2 * numberOfFreqs * (nyquist / fmax)) {
      nsampFFT *= 2;
    }

    final int halfNsampfft = nsampFFT ~/ 2;

    /*
			Compute the frequency sampling of the spectrogram.
		*/
    int binwidthSamples =
        math.max(1, (freqStep * me.samplingPeriod * nsampFFT).floor());
    double binwidthHertz = 1.0 / (me.samplingPeriod * nsampFFT);
    freqStep = binwidthSamples * binwidthHertz;

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
      numberOfFreqs: numberOfFreqs,
      centerOfFirstFrequencyBandHz: 0.5 * (freqStep - binwidthHertz),
      frequencyStepHz: freqStep,
    );

    // List<double>.generate(nsamp_window.toInt(), (index) => 0.0);
    final window = Float64List(nsampWindow);

    for (int i = 0; i < window.length; ++i) {
      window[i] = 0.0;
    }

    final double edge = math.exp(-12.0); // used for Gaussian

    double windowssq = 0.0;
    for (int i = 0; i < nsampWindow; ++i) {
      final nSamplesPerWindowF = physicalAnalysisWidth / me.samplingPeriod;

      switch (windowType) {
        default:
          final double imid = 0.5 * (nsampWindow + 1);
          final double phase =
              (i.toDouble() - imid) / nSamplesPerWindowF; // -0.5 .. +0.5
          window[i] = (math.exp(-48.0 * phase * phase) - edge) / (1.0 - edge);
          break;
      }
      windowssq += window[i] * window[i];
    }
    final double oneByBinWidth = 1.0 / windowssq / binwidthSamples;

    final data = List<double>.filled(nsampFFT, 0.0);
    final spectrum = List<double>.filled(halfNsampfft + 1, 0.0);

    final fftTable = FFTTable(n: nsampFFT);
    fftTable.init();

    debugPrint("Sound to Spectrogram...");

    for (int iframe = 0; iframe < numberOfTimes; ++iframe) {
      final t = thee.indexToX(iframe);
      final int leftSample = thee.xToLowIndex(me, t);
      final int rightSample = leftSample + 1;
      final int startSample = rightSample - halfnsampWindow;
      final int endSample = leftSample + halfnsampWindow;

      assert(startSample >= 1);
      assert(endSample <= me.numberOfSamples);

      // spectrum.all()  << =  0.0;

      for (int channel = 0; channel < me.numberOfChannels; ++channel) {
        for (int j = 0, i = startSample; j < nsampWindow; j++) {
          data[j] = me.amplitude[i++] * window[j];
        }
        for (int j = nsampWindow; j < nsampFFT; j++) {
          data[j] = 0.0;
        }

        debugPrint(
          "${iframe / (numberOfTimes + 1.0)} Sound to Spectrogram: analysis of frame $iframe out of $numberOfTimes",
        );

        fftTable.forward(data);

        spectrum[0] += data[0] * data[0];
        for (int i = 1; i < halfNsampfft; ++i) {
          final first = data[i + i - 1];
          final second = data[i + i];
          spectrum[i] += first * first + second * second;
        }

        final d = data[nsampFFT - 1];
        spectrum[halfNsampfft] += d * d; // Nyquist frequency. Correct??
      }

      for (int iband = 0; iband < numberOfFreqs; ++iband) {
        final int lowerSample = (iband) * binwidthSamples + 1;
        final int higherSample = lowerSample + binwidthSamples;

        final double power =
            pairwiseSum(spectrum.sublist(lowerSample, higherSample));

        thee.powerSpectrumDensity[iband][iframe] = power * oneByBinWidth;
        // thy z [iband] [iframe] = power * oneByBinWidth;
      }
    }

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

double NUMsum(List<double> data) {
  final double sum = 0.0;
  return sum.toDouble();
}
