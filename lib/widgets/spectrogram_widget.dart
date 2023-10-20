import 'package:flutter/material.dart';

import '../models/spectrogram.dart';
import '../painters/spectrogram_widget_painter.dart';

class SpectrogramWidget extends StatefulWidget {
  const SpectrogramWidget({
    super.key,
    required this.spectrogram,
    required this.size,
  });

  final Spectrogram spectrogram;
  final Size size;

  @override
  State<SpectrogramWidget> createState() => _SpectrogramWidgetState();
}

class _SpectrogramWidgetState extends State<SpectrogramWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: SpectrogramWidgetPainter(widget.spectrogram),
    );
  }
}
