import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'visualizer.dart';

class VisualizerWidget extends StatefulWidget {
  const VisualizerWidget({super.key});

  @override
  State<VisualizerWidget> createState() => _VisualizerWidgetState();
}

class _VisualizerWidgetState extends State<VisualizerWidget> {
  String shader = 'assets/shaders/test8.frag';
  FftController visualizerController = FftController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.FragmentShader?>(
      future: loadShader(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Visualizer(
            key: UniqueKey(),
            controller: visualizerController,
            shader: snapshot.data!,
            textureType: TextureType.fft2D,
          );
        } else {
          if (snapshot.data == null) {
            return const Placeholder(
              child: Align(
                child: Text('Error compiling shader.\nSee log'),
              ),
            );
          }
          return const CircularProgressIndicator();
        }
      },
    );
  }

  /// load asynchronously the fragment shader
  Future<ui.FragmentShader?> loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(shader);
      return program.fragmentShader();
    } catch (e) {
      debugPrint('error compiling the shader: $e');
    }
    return null;
  }
}
