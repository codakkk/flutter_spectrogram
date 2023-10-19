import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/colour_gradient.dart';
import 'dart:math' as math;

class SpectrogramPainter extends CustomPainter {
  SpectrogramPainter({
    required this.data,
    required this.totalDuration,
    required this.numTimeBins,
    required this.numFrequencyBins,
    required this.minFrequency,
    required this.maxFrequency,
    this.dominantColor = Colors.white,
  });

  final List<List<double>> data;

  final double totalDuration; // Total duration of the audio
  final int numTimeBins; // Total number of time bins in the spectrogram
  final int numFrequencyBins;
  final double minFrequency; // Minimum frequency represented
  final double maxFrequency; // Maximum frequency represented

  final Color dominantColor;

  final ColourGradient gradient = ColourGradient.audacity();

  // y-axis represents frequencies
  // x-axis represents (positive) time
  // intensity of colors represent amplitude of frequencies
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final cellWidth = width / numTimeBins;
    final cellHeight = height / numFrequencyBins;

    double min = 999999999.0;
    double max = -999999999.0;
    for (final list in data) {
      min = list.fold(min, (value, element) => math.min(value, element));
      max = list.fold(max, (value, element) => math.max(value, element));
    }
    gradient.min = min;
    gradient.max = max;

    for (int t = 0; t < data.length; t++) {
      for (int f = 0; f < data[0].length; f++) {
        final logPower = data[t][f];
        final color =
            gradient.getColour(logPower); // mapIntensityToColor(logPower);

        final rect = Rect.fromPoints(
          Offset(t * cellWidth, height - f * cellHeight),
          Offset((t + 1) * cellWidth, height - (f + 1) * cellHeight),
        );

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, paint);
      }
    }
  }

  Color mapIntensityToColor(double intensity) {
    // Map intensity to grayscale color (black to white)
    final grayValue = !intensity.isFinite ? 0 : (intensity * 255).toInt();

    return Color.fromARGB(255, grayValue, grayValue, grayValue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! SpectrogramPainter) {
      return false;
    }
    return data != oldDelegate.data ||
        dominantColor != oldDelegate.dominantColor;
  }
}
