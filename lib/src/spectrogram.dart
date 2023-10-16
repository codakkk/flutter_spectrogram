import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/spectrogram_options.dart';
import 'package:flutter_spectrogram/src/spectrogram_painter.dart';

import 'window_type.dart';

class Spectrogram extends StatefulWidget {
  const Spectrogram({
    super.key,
    required this.width,
    required this.height,
    required this.samples,
    required this.loadingBuilder,
    this.options = const SpectrogramOptions(
      chunkSize: 1024,
      chunkStride: 512,
      windowType: WindowType.hanning,
    ),
    this.processChunk,
  });

  final double width;
  final double height;

  final SpectrogramOptions options;

  final List<double> samples;

  final Widget Function(BuildContext context) loadingBuilder;
  final Float64List Function(Float64List amplitudes)? processChunk;

  @override
  State<Spectrogram> createState() => _SpectrogramState();
}

class _SpectrogramState extends State<Spectrogram> {
  bool _isProcessing = true;

  List<Float64List> _data = [];

  late final STFT _stft;

  @override
  void initState() {
    super.initState();

    _stft = STFT(
      widget.options.chunkSize,
      widget.options.windowType.apply(widget.options.chunkSize),
    );

    _processSamples();
  }

  @override
  void didUpdateWidget(covariant Spectrogram oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.samples != oldWidget.samples ||
        widget.options != oldWidget.options) {
      _processSamples();
    }
  }

  void _processSamples() {
    setState(() {
      _isProcessing = true;
    });

    //
    // Normalize
    //
    Float64List normalized = Float64List(widget.samples.length);

    final max = widget.samples.reduce((max, x) => x > max ? x : max);

    final norm = 1.0 / max;
    for (int i = 0; i < widget.samples.length; ++i) {
      normalized[i] = widget.samples[i] * norm;
    }

    final newData = <Float64List>[];

    _stft.run(
      normalized,
      (Float64x2List chunk) {
        Float64List amplitudes = chunk.discardConjugates().magnitudes();

        final processFunc = widget.processChunk;
        if (processFunc != null) {
          amplitudes = processFunc(amplitudes);
        }

        newData.add(amplitudes);
      },
      widget.options.chunkStride,
    );

    setState(() {
      _isProcessing = false;
      _data = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing && _data.isEmpty) {
      return widget.loadingBuilder(context);
    }
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        isComplex: true,
        painter: SpectrogramPainter(
          data: _data,
        ),
      ),
    );
  }
}
