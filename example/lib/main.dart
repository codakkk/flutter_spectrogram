import 'package:flutter/material.dart';
import 'package:flutter_spectrogram/flutter_spectrogram.dart';

Future<void> main() async {
  await FlutterSpectrogram.start();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PageVisualizer(),
      ),
    );
  }
}
