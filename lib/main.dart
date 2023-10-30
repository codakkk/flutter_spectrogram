import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wav/wav.dart';

import 'flutter_spectrogram.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  double _zoom = 1.0;
  double width = 1.0;

  Spectrogram? _spectrogram;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final spectrogram = await _generateSpectrogram();
      setState(() {
        _spectrogram = spectrogram;
      });
    });
    super.initState();
  }

  Future<void> zoomIn() async {
    final newZoom = clampDouble(_zoom * 1.05, 1.0, 100);
    final spectrogram = await _generateSpectrogram();
    setState(() {
      _zoom = newZoom;
      _spectrogram = spectrogram;
    });
  }

  Future<void> zoomOut() async {
    final newZoom = clampDouble(_zoom / 1.05, 1.0, 100);
    final spectrogram = await _generateSpectrogram();
    setState(() {
      _zoom = newZoom;
      _spectrogram = spectrogram;
    });
  }

  Sound extractSound(Sound sound, double tmin, double tmax) {
    if (tmin < sound.xmin) {
      tmin = sound.xmin;
    }

    if (tmax > sound.xmax) {
      tmax = sound.xmax;
    }

    return Sound.extractPart(
      sound: sound,
      tmin: tmin,
      tmax: tmax,
      relativeWidth: 1.0,
      preserveTimes: true,
    );
  }

  Future<Spectrogram> _generateSpectrogram() async {
    final root = await rootBundle.load('assets/audio.wav');
    final wav = Wav.read(root.buffer.asUint8List());

    final sound = Sound.fromWav(wav);

    const noOfTimeSteps = 1000;
    const frequencySteps = 250.0;
    const fmax = 5000.0; // Praat's viewTo

    const windowLength = 0.005;
    const minimumTimeStep = 1 / noOfTimeSteps;
    const minimumFreqStep = fmax / frequencySteps;

    const margin = windowLength;

    final extracted = extractSound(
      sound,
      0.1 - margin,
      1.0 + margin,
    );

    final builder = SpectrogramBuilder()
      ..sound = extracted
      ..effectiveAnalysisWidth = windowLength
      ..frequencyMax = fmax
      ..minTimeStep = minimumTimeStep
      ..minFrequencyStep = minimumFreqStep;

    final b = builder.build();
    return b;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = Size(
      mediaQuery.size.width,
      mediaQuery.size.height - 40,
    );
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: zoomIn,
                  icon: const Icon(Icons.zoom_in),
                ),
                IconButton(
                  onPressed: zoomOut,
                  icon: const Icon(Icons.zoom_out),
                ),
              ],
            ),
            const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
