import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SpectrogramPainter extends CustomPainter {
  SpectrogramPainter({
    required this.data,
    this.dominantColor = Colors.white,
  })  : _numXDivisions = data.length,
        _numYDivisions = data.isEmpty ? 0 : data[0].length;

  final List<Float64List> data;
  final int _numXDivisions;
  final int _numYDivisions;

  final Color dominantColor;

  ui.Image? _backBuffer;

  // y-axis represents frequencies
  // x-axis represents (positive) time
  // intensity of colors represent amplitude of frequencies
  @override
  void paint(Canvas canvas, Size size) {
    _renderToBackBuffer(size);

    if (_backBuffer != null) {
      canvas.drawImage(_backBuffer!, Offset.zero, Paint());
      debugPrint('image');
    }
  }

  void _renderToBackBuffer(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final width = size.width;
    final height = size.height;

    final cellWidth = width / _numXDivisions;
    final cellHeight = height / _numYDivisions;

    // Rotate by 180 degrees
    // This rotation is based on my calculation using fftea package.
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(math.pi);
    canvas.translate(-size.width * 0.5, -size.height * 0.5);

    for (var j = 0; j < _numYDivisions; j++) {
      for (var i = 0; i < _numXDivisions; i++) {
        final intensity = data[i][j];
        final x = i * cellWidth;
        final y = j * cellHeight;

        final neighbour = getNeighborValues(
          i,
          j,
          _numXDivisions,
          _numYDivisions,
        );
        // Adjust the smoothing factor as needed
        final smoothValue = (intensity + neighbour) / 9.0;

        double sy = y + (1.0 - smoothValue) * cellHeight;
        double ey = y + cellHeight;

        if (sy < 0) {
          sy = 0;
        }

        if (ey >= height) {
          ey = height;
        }

        final smoothRect = Rect.fromPoints(
          Offset(x, sy), // Smooth the height of the rectangle
          Offset(x + cellWidth, ey),
        );

        final paint = Paint()..color = dominantColor;
        canvas.drawRect(smoothRect, paint);
      }
    }

    // .toImage(size.width.floor(), size.height.floor());
    final picture = recorder.endRecording();

    _backBuffer = picture.toImageSync(size.width.floor(), size.height.floor());
  }

  double getNeighborValues(
    int x,
    int y,
    int numXDivisions,
    int numYDivisions,
  ) {
    final neighbors = [
      if (x > 0) data[x - 1][y],
      if (x < numXDivisions - 1) data[x + 1][y],
      if (y > 0) data[x][y - 1],
      if (y < numYDivisions - 1) data[x][y + 1],
      if (x > 0 && y > 0) data[x - 1][y - 1],
      if (x > 0 && y < numYDivisions - 1) data[x - 1][y + 1],
      if (x < numXDivisions - 1 && y > 0) data[x + 1][y - 1],
      if (x < numXDivisions - 1 && y < numYDivisions - 1) data[x + 1][y + 1],
    ];

    return neighbors.fold(0.0, (sum, value) => sum + value);
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
