import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spectrogram_tests/models/sound.dart';
import 'package:spectrogram_tests/models/spectrogram.dart';
import 'package:spectrogram_tests/spectrogram_utils.dart';
import 'package:spectrogram_tests/widgets/spectrogram_widget.dart';
import 'package:wav/wav.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Future<Spectrogram> _test() async {
    final root = await rootBundle.load('assets/audio.wav');
    final wav = Wav.read(root.buffer.asUint8List());

    final sound = Sound.fromWav(wav);

    return SpectrogramUtils.soundToSpectrogram(
      sound: sound,
      effectiveAnalysisWidth: 0.005,
      minFreqStep: 20.0,
      minTimeStep: 0.002,
      frequencyMax: 5000.0,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            FutureBuilder(
              future: _test(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return SpectrogramWidget(
                  size: Size(
                    mediaQuery.size.width,
                    mediaQuery.size.height,
                  ),
                  spectrogram: snapshot.data!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
