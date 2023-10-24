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

  void zoomIn() {
    setState(() {
      _zoom = clampDouble(_zoom * 1.05, 1.0, 100);
    });
  }

  void zoomOut() {
    setState(() {
      _zoom = clampDouble(_zoom / 1.05, 1.0, 100);
    });
  }

  Future<Spectrogram> _test(Size size) async {
    final root = await rootBundle.load('assets/audio.wav');
    final wav = Wav.read(root.buffer.asUint8List());

    final sound = Sound.fromWav(wav);

    const noOfTimeSteps = 1000;
    const frequencySteps = 250.0;
    const fmax = 5000.0; // Praat's viewTo

    const windowLength = 0.005;
    final minimumTimeStep = size.width / noOfTimeSteps;
    const minimumFreqStep = fmax / frequencySteps;

    final builder = SpectrogramBuilder()
      ..sound = sound
      ..effectiveAnalysisWidth = windowLength
      ..frequencyMax = fmax
      ..minTimeStep = minimumTimeStep
      ..minFrequencyStep = minimumFreqStep;
    return builder.build();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = Size(
      mediaQuery.size.width,
      mediaQuery.size.height,
    );
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            /*IconButton(
              onPressed: zoomIn,
              icon: const Icon(Icons.zoom_in),
            ),
            IconButton(
              onPressed: zoomOut,
              icon: const Icon(Icons.zoom_out),
            ),*/
            FutureBuilder(
              future: _test(size),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return SpectrogramWidget(
                  size: size,
                  spectrogram: snapshot.data!,
                  zoom: _zoom,
                  applyDynamicRange: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
