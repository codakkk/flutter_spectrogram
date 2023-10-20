import 'package:flutter/material.dart';

import '../models/colour_gradient.dart';
import '../models/spectrogram.dart';

class SpectrogramWidgetPainter extends CustomPainter {
  const SpectrogramWidgetPainter(this.spectrogram);

  final Spectrogram spectrogram;

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = ColourGradient.whiteBlack();

    double min = spectrogram.powerSpectrumDensity[0][0];
    double max = spectrogram.powerSpectrumDensity[0][0];

    for (var row in spectrogram.powerSpectrumDensity) {
      for (var value in row) {
        if (value < min) {
          min = value;
        }
        if (value > max) {
          max = value;
        }
      }
    }

    gradient.min = min;
    gradient.max = max;

    final width = size.width;
    final height = size.height;

    final timeBin = spectrogram.powerSpectrumDensity.length;
    final frequenciesBin = spectrogram.numberOfFreqs;

    final cellWidth = width / timeBin;
    final cellHeight = height / frequenciesBin;

    // spectrogram.powerSpectrumDensity[0].length;
    for (int t = 0; t < timeBin; t++) {
      for (int f = 0; f < frequenciesBin; f++) {
        final intensity = spectrogram.powerSpectrumDensity[t][f];
        final color = gradient.getColour(intensity);

        // height - f * cellHeight is because Canvas renders from top to bottom
        // we just render up-side down
        // +1 and -1 on both x and y of the second offset
        // is just to removed those lines between rectangles
        final rect = Rect.fromPoints(
          Offset(t * cellWidth, height - f * cellHeight),
          Offset(
            ((t + 1) * cellWidth).ceilToDouble(),
            (height - (f + 1) * cellHeight).floorToDouble(),
          ),
        );

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SpectrogramWidgetPainter oldDelegate) => true;
}
