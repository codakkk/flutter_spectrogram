import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Spectrogram(
          path: 'assets/IT_CLD_02S06.wav',
          height: 100,
          width: MediaQuery.of(context).size.width,
          loadingBuilder: (context) => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
