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
    double maximumTimeOversampling = 8.0,
    double maximumFreqOversampling = 8.0,
  }) {
    final nyquist = 0.5 / sound.samplingPeriod;
    final physicalAnalysisWidth = 2.0 * effectiveAnalysisWidth;
    final effectiveTimeWidth = effectiveAnalysisWidth / math.sqrt(math.pi);
    final effectiveFreqWidth = 1.0 / effectiveTimeWidth;

    final timeStep = math.max(
      minTimeStep,
      effectiveTimeWidth / maximumTimeOversampling,
    );
    double freqStep = math.max(
      minFreqStep,
      effectiveFreqWidth / maximumFreqOversampling,
    );

    final physicalDuration = sound.samplingPeriod * sound.numberOfSamples;

    // Compute the Time Sampling
    final approxNumberOfSamplesPerWindow =
        (physicalAnalysisWidth / sound.samplingPeriod).floor();

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
    final t1 = sound.timeOfFirstSample +
        0.5 *
            ((sound.numberOfSamples - 1) * sound.samplingPeriod -
                (numberOfTimes - 1) * timeStep);

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

    final binWidthSamples =
        math.max(1, (freqStep * sound.samplingPeriod * nSampFFT)).floor();
    final binWidthHertz = 1.0 / (sound.samplingPeriod * nSampFFT);
    freqStep = binWidthSamples * binWidthHertz;
    numberOfFreqs = (frequencyMax / freqStep).floor();
    if (numberOfFreqs < 1) {
      return null;
    }

    final stft = STFT(
      nSampFFT,
      gaussianPraat(
        nSampFFT,
        // alpha: 4.5,
        nSamplesPerWindowF: physicalAnalysisWidth / sound.samplingPeriod,
      ),
    );

    Uint64List? logItr;
    final List<List<double>> logBinnedData = [];

    //const buckets = 120;

    stft.run(
      sound.monoAmplitudes,
      (chunk) {
        // Each time we get a new chunk, add a row to the matrix.
        List<double> chunkPowers = [];
        logBinnedData.add(chunkPowers);

        final amp = chunk.discardConjugates().magnitudes();
        logItr ??= linSpace(amp.length, numberOfFreqs);

        int i0 = 0;
        for (final i1 in logItr!) {
          double power = 0;
          if (i1 != i0) {
            for (int i = i0; i < i1; ++i) {
              power += amp[i];
            }
            power /= i1 - i0;

            // Add data to the row.
            chunkPowers.add(math.log(power));
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
      centerOfFirstTimeSlice: t1,
      minFrequencyHz: 0.0,
      maxFrequencyHz: frequencyMax,
      numberOfFreqs: numberOfFreqs,
      frequencyStepHz: freqStep,
      centerOfFirstFrequencyBandHz: 0.5 * (freqStep - binWidthHertz),
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

Float64List gaussianPraat(
  int size, {
  required double nSamplesPerWindowF,
}) {
  final res = Float64List(size);

  for (int i = 0; i < size; i++) {
    final imid = 0.5 * (size + 1);
    final edge = math.exp(-12.0);
    final phase = (i.toDouble() - imid) / nSamplesPerWindowF; // -0.5 .. +0.5
    final x = (math.exp(-48.0 * phase * phase) - edge) / (1.0 - edge);
    res[i] = x;
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
