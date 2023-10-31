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
    required this.lineColor,
    this.dynamic = 70.0,
    this.maximum = 100.0,
    this.autoscaling = true,
    this.preemphasis = 6.0,
    this.dynamicCompression = 0.0,
    this.selectedFrequency = 0,
  });

  final Spectrogram spectrogram;

  final double tmin;
  final double tmax;

  final double fmin;
  final double fmax;

  final int selectedFrequency;
  final Color lineColor;

  final Size size;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${widget.fmax} Hz'),
            const SizedBox(width: 16),
            Text(
              '${widget.selectedFrequency} Hz',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: widget.lineColor,
                  ),
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Derived Spectrogram',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
        CustomPaint(
          size: widget.size,
          painter: SpectrogramWidgetPainter(
            spectrogram: widget.spectrogram,
            tmin: widget.tmin,
            tmax: widget.tmax,
            fmin: widget.fmin,
            fmax: widget.fmax,
            dynamic: widget.dynamic,
            maximum: widget.maximum,
            preemphasis: widget.preemphasis,
            dynamicCompression: widget.dynamicCompression,
            selectedFrequency: widget.selectedFrequency,
            lineColor: widget.lineColor,
          ),
        ),
        Text('${widget.fmin} Hz'),
      ],
    );
  }
}
