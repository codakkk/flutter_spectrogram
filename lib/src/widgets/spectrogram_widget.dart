import 'package:flutter/material.dart';

import '../models/spectrogram.dart';
import '../painters/spectrogram_widget_painter.dart';

class SpectrogramWidget extends StatefulWidget {
  const SpectrogramWidget({
    super.key,
    required this.spectrogram,
    required this.size,
    this.zoom = 1.0,
    this.applyDynamicRange = false,
  });

  final Spectrogram spectrogram;
  final double zoom;
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
        zoom: widget.zoom,
        applyDynamicRange: widget.applyDynamicRange,
      ),
    );
  }
}
