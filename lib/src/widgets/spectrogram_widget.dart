import 'package:flutter/material.dart';

import '../models/spectrogram.dart';
import '../painters/spectrogram_widget_painter.dart';

class SpectrogramWidget extends StatefulWidget {
  const SpectrogramWidget({
    super.key,
    required this.spectrogram,
    required this.size,
    required this.tmin,
    required this.tmax,
    required this.fmin,
    required this.fmax,
    this.applyDynamicRange = false,
  });

  final Spectrogram spectrogram;

  final double tmin;
  final double tmax;

  final double fmin;
  final double fmax;

  final Size size;
  final bool applyDynamicRange;

  @override
  State<SpectrogramWidget> createState() => _SpectrogramWidgetState();
}

class _SpectrogramWidgetState extends State<SpectrogramWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: SpectrogramWidgetPainter(
        spectrogram: widget.spectrogram,
        applyDynamicRange: widget.applyDynamicRange,
        tmin: widget.tmin,
        tmax: widget.tmax,
        fmin: widget.fmin,
        fmax: widget.fmax,
      ),
    );
  }
}
