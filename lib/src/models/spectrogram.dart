import 'package:freezed_annotation/freezed_annotation.dart';

part 'spectrogram.freezed.dart';

@freezed
class Spectrogram with _$Spectrogram {
  const Spectrogram._();

  const factory Spectrogram({
    required double tmin, // tmin or xmin
    required double tmax, // tmax or xmax
    required int numberOfTimeSlices, //nx or nt
    required double timeBetweenTimeSlices, // dt or dx
    required double centerOfFirstTimeSlice, // t1 or x1
    required double minFrequencyHz, // ymin or fmin
    required double maxFrequencyHz, // ymax or fmax
    required int numberOfFreqs, // nf or ny
    required double frequencyStepHz, // df or dy
    required double centerOfFirstFrequencyBandHz, // y1 or f1
    required List<List<double>> powerSpectrumDensity,
  }) = _Spectrogram;

  static Spectrogram zero = const Spectrogram(
    tmin: 0.0,
    tmax: 0.0,
    numberOfTimeSlices: 0,
    timeBetweenTimeSlices: 0,
    centerOfFirstTimeSlice: 0,
    minFrequencyHz: 0,
    maxFrequencyHz: 0,
    numberOfFreqs: 0,
    frequencyStepHz: 0,
    centerOfFirstFrequencyBandHz: 0,
    powerSpectrumDensity: [],
  );

  double get totalDuration => tmax - tmin;
  double get totalBandwidth => maxFrequencyHz - minFrequencyHz;
}
