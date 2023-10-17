import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:flutter_spectrogram/src/colour_gradient.dart';
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

  Float64List toBuffer(FrequencyScale frequencyScale) {
    Float64List buf = Float64List(width * height);

    switch (frequencyScale) {
      case FrequencyScale.logarithm:
        final scaler = FrequencyScaler.create(
          frequencyScale,
          width.toDouble(),
          height.toDouble(),
        );

        final vertSlice = Float64List(height);
        int pos = 0;

        for (int h = 0; h < height; ++h) {
          final (f1, f2) = scaler.scale(h);

          final h1 = f1.isFinite ? f1.floor() : 0;
          int h2 = f2.isFinite ? f2.ceil() : 0;

          if (h2 >= height) {
            h2 = height - 1;
          }

          for (int w = 0; w < width; w++) {
            for (int hh = h1; hh < h2; hh++) {
              vertSlice[hh - h1] = spec[(hh * width) + w];
            }
            double value = integrate(f1, f2, vertSlice);
            buf[pos++] = value;
          }
        }
        break;
      case FrequencyScale.linear:
        buf = spec.sublist(0);
        break;
    }

    toDb();

    return buf;
  }

  img.Image toImageInMemory(
    int imgWidth,
    int imgHeight,
    ColourGradient gradient,
  ) {
    final buf = toBuffer(FrequencyScale.logarithm);
    final image = img.Image(
      width: imgWidth,
      height: imgHeight,
      numChannels: 4,
      format: img.Format.uint8,
    );

    Uint8List list = Uint8List(4 * imgWidth * imgHeight);
    bufToImage(buf, list, gradient);

    for (final pixel in image) {
      int index = pixel.x + pixel.y * width;

      pixel
        ..r = list[index + 0]
        ..g = list[index + 1]
        ..b = list[index + 2]
        ..a = list[index + 3];
    }

    return image;
  }

  void bufToImage(Float64List buf, Uint8List img, ColourGradient gradient) {
    final (min, max) = getMinMax();
    gradient.min = min;
    gradient.max = max;

    final channels = buf
        .map((e) => gradient.getColour(e))
        .expand((e) => [e.red, e.green, e.blue, e.alpha])
        .toList();

    for (int i = 0; i < channels.length; ++i) {
      if (i >= img.length) {
        break;
      }
      img[i] = channels[i];
    }
  }

  (double min, double max) getMinMax() {
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (final v in spec) {
      min = math.min(v, min);
      max = math.max(v, max);
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
}

extension Logarithm on num {
  //double logBase(num x, num base) => math.log(x) / math.log(base);
  //double log10(num x) => math.log(x) / math.ln10;

  double log(num base) => math.log(this) / math.log(base);
  double log10() => log(10);
}

double integrate(double x1, double x2, Float64List spec) {
  x1 = x1.isFinite ? x1 : 0.0;
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

extension Float64ListX on Float64List {}
