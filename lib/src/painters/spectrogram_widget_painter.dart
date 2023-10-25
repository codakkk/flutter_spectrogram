import 'package:flutter/material.dart';

import '../models/colour_gradient.dart';
import '../models/spectrogram.dart';

class SpectrogramWidgetPainter extends CustomPainter {
  const SpectrogramWidgetPainter({
    required this.spectrogram,
    required this.zoom,
    this.applyDynamicRange = false,
  });

  final Spectrogram spectrogram;
  final double zoom;

  final bool applyDynamicRange;

  // We need to adjust rendering based on Max Frequency
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = ColourGradient.whiteBlack();

    double minFreq = spectrogram.powerSpectrumDensity[0][0];
    double maxFreq = spectrogram.powerSpectrumDensity[0][0];

    for (var row in spectrogram.powerSpectrumDensity) {
      for (var value in row) {
        if (value < minFreq) {
          minFreq = value;
        }
        if (value > maxFreq) {
          maxFreq = value;
        }
      }
    }

    if (applyDynamicRange) {
      gradient.min = 0.0;
      gradient.max = 1.0;
    } else {
      gradient.min = minFreq;
      gradient.max = maxFreq;
    }

    final width = size.width;
    final height = size.height;

    final timeBin = spectrogram.powerSpectrumDensity.length;
    final frequenciesBin = spectrogram.numberOfFreqs;

    int zoomedTimeBin = (timeBin / zoom).floor();
    // Calculate the center point
    int centerTimeBin = timeBin ~/ 2;

    final int freqBins = frequenciesBin ~/ 2;

    // Calculate the starting and ending indices for the visible time bins
    int visibleTimeStart = centerTimeBin - zoomedTimeBin ~/ 2;
    int visibleTimeEnd = centerTimeBin + (zoomedTimeBin + 1) ~/ 2;
    final cellWidth = width / zoomedTimeBin;
    final cellHeight = height / (freqBins);

    //final zoomedSeconds = 2 * (spectrogram.tmax / (2.0 * zoom));
    // spectrogram.powerSpectrumDensity[0].length;

    for (int t = visibleTimeStart; t < visibleTimeEnd; t++) {
      for (int f = 0; f < freqBins; f++) {
        // Power
        double intensity = spectrogram.powerSpectrumDensity[t][f];

        if (applyDynamicRange) {
          intensity = (intensity - minFreq) / (maxFreq - minFreq);
        }

        final color = gradient.getColour(intensity);

        // height - f * cellHeight is because Canvas renders from top to bottom
        // we just render up-side down
        // +1 and -1 on both x and y of the second offset
        // is just to removed those lines between rectangles
        final rect = Rect.fromPoints(
          Offset((t - visibleTimeStart) * cellWidth, height - f * cellHeight),
          Offset(
            ((t - visibleTimeStart + 1) * cellWidth).ceilToDouble(),
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
