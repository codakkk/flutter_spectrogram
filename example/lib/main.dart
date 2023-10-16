import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';
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
  Future<Float64List> _loadAudioFile() async {
    final audio = await Wav.readFile("assets/IT_CLD_02S06.wav");

    return audio.toMono();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: _loadAudioFile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return Spectrogram(
                samples: snapshot.data!,
                height: 100,
                width: MediaQuery.of(context).size.width,
                loadingBuilder: (context) => const CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
