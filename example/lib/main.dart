import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
import 'package:wav/wav_file.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final future = Wav.readFile('assets/IT_CLD_02S06.wav');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('loading');
              }
              final data = snapshot.data!;
              return Spectrogram(
                height: 100,
                samples: data.toMono(),
                minFrequency: 0,
                maxFrequency: 5000,
                numTimeBins: 100,
                totalDuration: data.duration,
                width: MediaQuery.of(context).size.width,
                loadingBuilder: (context) => const CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
