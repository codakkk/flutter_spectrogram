import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_spectrogram/src/spectrogram_options.dart';
import 'package:flutter_spectrogram/src/spectrogram_painter.dart';
import 'package:wav/wav.dart';

import 'colour_gradient.dart';
import 'data/spec_options_builder.dart';
import 'window_type.dart';

class Spectrogram extends StatefulWidget {
  const Spectrogram({
    super.key,
    required this.audio,
    required this.width,
    required this.height,
    required this.loadingBuilder,
    this.options = const SpectrogramOptions(
      chunkSize: 1024,
      chunkStride: 512,
      windowType: WindowType.hanning,
    ),
  });

  final double width;
  final double height;

  final Wav audio;

  final SpectrogramOptions options;

  final Widget Function(BuildContext context) loadingBuilder;

  @override
  State<Spectrogram> createState() => _SpectrogramState();
}

class _SpectrogramState extends State<Spectrogram> {
  final gradient = ColourGradient.whiteBlack();

  bool _isProcessing = true;
  SpectrogramData? _spectrogramData;

  @override
  void initState() {
    super.initState();

    _processSamples();
  }

  @override
  void didUpdateWidget(covariant Spectrogram oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.audio != oldWidget.audio ||
        widget.options != oldWidget.options) {
      _processSamples();
    }
  }

  void _processSamples() {
    setState(() {
      _isProcessing = true;
    });

    final samples = widget.audio.toMono();

    final builder = SpecOptionsBuilder(
      data: samples,
      sampleRate: widget.audio.samplesPerSecond.toDouble(),
      doNormalize: true,
      numBins: widget.options.chunkSize,
      stepSize: widget.options.chunkStride,
      windowFn: WindowType.gaussian.apply(widget.options.chunkSize),
    );

    final spectrogramData = builder.build()!.compute();

    setState(() {
      _isProcessing = false;
      _spectrogramData = spectrogramData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing && _spectrogramData == null) {
      return widget.loadingBuilder(context);
    }
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        isComplex: true,
        painter: SpectrogramPainter(
          data: _spectrogramData!,
          gradient: gradient,
        ),
      ),
    );
  }
}
