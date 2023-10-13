import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/data/spectrogram_data.dart';
import 'package:flutter_spectrogram/src/spectrogram_options.dart';
import 'package:flutter_spectrogram/src/spectrogram_painter.dart';
import 'package:wav/wav.dart';

import 'data/sound.dart';
import 'window_type.dart';

class Spectrogram extends StatefulWidget {
  const Spectrogram({
    super.key,
    required this.path,
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

  final String path;
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

  late final SpectrogramData _data;

  @override
  void initState() {
    super.initState();

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

  Future<void> _processSamples() async {
    setState(() {
      _isProcessing = true;
    });

    final file = await Wav.readFile(widget.path);
    final mono = file.toMono();

    final channels = file.channels.length;
    final sampleRate = file.samplesPerSecond;
    final duration = mono.length / sampleRate;

    if (mono.isEmpty) {
      throw Exception('Audio file contains 0 samples');
    }

    final sound = Sound(
      numberOfChannels: file.channels.length,
      xmin: 0.0,
      xmax: duration,
      numberOfSamples: (duration * sampleRate).round(),
      samplingPeriod: 1.0 / sampleRate,
      timeOfFirstSample: 0.5 / sampleRate,
      ymax: 0,
      amplitude: mono,
    );

    final spectrogram = SpectrogramData.fromSound(sound);

    setState(() {
      _isProcessing = false;
      _data = spectrogram!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return widget.loadingBuilder(context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('5000 Hz'),
        RepaintBoundary(
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            isComplex: true,
            painter: SpectrogramPainter(
              dominantColor: Colors.white,
              tmin: 0.0,
              tmax: 0.0,
              fmin: 0.0,
              fmax: 0.0,
              autoscaling: true,
              preemphasis: 60.0,
              maximum: 100.0,
              dynamic: 50.0,
              dynamicCompression: 0.0,
              data: _data,
            ),
          ),
        ),
        const Text('0 Hz'),
      ],
    );
  }
}
