class Spectrogram {
  Spectrogram({
    required this.tmin, // tmin or xmin
    required this.tmax, // tmax or xmax
    required this.numberOfTimeSlices, //nx or nt
    required this.timeBetweenTimeSlices, // dt or dx
    required this.centerOfFirstTimeSlice, // t1 or x1
    required this.minFrequencyHz, // ymin or fmin
    required this.maxFrequencyHz, // ymax or fmax
    required this.numberOfFreqs, // nf or ny
    required this.frequencyStepHz, // df or dy
    required this.centerOfFirstFrequencyBandHz, // y1 or f1
    required this.powerSpectrumDensity,
  })  : /*powerSpectrumDensity = List<Float64List>.filled(
          numberOfFreqs,
          Float64List(numberOfTimeSlices),
        ),*/
        assert(numberOfTimeSlices > 0),
        assert(numberOfFreqs > 0),
        assert(timeBetweenTimeSlices > 0),
        assert(frequencyStepHz > 0);

  static Spectrogram zero = Spectrogram(
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
}
