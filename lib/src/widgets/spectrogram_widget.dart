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
    this.applyDynamicRange = true,
    this.dynamic = 70.0,
    this.maximum = 100.0,
    this.autoscaling = true,
    this.preemphasis = 6.0,
    this.dynamicCompression = 0.0,
  });

  final Spectrogram spectrogram;

  final double tmin;
  final double tmax;

  final double fmin;
  final double fmax;

  final Size size;

  final bool applyDynamicRange;
  final bool autoscaling;

  final double dynamic; // dB
  final double maximum; // dB/Hz
  final double preemphasis; // dB/oct
  final double dynamicCompression; // [0, 1]

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
        tmin: widget.tmin,
        tmax: widget.tmax,
        fmin: widget.fmin,
        fmax: widget.fmax,
      ),
    );
  }
}
