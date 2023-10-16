import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_spectrogram/src/data/frequency_scale.dart';
import 'package:flutter_spectrogram/src/data/frequency_scaler.dart';

class SpectrogramData {
  const SpectrogramData({
    required this.width,
    required this.height,
    required this.spec,
  });

  final int width;
  final int height;
  final Float64List spec;

  Float64List toBuffer(
    FrequencyScale frequencyScale,
    int imgWidth,
    int imgHeight,
  ) {
    Float64List buf = Float64List(width * height);

    switch (frequencyScale) {
      case FrequencyScale.logarithm:
        final scaler = FrequencyScaler.create(
          frequencyScale,
          width.toDouble(),
          height.toDouble(),
        );

        final vertSlice = Float64List(height);

        for (int h = 0; h < vertSlice.length; ++h) {
          final tuple = scaler.scale(h);

          double f1 = tuple.item1;
          double f2 = tuple.item2;
          int h1 = f1.floor().toInt();
          int h2 = f2.ceil().toInt();

          if (h2 >= height) {
            h2 = height - 1;
          }

          for (int w = 0; w < width; w++) {
            for (int hh = h1; hh < h2; hh++) {
              vertSlice[hh - h1] = spec[(hh * width) + w];
            }
            double value = integrate(f1, f2, vertSlice);
            buf.add(value);
          }
        }
        break;
      case FrequencyScale.linear:
        buf = spec.sublist(0);
        break;
    }

    toDb();
    resize(width, height, imgWidth, imgHeight);
  }

  Float64List resize(int wIn, int wIn, int wOut, int hOut) {}

  (double min, double max) getMinMax() {
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (final v in spec) {
      min = math.min(v, min);
      max = math.min(v, max);
    }

    return (min, max);
  }

  void toDb() {
    double refDb = double.negativeInfinity;

    for (double v in spec) {
      refDb = v > refDb ? v : refDb;
    }

    double ampRef = refDb * refDb;
    double offset = 10.0 * (math.max(1e-10, ampRef)).log10();
    double logSpecMax = double.negativeInfinity;

    for (int i = 0; i < spec.length; i++) {
      double val = spec[i];
      spec[i] = 10.0 * (math.max(1e-10, val * val)).log(10) - offset;
      logSpecMax = math.max(val, logSpecMax);
    }

    for (int i = 0; i < spec.length; i++) {
      spec[i] = math.max(spec[i], logSpecMax - 80.0);
    }
  }

  double integrate(double x1, double x2, Float64List spec) {
    int iX1 = x1.floor();
    int iX2 = (x2 - 0.000001).floor();

    double area(num y, double frac) => y * frac;

    if (iX1 >= iX2) {
      // Sub-cell integration
      return area(spec[iX1], x2 - x1);
    } else {
      // Need to integrate from x1 to x2 over multiple indices.
      double result = area(spec[iX1], (iX1 + 1 - x1).toDouble());
      iX1++;
      while (iX1 < iX2) {
        result += spec[iX1];
        iX1++;
      }
      if (iX1 >= spec.length) {
        iX1 = spec.length - 1;
      }
      result += area(spec[iX1], x2 - iX1.toDouble());
      return result;
    }
  }
}

extension Logarithm on num {
  //double logBase(num x, num base) => math.log(x) / math.log(base);
  //double log10(num x) => math.log(x) / math.ln10;

  double log(num base) => math.log(this) / math.log(base);
  double log10() => log(10);
}
