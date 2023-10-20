import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:spectrogram_tests/models/spectrogram.dart';
import 'dart:math' as math;
import 'models/sound.dart';

class SpectrogramUtils {
  static Spectrogram? soundToSpectrogram({
    required Sound sound,
    required double effectiveAnalysisWidth,
    required double minFreqStep,
    required double minTimeStep,
    required double frequencyMax,
  }) {
    final samplingPeriod = sound.samplingPeriod;

    final nyquist = 0.5 / sound.samplingPeriod;
    final physicalAnalysisWidth = 2.0 * effectiveAnalysisWidth;
    final effectiveTimeWidth = effectiveAnalysisWidth / math.sqrt(math.pi);
    final effectiveFreqWidth = 1.0 / effectiveTimeWidth;

    final minFreqStep = effectiveFreqWidth / 8.0;

    final timeStep = math.max(minTimeStep, effectiveTimeWidth / 8.0);
    double freqStep = math.max(minFreqStep, effectiveFreqWidth / 8.0);

    final physicalDuration = sound.samplingPeriod * sound.numberOfSamples;

    // Compute the Time Sampling
    final approxNumberOfSamplesPerWindow =
        (physicalAnalysisWidth / samplingPeriod).floor();

    final halfNSampWindow = approxNumberOfSamplesPerWindow / 2 - 1;
    final nSampWindow = halfNSampWindow * 2;

    if (nSampWindow < 1) {
      throw Exception('Analysis window is too short: less than two samples');
    }

    if (physicalAnalysisWidth > physicalDuration) {
      throw Exception(
        'Your sound is too short: it should be at least as long as two window lengths',
      );
    }

    final int numberOfTimes =
        1 + ((physicalDuration - physicalAnalysisWidth) / timeStep).floor();

    // Compute the freq sampling of the FFT

    if (frequencyMax <= 0.0 || frequencyMax > nyquist) {
      frequencyMax = nyquist;
    }

    int numberOfFreqs = (frequencyMax / freqStep).floor();

    if (numberOfFreqs < 1) {
      return null;
    }

    int nSampFFT = 1;

    while (nSampFFT < nSampWindow ||
        nSampFFT < 2 * numberOfFreqs * (nyquist / frequencyMax)) {
      nSampFFT *= 2;
    }

    final int halfNSampFFT = nSampFFT ~/ 2;

    final stft = STFT(nSampFFT, gaussian(nSampFFT));
    const buckets = 120;

    Uint64List? logItr;
    final List<List<double>> logBinnedData = [];

    stft.run(
      sound.monoAmplitudes,
      (chunk) {
        // Each time we get a new chunk, add a row to your matrix.
        List<double> chunkPowers = [];
        logBinnedData.add(chunkPowers);

        final amp = chunk.discardConjugates().magnitudes();
        logItr ??= linSpace(amp.length, buckets);

        int i0 = 0;
        for (final i1 in logItr!) {
          double power = 0;
          if (i1 != i0) {
            for (int i = i0; i < i1; ++i) {
              power += amp[i];
            }
            power /= i1 - i0;

            // Add data to the row.
            chunkPowers.add(power);
          }
          i0 = i1;
        }
      },
      halfNSampFFT,
    );
    return Spectrogram(
      tmin: sound.xmin,
      tmax: sound.xmax,
      numberOfTimeSlices: numberOfTimes,
      timeBetweenTimeSlices: timeStep,
      centerOfFirstTimeSlice: 0.0,
      minFrequencyHz: 0.0,
      maxFrequencyHz: frequencyMax,
      numberOfFreqs: numberOfFreqs,
      frequencyStepHz: freqStep,
      centerOfFirstFrequencyBandHz: 0.0,
      powerSpectrumDensity: logBinnedData,
    );
  }
}

Float64List gaussian(
  int size, {
  double alpha = 0.25,
}) {
  final res = Float64List(size);
  final samplingPeriods = (size - 1) * 0.5;

  // standard deviation is alpha * size/2
  final standardDeviation = (alpha * (size - 1)) * 0.5;
  for (int i = 0; i < size; i++) {
    final x = -0.5 * math.pow((i - samplingPeriods) / standardDeviation, 2);
    res[i] = math.exp(x);
  }

  return res;
}

Uint64List linSpace(int end, int steps) {
  final a = Uint64List(steps);
  for (int i = 1; i < steps; ++i) {
    a[i - 1] = (end * i) ~/ steps;
  }
  a[steps - 1] = end;
  return a;
}
