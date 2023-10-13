import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/data/fft/fft_table.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';

class SpectrogramPainter extends CustomPainter {
  SpectrogramPainter({
    required this.tmin,
    required this.tmax,
    required this.fmin,
    required this.fmax,
    required this.data,
    this.dominantColor = Colors.white,
  });

  final double tmin;
  final double tmax;

  final double fmin;
  final double fmax;

  final SpectrogramData data;

  final Color dominantColor;

  ui.Image? _backBuffer;

  // y-axis represents frequencies
  // x-axis represents (positive) time
  // intensity of colors represent amplitude of frequencies
  @override
  void paint(Canvas canvas, Size size) {
    final (tmin, tmax) = data.unidirectionalAutowindow(this.tmin, this.tmax);
    final (fmin, fmax) = data.unidirectionalAutowindowY(this.fmin, this.fmax);

    final dx = data.timeBetweenTimeSlices;
    final dy = data.frequencyStepHz;

    final (nt, itmin, itmax) =
        data.getWindowSamplesX(tmin - 0.49999 * dx, tmax + 0.49999 * dx);
    final (nf, ifmin, ifmax) =
        data.getWindowSamplesY(fmin - 0.49999 * dy, fmax + 0.49999 * dy);

    if (nt == 0 || nf == 0) {
      return;
    }

    // Graphics_setWindow(g, tmin, tmax, fmin, fmax)

    final preemphasisFactorBuffer = List<double>.filled(nf, 0);
    final dynamicFactorBuffer = List<double>.filled(nt, 0);

    ListWithOffset<double> preemphasisFactor =
        preemphasisFactorBuffer.offset(1 - ifmin);
    ListWithOffset<double> dynamicFactor =
        preemphasisFactorBuffer.offset(1 - itmin);
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
