import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/data/fft/fft_table.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';

const double NUMln2 = 0.6931471805599453094172321214581765680755;
const double NUMln10 = 2.3025850929940456840179914546843642076011;

class SpectrogramPainter extends CustomPainter {
  SpectrogramPainter({
    required this.tmin,
    required this.tmax,
    required this.fmin,
    required this.fmax,
    required this.data,
    required this.preemphasis,
    required this.autoscaling,
    required this.dynamic,
    required this.maximum,
    required this.dynamicCompression,
    this.dominantColor = Colors.white,
  });

  final double tmin;
  final double tmax;

  final double fmin;
  final double fmax;

  final double dynamic;
  final double maximum;
  final double dynamicCompression;
  final double preemphasis;
  final bool autoscaling;

  final SpectrogramData data;

  final Color dominantColor;

  ui.Image? _backBuffer;

  // y-axis represents frequencies
  // x-axis represents (positive) time
  // intensity of colors represent amplitude of frequencies
  @override
  void paint(Canvas canvas, Size size) {
    Spectrogram_paintInside(
      data,
      canvas,
      tmin,
      tmax,
      fmin,
      fmax,
      maximum,
      autoscaling,
      dynamic,
      preemphasis,
      dynamicCompression,
    );
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

void Spectrogram_paintInside(
  SpectrogramData me,
  Canvas g,
  double tmin,
  double tmax,
  double fmin,
  double fmax,
  double maximum,
  bool autoscaling,
  double dynamic,
  double preemphasis,
  double dynamicCompression,
) {
  final (ttmin, ttmax) = me.unidirectionalAutowindow(tmin, tmax);
  final (ffmin, ffmax) = me.unidirectionalAutowindowY(fmin, fmax);

  final dx = me.timeBetweenTimeSlices;
  final dy = me.frequencyStepHz;

  final (nt, itmin, itmax) =
      me.getWindowSamplesX(ttmin - 0.49999 * dx, ttmax + 0.49999 * dx);
  final (nf, ifmin, ifmax) =
      me.getWindowSamplesY(ffmin - 0.49999 * dy, ffmax + 0.49999 * dy);

  if (nt == 0 || nf == 0) {
    return;
  }

  // Graphics_setWindow(g, ttmin, ttmax, ffmin, ffmax)

  final preemphasisFactorBuffer = List<double>.filled(nf, 0);
  final dynamicFactorBuffer = List<double>.filled(nt, 0);

  ListWithOffset<double> preemphasisFactor =
      preemphasisFactorBuffer.offset(1 - ifmin);
  ListWithOffset<double> dynamicFactor =
      preemphasisFactorBuffer.offset(1 - itmin);

  /* Pre-emphasis in place; also compute maximum after pre-emphasis. */
  for (int ifreq = ifmin; ifreq < ifmax; ifreq++) {
    preemphasisFactor[ifreq] =
        (preemphasis / NUMln2) * math.log(ifreq * dy / 1000.0);
    for (int itime = itmin; itime < itmax; itime++) {
      double value = me.powerSpectrumDensity[ifreq][itime]; // power
      value = (10.0 / NUMln10) * math.log((value + 1e-30) / 4.0e-10) +
          preemphasisFactor[ifreq]; // dB
      if (value > dynamicFactor[itime - 1]) {
        dynamicFactor[itime] = value;
      }
      me.powerSpectrumDensity[ifreq][itime] = value; // local maximum
    }
  }

  /* Compute global maximum. */
  if (autoscaling) {
    maximum = 0.0;
    for (int itime = itmin - 1; itime < itmax; itime++) {
      if (dynamicFactor[itime] > maximum) {
        maximum = dynamicFactor[itime];
      }
    }
  }

  /* Dynamic compression in place. */
  for (int itime = itmin; itime < itmax; itime++) {
    dynamicFactor[itime] =
        dynamicCompression * (maximum - dynamicFactor[itime]);
    for (int ifreq = ifmin; ifreq < ifmax; ifreq++) {
      me.powerSpectrumDensity[ifreq][itime] += dynamicFactor[itime];
    }
  }

  // Canvas qualcosa
  final thepart = part(me.powerSpectrumDensity, ifmin, ifmax, itmin, itmax);
  final a = me.columnToX(itmin - 0.5);
  final b = me.columnToX(itmax + 0.5);
  final c = me.rowToY(ifmin - 0.5);
  final d = me.rowToY(ifmax + 0.5);

  for (int ifreq = ifmin; ifreq < ifmax; ifreq++) {
    for (int itime = itmin; itime < itmax; itime++) {
      final double value = 4.0e-10 *
              math.exp((me.powerSpectrumDensity[ifreq][itime] -
                      dynamicFactor[itime] -
                      preemphasisFactor[ifreq]) *
                  (NUMln10 / 10.0)) -
          1e-30;
      me.powerSpectrumDensity[ifreq][itime] = value < 0.0 ? 0.0 : value;
    }
  }
}

List<List<double>> part(List<List<double>> our, int firstRow, int lastRow,
    int firstCol, int lastCol) {
  int newNrow = lastRow - (firstRow - 1);
  int newNcol = lastCol - (firstCol - 1);

  if (newNrow <= 0 || newNcol <= 0) {
    return [];
  }

  assert(firstRow >= 1 && firstRow <= our.length);
  assert(lastRow >= 1 && lastRow <= our.length);
  assert(firstCol >= 1 && firstCol <= our[0].length);
  assert(lastCol >= 1 && lastCol <= our[0].length);

  return our
      .sublist(firstRow - 1, firstRow - 1 + newNrow)
      .map((row) => row.sublist(firstCol - 1, firstCol - 1 + newNcol))
      .toList();
}
