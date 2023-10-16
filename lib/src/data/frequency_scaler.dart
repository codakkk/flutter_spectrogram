import 'dart:math' as math;

import 'frequency_scale.dart';

abstract class FrequencyScaler {
  static FreqScalerTrait create(
    FrequencyScale freqScale,
    double fMaxOrig,
    double fMaxNew,
  ) {
    return switch (freqScale) {
      FrequencyScale.linear => LinearFreq.init(fMaxOrig, fMaxNew),
      FrequencyScale.logarithm => LogFreq.init(fMaxOrig, fMaxNew),
    };
  }
}

abstract class FreqScalerTrait {
  FreqScalerTrait.init();
  Tuple2<double, double> scale(int y);
}

class LinearFreq implements FreqScalerTrait {
  final double ratio;

  LinearFreq.init(double fMaxOrig, double fMaxNew) : ratio = fMaxOrig / fMaxNew;

  @override
  Tuple2<double, double> scale(int y) {
    final f1 = ratio * y.toDouble();
    final f2 = ratio * (y + 1).toDouble();
    return Tuple2(f1, f2);
  }
}

class LogFreq implements FreqScalerTrait {
  final double logCoef;

  LogFreq.init(double fMaxOrig, double fMaxNew)
      : logCoef = fMaxOrig / math.log(fMaxNew);

  @override
  Tuple2<double, double> scale(int y) {
    final f1 = logCoef * math.log(y.toDouble());
    final f2 = logCoef * math.log((y + 1).toDouble());
    return Tuple2(f1, f2);
  }
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);
}
