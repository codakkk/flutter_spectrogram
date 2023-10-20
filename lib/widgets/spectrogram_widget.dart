import 'package:flutter/material.dart';

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
    final width = size.width;
    final height = size.height;

    final cellWidth = width / spectrogram.powerSpectrumDensity.length;
    final cellHeight = height / spectrogram.powerSpectrumDensity[0].length;

    for (int t = 0; t < spectrogram.powerSpectrumDensity.length; t++) {
      for (int f = 0; f < spectrogram.powerSpectrumDensity[0].length; f++) {
        final logPower = spectrogram.powerSpectrumDensity[t][f];
        final color = mapIntensityToColor(logPower);

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
  bool shouldRepaint(SpectrogramWidgetPainter oldDelegate) => true;
}
