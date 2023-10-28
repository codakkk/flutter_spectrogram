import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../models/colour_gradient.dart';
import '../models/spectrogram.dart';

class SpectrogramWidgetPainter extends CustomPainter {
  SpectrogramWidgetPainter({
    required this.spectrogram,
    required this.tmin,
    required this.tmax,
    required this.fmin,
    required this.fmax,
    this.dynamic = 70.0,
    this.maximum = 100.0,
    this.autoscaling = true,
    this.preemphasis = 6.0,
    this.dynamicCompression = 0.0,
    this.useCustomShader = true,
  });

  final Spectrogram spectrogram;

  final double tmin;
  final double tmax;
  final double fmin;
  final double fmax;

  final bool autoscaling;

  final double dynamic; // dB
  final double maximum; // dB/Hz
  final double preemphasis; // dB/oct
  final double dynamicCompression; // [0, 1]

  final bool useCustomShader;

  // Those shouldn't be static
  // but who knows, CustomPainters are recreated each time
  // they're built lol
  static Float32List? _positionsBuffer;
  static Int32List? _colorsBuffer;

  /*double colToX(double col) =>
        spectrogram.centerOfFirstTimeSlice +
        (col - 1.0) * spectrogram.timeBetweenTimeSlices;

    double rowToY(double row) =>
        spectrogram.centerOfFirstFrequencyBandHz +
        (row - 1.0) * spectrogram.frequencyStepHz;*/

  @override
  void paint(Canvas canvas, Size size) {
    double currentMaximum = maximum;

    final gradient = ColourGradient.whiteBlack();

    final (nt, itmin, itmax) = spectrogram.getWindowSamplesX(
      tmin - 0.49999 * spectrogram.timeBetweenTimeSlices,
      tmax + 0.49999 * spectrogram.timeBetweenTimeSlices,
    );

    final (nf, ifmin, ifmax) = spectrogram.getWindowSamplesY(
      fmin - 0.49999 * spectrogram.frequencyStepHz,
      fmax + 0.49999 * spectrogram.frequencyStepHz,
    );

    if (nt == 0 || nf == 0) {
      return;
    }

    final workedPower = spectrogram.powerSpectrumDensity.sublist(itmin, itmax);
    for (int i = 0; i < workedPower.length; ++i) {
      workedPower[i] = workedPower[i].sublist(0);
    }

    final dynamicFactor = List.filled(nt, 0.0);

    const e1 = 1 / (1e30);
    const e2 = 4 / (1e10);
    const numLN10 = 2.302585092994046;
    const numLN2 = 0.6931471805599453;

    /* Pre-emphasis; also compute maximum after pre-emphasis. -*/
    for (int ifreq = 0; ifreq < nf; ++ifreq) {
      final preemphasisFactor = (preemphasis / numLN2) *
          math.log((ifreq + 1) * spectrogram.frequencyStepHz / 1000.0);
      for (int itime = 0; itime < nt; ++itime) {
        double power = workedPower[itime][ifreq];

        double tl = math.log(((power + e1) / e2));
        power = (10 / numLN10) * tl + preemphasisFactor; // dB

        // power = 10 * (math.log(power) / math.ln10);
        if (power > dynamicFactor[itime]) {
          dynamicFactor[itime] = power; // local maximum
        }

        workedPower[itime][ifreq] = power;
      }
    }

    /* Compute global maximum. */
    if (autoscaling) {
      currentMaximum = 0.0;
      for (int itime = 0; itime < nt; ++itime) {
        if (dynamicFactor[itime] > maximum) {
          currentMaximum = dynamicFactor[itime];
        }
      }
    }

    /* Dynamic compression  */
    for (int itime = 0; itime < nt; itime++) {
      dynamicFactor[itime] =
          dynamicCompression * (currentMaximum - dynamicFactor[itime]);
      for (int ifreq = 0; ifreq < nf; ++ifreq) {
        workedPower[itime][ifreq] += dynamicFactor[itime];
      }
    }

    gradient.min = currentMaximum - dynamic;
    gradient.max = currentMaximum;

    if (useCustomShader) {
      _newRendering(
        canvas,
        size,
        nt,
        nf,
        workedPower,
        gradient,
      );
    } else {
      _oldRendering(
        canvas,
        size,
        nt,
        nf,
        workedPower,
        gradient,
      );
    }
  }

  void _oldRendering(
    Canvas canvas,
    Size size,
    int nt,
    int nf,
    List<List<double>> intensity,
    ColourGradient gradient,
  ) {
    final width = size.width;
    final height = size.height;

    final cellWidth = width / nt;
    final cellHeight = height / nf;
    for (int t = 0; t < nt; t++) {
      for (int f = 0; f < nf; f++) {
        // Power
        double value = intensity[t][f];

        final color = gradient.getColour(value);

        // height - f * cellHeight is because Canvas renders from top to bottom
        // we just render up-side down
        // +1 and -1 on both x and y of the second offset
        // is just to removed those lines between rectangles
        final rect = Rect.fromPoints(
          Offset((t) * cellWidth, height - f * cellHeight),
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

  void _newRendering(
    Canvas canvas,
    Size size,
    int nt,
    int nf,
    List<List<double>> intensity,
    ColourGradient gradient,
  ) {
    final width = size.width;
    final height = size.height;

    final cellWidth = width / nt;
    final cellHeight = height / nf;

    int positionsSize = nt * nf * 6 * 2;
    int colorsSize = nt * nf * 6;

    if (_positionsBuffer == null || _positionsBuffer!.length < positionsSize) {
      _positionsBuffer = Float32List(positionsSize);
    }

    if (_colorsBuffer == null || _colorsBuffer!.length < colorsSize) {
      _colorsBuffer = Int32List(colorsSize);
    }

    final positions = _positionsBuffer!;
    final colors = _colorsBuffer!;

    for (int t = 0; t < nt; ++t) {
      for (int f = 0; f < nf; ++f) {
        // Power
        double value = intensity[t][f];

        final color = gradient.getColour(value);

        // height - f * cellHeight is because Canvas renders from top to bottom
        // we just render up-side down
        // +1 and -1 on both x and y of the second offset
        // is just to removed those lines between rectangles
        final top = height - f * cellHeight;
        final bottom = height - (f + 1) * cellHeight;
        final left = t * cellWidth;
        final right = (t + 1) * cellWidth;

        final baseIndex = (t + f * nt) * 12;

        // Top-Left vertex
        positions[baseIndex + 0] = left;
        positions[baseIndex + 1] = top;

        // Top-Right vertex
        positions[baseIndex + 2] = right;
        positions[baseIndex + 3] = top;
        // Bottom-Left vertex
        positions[baseIndex + 4] = left;
        positions[baseIndex + 5] = bottom;
        // Bottom-Right vertex
        positions[baseIndex + 6] = right;
        positions[baseIndex + 7] = top;
        // Top-Right vertex
        positions[baseIndex + 8] = right;
        positions[baseIndex + 9] = bottom;
        // Bottom-Left vertex
        positions[baseIndex + 10] = left;
        positions[baseIndex + 11] = bottom;

        final colorBaseIndex = (t + f * nt) * 6;
        colors[colorBaseIndex + 0] = color.value;
        colors[colorBaseIndex + 1] = color.value;
        colors[colorBaseIndex + 2] = color.value;
        colors[colorBaseIndex + 3] = color.value;
        colors[colorBaseIndex + 4] = color.value;
        colors[colorBaseIndex + 5] = color.value;
      }
    }
    final vertices = Vertices.raw(
      VertexMode.triangles,
      Float32List.sublistView(_positionsBuffer!, 0, positionsSize),
      colors: Int32List.sublistView(_colorsBuffer!, 0, colorsSize),
    );
    canvas.drawVertices(
      vertices,
      BlendMode.dstIn,
      Paint()..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(SpectrogramWidgetPainter oldDelegate) {
    final r = oldDelegate.fmin != fmin ||
        oldDelegate.fmax != fmax ||
        oldDelegate.tmin != tmin ||
        oldDelegate.tmax != tmax ||
        oldDelegate.preemphasis != preemphasis ||
        oldDelegate.dynamic != dynamic ||
        oldDelegate.autoscaling != autoscaling ||
        oldDelegate.dynamicCompression != dynamicCompression;
    return r;
  }
}
