import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/src/spectrogram_options.dart';
import 'package:flutter_spectrogram/src/spectrogram_painter.dart';
import 'dart:math' as math;
import 'window_type.dart';

class Spectrogram extends StatefulWidget {
  const Spectrogram({
    super.key,
    required this.width,
    required this.height,
    required this.numTimeBins,
    required this.numFrequencyBins,
    required this.totalDuration,
    required this.minFrequency,
    required this.maxFrequency,
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

  final int numTimeBins;
  final int numFrequencyBins;
  final double totalDuration;

  final double minFrequency;
  final double maxFrequency;

  final SpectrogramOptions options;

  final List<double> samples;

  final Widget Function(BuildContext context) loadingBuilder;
  final Float64List Function(Float64List amplitudes)? processChunk;

  @override
  State<Spectrogram> createState() => _SpectrogramState();
}

class _SpectrogramState extends State<Spectrogram> {
  bool _isProcessing = true;

  List<List<double>> _data = [];

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

  void _processSamples() async {
    setState(() {
      _isProcessing = true;
    });

    final newData = await calculateSpectrogram(
      _stft,
      widget.options.chunkSize,
      widget.samples,
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
          numTimeBins: widget.numTimeBins,
          numFrequencyBins: widget.numFrequencyBins,
          totalDuration: widget.totalDuration,
          minFrequency: widget.minFrequency,
          maxFrequency: widget.maxFrequency,
        ),
      ),
    );
  }
}

Future<List<List<double>>> calculateSpectrogram(
  STFT stft,
  int chunkSize,
  List<double> samples,
) async {
  const buckets = 120;
  Uint64List? logItr;

  List<List<double>> spectrogram = [];

  List<double> logBinnedData = [];

  stft.run(
    samples,
    (Float64x2List chunk) {
      final amp = chunk.discardConjugates().magnitudes();
      // final decibels = amp.map(amp => 20 * math.log(amp) / math.ln10).toList();
      logItr ??= linSpace(amp.length, buckets);

      logBinnedData.clear();
      // Calculate Logarithm binning
      int i0 = 0;
      for (final i1 in logItr!) {
        double power = 0;
        if (i1 != i0) {
          for (int i = i0; i < i1; ++i) {
            power += amp[i];
          }
          power /= i1 - i0;

          // Add the log binned data
          //logBinnedData.add(math.log(power));
          logBinnedData.add(power);

          debugPrint('Power: $power - Log: ${math.log(power)}');
        }
        i0 = i1;
      }
      spectrogram.add(logBinnedData);
    },
    chunkSize ~/ 2,
  );

  return spectrogram;
}

Uint64List linSpace(int end, int steps) {
  final a = Uint64List(steps);
  for (int i = 1; i < steps; ++i) {
    a[i - 1] = (end * i) ~/ steps;
  }
  a[steps - 1] = end;
  return a;
}
