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
  Future<Wav> _loadAudioFile() async {
    final audio = await Wav.readFile("assets/IT_CLD_02S06.wav");

    return audio;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 200),
            FutureBuilder(
              future: _loadAudioFile(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Spectrogram(
                  audio: snapshot.data!,
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  loadingBuilder: (context) =>
                      const CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
