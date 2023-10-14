import 'package:flutter/foundation.dart';
import 'package:flutter_spectrogram/src/data/sound.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_spectrogram/src/log_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scidart/numdart.dart';
import 'package:wav/wav_file.dart';

import 'dart:math' as math;

void main() {
  test(
    'Create default sound from Wav',
    () async {
      final file = await Wav.readFile('test/assets/IT_CLD_02S06.wav');
      final mono = file.toMono();

      final channels = file.channels.length;
      final sampleRate = file.samplesPerSecond;
      final duration = mono.length / sampleRate;

      if (mono.isEmpty) {
        throw Exception('Audio file contains 0 samples');
      }

      final sound = Sound(
        numberOfChannels: file.channels.length,
        xmin: 0.0,
        xmax: duration,
        numberOfSamples: (duration * sampleRate).round(),
        samplingPeriod: 1.0 / sampleRate,
        timeOfFirstSample: 0.5 / sampleRate,
        ymax: 0,
        amplitudes: file.channels,
      );

      final spectrogram = SpectrogramData.fromSound(sound)!;

      debugPrint('Object Name: ...');
      debugPrint('Date: today');
      debugPrint('N of Channels: ${sound.numberOfChannels}');

      debugPrint('Time domain: ');
      debugPrint('   Start time: ${sound.xmin} seconds');
      debugPrint('   End time: ${sound.xmax} seconds');
      debugPrint('   Total duration: ${sound.xmax - sound.xmin} secondss');

      debugPrint('Time sampling: ');
      debugPrint('   Number of samples: ${sound.numberOfSamples}');
      debugPrint(
          '   Sampling period: ${sound.samplingPeriod.toStringAsExponential(8)} seconds');
      debugPrint('   Sampling frequency: ${1.0 / sound.samplingPeriod} Hz');
      debugPrint(
          '   First sample centred at: ${sound.timeOfFirstSample.toStringAsExponential(8)} seconds');

      int numberOfCells = sound.numberOfSamples * sound.numberOfChannels;
      bool thereAreEnoughObservationsToComputeFirstOrderOverallStatistics =
          (numberOfCells >= 1);
      if (thereAreEnoughObservationsToComputeFirstOrderOverallStatistics) {
        double minimumPa = sound.amplitudes[0][0];
        double maximumPa = minimumPa;

        double sumPa = 0.0;
        double sumOfSquaresPa2 = 0.0;
        for (int channel = 0; channel < sound.numberOfChannels; ++channel) {
          final waveformPa = sound.amplitudes[channel];
          for (int i = 0; i < sound.numberOfSamples; ++i) {
            final double valuePa = waveformPa[i];
            sumPa += valuePa;
            sumOfSquaresPa2 += valuePa * valuePa;
            if (valuePa < minimumPa) {
              minimumPa = valuePa;
            }
            if (valuePa > maximumPa) {
              maximumPa = valuePa;
            }
          }
        }
        debugPrint('Amplitude:');
        debugPrint('   Minimum: $minimumPa Pascal');
        debugPrint('   Maximum: $maximumPa Pascal');
        debugPrint(
            '   Mean: ${(sumPa / numberOfCells).toStringAsExponential(8)}');
        final rootMeanSquarePa = math.sqrt(sumOfSquaresPa2 / numberOfCells);
        debugPrint('   Root Mean square: $rootMeanSquarePa Pascal');
        final energyPa2s =
            sumOfSquaresPa2 * sound.samplingPeriod / sound.numberOfChannels;

        const rhoc = 400.0;
        final energyJm2 = energyPa2s / rhoc;
        debugPrint(
            'Total energy: $energyPa2s Pascal/sec (energy in air: ${energyJm2.toStringAsExponential(8)} Joule/m)');

        final double physicaldurationS =
            sound.samplingPeriod * sound.numberOfSamples;
        final double powerWM2 =
            energyJm2 / physicaldurationS; // kg s-3 = Watt/m2

        String powerString = '';
        if (powerWM2 != 0.0) {
          // this equals the square of 2.0e-5 Pa, divided by rho c
          final double referencepowerWM2 = double.parse("1.0e-12");
          final double powerDb =
              10.0 * LogUtils.log10(powerWM2 / referencepowerWM2);
          powerString = ' = $powerDb dB';
        }

        debugPrint(
            'Mean power (intensity) in air: ${powerWM2.toStringAsExponential(8)} Watt/m\u00B2 $powerString');
      }

      if (sound.numberOfSamples >= 2) {
        for (int channel = 0; channel < sound.numberOfChannels; ++channel) {
          double stdev = standardDeviation(Array(sound.amplitudes[channel]));
          debugPrint('Standard deviation in channel $channel: $stdev Pascal');
        }
      }
    },
  );
}
