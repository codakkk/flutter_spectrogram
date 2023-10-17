import 'dart:ui' as ui;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/colour_gradient.dart';
import 'package:flutter_spectrogram/src/data/frequency_scale.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';

class SpectrogramPainter extends CustomPainter {
  SpectrogramPainter({
    required this.data,
    required this.gradient,
  });

  final SpectrogramData data;
  final ColourGradient gradient;

  // y-axis represents frequencies
  // x-axis represents (positive) time
  // intensity of colors represent amplitude of frequencies
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Render background
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final buffer = data.toBuffer(FrequencyScale.linear);

    final width = size.width;
    final height = size.height;

    final cellWidth = width / data.width;
    final cellHeight = height / data.height;

    for (var iFreq = 0; iFreq < data.height; iFreq++) {
      for (var iTime = 0; iTime < data.width; iTime++) {
        final intensity = buffer[iTime + iFreq * data.width];
        final color = gradient.getColour(intensity);

        final x = iTime * cellWidth;
        final y = iFreq * cellHeight;

        final smoothRect = Rect.fromPoints(
          Offset(x, y), // Smooth the height of the rectangle
          Offset(x + cellWidth, y + cellHeight),
        );

        canvas.drawRect(
          smoothRect,
          paint
            ..color = color
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! SpectrogramPainter) {
      return false;
    }
    return data != oldDelegate.data || gradient != oldDelegate.gradient;
  }
}

/*
  void _renderToBackBuffer(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final width = size.width;
    final height = size.height;

    final cellWidth = width / _numXDivisions;
    final cellHeight = height / _numYDivisions;

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

        double sy = y + (1.0 - intensity) * cellHeight;
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

        final paint = Paint()..color = colours.getColour(intensity);
        canvas.drawRect(smoothRect, paint);
      }
    }

    // .toImage(size.width.floor(), size.height.floor());
    final picture = recorder.endRecording();

    _backBuffer = picture.toImageSync(size.width.floor(), size.height.floor());
  }
*/
