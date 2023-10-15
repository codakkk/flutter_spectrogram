import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/data/fft/fft_table.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_spectrogram/src/log_utils.dart';

// ignore: constant_identifier_names
const double NUMln2 = 0.6931471805599453094172321214581765680755;
// ignore: constant_identifier_names
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
      size,
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
  Size size,
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
  debugPrint('run Spectrogram_paintInside');
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

  final preemphasisFactorBuffer = Float64List(nf);
  final dynamicFactorBuffer = Float64List(nt);

  final tvalue = double.parse("1e-30");
  final t2value = double.parse("4.0e-10");

  final preCalc = preemphasis / NUMln2;

  /* Pre-emphasis in place; also compute maximum after pre-emphasis. */
  for (int ifreq = ifmin; ifreq < ifmax; ++ifreq) {
    final preemphasisValue = preCalc * math.log((ifreq + 1) * dy / 1000.0);
    preemphasisFactorBuffer[ifreq] = preemphasisValue;

    for (int itime = itmin; itime < itmax; ++itime) {
      double value = me.powerSpectrumDensity[ifreq][itime]; // power

      final c = 10.0 * LogUtils.log10((value + tvalue) / t2value) +
          preemphasisValue; // dB

      if (c > dynamicFactorBuffer[itime]) {
        dynamicFactorBuffer[itime] = value;
      }

      final zz = me.powerSpectrumDensity[0][0];
      debugPrint('0:0: $zz');
      if (c > 128) {
        debugPrint('we');
      }

      me.powerSpectrumDensity[ifreq][itime] =
          c.isNaN ? 0.0 : c; // local maximum+
    }
  }

  /* Compute global maximum. */
  if (autoscaling) {
    maximum = 0.0;
    for (int itime = itmin; itime < itmax; itime++) {
      if (dynamicFactorBuffer[itime] > maximum) {
        maximum = dynamicFactorBuffer[itime];
      }
    }
  }

  /* Dynamic compression in place. */
  for (int itime = itmin; itime < itmax; itime++) {
    dynamicFactorBuffer[itime] =
        dynamicCompression * (maximum - dynamicFactorBuffer[itime]);
    for (int ifreq = ifmin; ifreq < ifmax; ifreq++) {
      me.powerSpectrumDensity[ifreq][itime] += dynamicFactorBuffer[itime];
    }
  }

  for (int i = 0; i < greyBrush.length; ++i) {
    greyBrush[i] = Color.fromARGB(255, i, i, i);
  }

  // Canvas qualcosa
  final thepart = part(me.powerSpectrumDensity, ifmin, ifmax, itmin, itmax);
  final minX = me.columnToX(itmin - 0.5);
  final maxX = me.columnToX(itmax + 0.5);
  final minY = me.rowToY(ifmin - 0.5);
  final maxY = me.rowToY(ifmax + 0.5);

  Graphics_image(
    g,
    thepart,
    minX,
    maxX,
    minY,
    maxY,
    maximum - dynamic,
    maximum,
  );

  final width = size.width;
  final height = size.height;

  final _numXDivisions = me.powerSpectrumDensity[0].length;
  final _numYDivisions = me.powerSpectrumDensity.length;

  final cellWidth = width / _numXDivisions;
  final cellHeight = height / _numYDivisions;

  // Rotate by 180 degrees
  // This rotation is based on my calculation using fftea package.
  // canvas.translate(size.width * 0.5, size.height * 0.5);
  // canvas.rotate(-math.pi);
  // canvas.translate(-size.width * 0.5, -size.height * 0.5);
  double minimum = maximum - dynamic;
  double scale = 255.0 / (maximum - minimum);
  double offset = 255.0 + minimum * scale;
  for (var ifreq = 0; ifreq < _numYDivisions; ifreq++) {
    for (var itime = 0; itime < _numXDivisions; itime++) {
      final intensity = me.powerSpectrumDensity[ifreq][itime];
      final x = itime * cellWidth;
      final y = ifreq * cellHeight;

      // Adjust the smoothing factor as needed
      final smoothValue = (intensity) / 9.0;

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

      final paint = Paint()
        ..color = Color.fromARGB(
          255,
          intensity.toInt(),
          intensity.toInt(),
          intensity.toInt(),
        );
      g.drawRect(smoothRect, paint);
    }
  }

  // Graphics_image

  for (int ifreq = ifmin; ifreq < ifmax; ifreq++) {
    for (int itime = itmin; itime < itmax; itime++) {
      final double value = double.parse("4.0e-10") *
              math.exp((me.powerSpectrumDensity[ifreq][itime] -
                      dynamicFactorBuffer[itime] -
                      preemphasisFactorBuffer[ifreq]) *
                  (NUMln10 / 10.0)) -
          double.parse("1e-30");
      me.powerSpectrumDensity[ifreq][itime] =
          (value.isNaN || value < 0.0) ? 0.0 : value;
    }
  }
}

final greyBrush = List.filled(256, Colors.white);

// Those are zoom and movement
const scaleX = 1;
const deltaX = 1;
const scaleY = 1;
const deltaY = 1;

int wdx(double x) => (x * scaleX + deltaX).toInt();
int wdy(double y) => (y * scaleY + deltaY).toInt();

void Graphics_image(
  Canvas canvas,
  List<List<double>> z,
  double x1WC,
  double x2WC,
  double y1WC,
  double y2WC,
  double minimum,
  double maximum,
) {
  // Some checks on z

  _cellArrayOrImage(
    canvas,
    z,
    1,
    z[0].length,
    wdx(x1WC),
    wdx(x2WC),
    1,
    z.length,
    wdy(y1WC),
    wdy(y2WC),
    minimum,
    maximum,
    0, // wdx(my d_x1WC)
    1, // wdx(my d_x2WC)
    0, // wdy(my d_y1WC)
    1, // wdy(my d_y2WC)
    true,
  );
}

void _cellArrayOrImage(
  Canvas canvas,
  List<List<double>> z,
  int ix1,
  int ix2,
  int x1DC,
  int x2DC,
  int iy1,
  int iy2,
  int y1DC,
  int y2DC,
  double minimum,
  double maximum,
  int clipx1,
  int clipx2,
  int clipy1,
  int clipy2,
  bool interpoalte,
) {
  int nx = ix2 - ix1;
  int ny = iy2 - iy1;
  double dx = (x2DC - x1DC) / nx.toDouble();
  double dy = (y2DC - y1DC) / ny.toDouble();
  double scale = 255.0 / (maximum - minimum);
  double offset = 255.0 + minimum * scale;

  if (x2DC <= x1DC || y1DC <= y2DC) return;

  if (clipx1 < x1DC) clipx1 = x1DC;
  if (clipx2 > x2DC) clipx2 = x2DC;
  if (clipy1 > y1DC) clipy1 = y1DC;
  if (clipy2 < y2DC) clipy2 = y2DC;

  for (int yDC = clipy2; yDC < clipy1; yDC++) {
    for (int xDC = clipx1; xDC < clipx2; xDC++) {
      double ixReal = ix1 - 0.5 + (nx * (xDC - x1DC)) / (x2DC - x1DC);
      int ileft = ixReal.floor();
      int iright = ileft + 1;
      double rightWeight = ixReal - ileft;
      double leftWeight = 1.0 - rightWeight;

      if (ileft < ix1) ileft = ix1;
      if (iright > ix2) iright = ix2;

      double iyReal = iy2 + 0.5 - (ny * (yDC - y2DC)) / (y1DC - y2DC);
      int itop = iyReal.ceil();
      int ibottom = itop - 1;
      double bottomWeight = itop - iyReal;
      double topWeight = 1.0 - bottomWeight;

      List<double> ztop = z[itop];
      List<double> zbottom = z[ibottom];
      Color pixelColor;

      for (int x = clipx1; x < clipx2; x++) {
        double interpol = rightWeight *
                (topWeight * ztop[iright] + bottomWeight * zbottom[iright]) +
            leftWeight *
                (topWeight * ztop[ileft] + bottomWeight * zbottom[ileft]);
        double value = offset - scale * interpol;

        // Convert the value to a color based on your logic.
        int c = (255 * value).toInt();
        pixelColor = Color.fromARGB(255, c, c, c);

        // Draw the pixel on the canvas.
        canvas.drawRect(
          Rect.fromPoints(Offset(x.toDouble(), yDC.toDouble()),
              Offset(x.toDouble() + 1.0, yDC.toDouble() + 1.0)),
          Paint()..color = pixelColor,
        );
      }
    }
  }
}

List<List<double>> part(
  List<List<double>> our,
  int firstRow,
  int lastRow,
  int firstCol,
  int lastCol,
) {
  int newNrow = lastRow - firstRow;
  int newNcol = lastCol - firstCol;

  if (newNrow <= 0 || newNcol <= 0) {
    return [];
  }

  assert(firstRow >= 0 && firstRow <= our.length);
  assert(lastRow >= 0 && lastRow <= our.length);
  assert(firstCol >= 0 && firstCol <= our[0].length);
  assert(lastCol >= 0 && lastCol <= our[0].length);

  return our
      .sublist(firstRow, firstRow + newNrow)
      .map((row) => row.sublist(firstCol, firstCol + newNcol))
      .toList();
}
