import 'package:flutter/material.dart';

import '../models/colour_gradient.dart';
import '../models/spectrogram.dart';

class SpectrogramWidget extends StatefulWidget {
  const SpectrogramWidget({
    super.key,
    required this.spectrogram,
  });

  final Spectrogram spectrogram;

  @override
  State<SpectrogramWidget> createState() => _SpectrogramWidgetState();
}

class _SpectrogramWidgetState extends State<SpectrogramWidget> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return CustomPaint(
      size: Size(mediaQuery.size.width, 300),
      painter: SpectrogramWidgetPainter(widget.spectrogram),
    );
  }
}

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

    final cellWidth = width / spectrogram.powerSpectrumDensity.length;
    final cellHeight = height / spectrogram.powerSpectrumDensity[0].length;

    for (int t = 0; t < spectrogram.powerSpectrumDensity.length; t++) {
      for (int f = 0; f < spectrogram.powerSpectrumDensity[0].length; f++) {
        final intensity = spectrogram.powerSpectrumDensity[t][f];
        final color = gradient.getColour(intensity);

        // height - f * cellHeight is because Canvas renders from top to bottom
        // we just render up-side down
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

  @override
  bool shouldRepaint(SpectrogramWidgetPainter oldDelegate) => true;
}
