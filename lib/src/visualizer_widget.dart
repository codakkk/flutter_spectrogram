import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';

import 'visualizer.dart';

class PageVisualizer extends StatefulWidget {
  const PageVisualizer({super.key});

  @override
  State<PageVisualizer> createState() => _PageVisualizerState();
}

class _PageVisualizerState extends State<PageVisualizer> {
  String shader = 'assets/shaders/test8.frag';
  final regExp = RegExp('_(s[w|i].*)_-');
  final List<String> audioChecks = [
    'assets/IT_CLD_02S06.wav',
  ];
  final ValueNotifier<TextureType> textureType =
      ValueNotifier(TextureType.fft2D);
  final ValueNotifier<double> fftSmoothing = ValueNotifier(0.8);
  final ValueNotifier<bool> isVisualizerForPlayer = ValueNotifier(false);
  final ValueNotifier<bool> isVisualizerEnabled = ValueNotifier(true);
  final ValueNotifier<RangeValues> fftImageRange =
      ValueNotifier(const RangeValues(0, 255));
  final ValueNotifier<int> maxFftImageRange = ValueNotifier(255);
  final ValueNotifier<double> soundLength = ValueNotifier(0);
  final ValueNotifier<double> soundPosition = ValueNotifier(0);
  Timer? timer;
  SoundProps? currentSound;
  FftController visualizerController = FftController();

  @override
  void dispose() {
    SoLoud().stopIsolate();
    SoLoud().stopCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                playAsset(audioChecks[0]);
              },
              child: Text('Test'),
            ),

            /// Seek slider
            ValueListenableBuilder<double>(
              valueListenable: soundLength,
              builder: (_, length, __) {
                return ValueListenableBuilder<double>(
                  valueListenable: soundPosition,
                  builder: (_, position, __) {
                    if (position >= length) {
                      position = 0;
                      if (length == 0) length = 1;
                    }

                    return Row(
                      children: [
                        Text(position.toInt().toString()),
                        Expanded(
                          child: Slider.adaptive(
                            value: position,
                            max: length < position ? position : length,
                            onChanged: (value) {
                              if (currentSound == null) return;
                              stopTimer();
                              SoLoud().seek(currentSound!.handle.last, value);
                              soundPosition.value = value;
                              startTimer();
                            },
                          ),
                        ),
                        Text(length.toInt().toString()),
                      ],
                    );
                  },
                );
              },
            ),

            /// fft range slider values to put into the texture
            ValueListenableBuilder<RangeValues>(
              valueListenable: fftImageRange,
              builder: (_, fftRange, __) {
                return Row(
                  children: [
                    Text('FFT range ${fftRange.start.toInt()}'),
                    Expanded(
                      child: RangeSlider(
                        max: 255,
                        divisions: 256,
                        values: fftRange,
                        onChanged: (values) {
                          fftImageRange.value = values;
                          visualizerController
                            ..changeMinFreq(values.start.toInt())
                            ..changeMaxFreq(values.end.toInt());
                        },
                      ),
                    ),
                    Text('${fftRange.end.toInt()}'),
                  ],
                );
              },
            ),

            /// fft smoothing slider
            ValueListenableBuilder<double>(
              valueListenable: fftSmoothing,
              builder: (_, smoothing, __) {
                return Row(
                  children: [
                    Text('FFT smooth: ${smoothing.toStringAsFixed(2)}'),
                    Expanded(
                      child: Slider.adaptive(
                        value: smoothing,
                        onChanged: (smooth) {
                          if (isVisualizerForPlayer.value) {
                            SoLoud().setFftSmoothing(smooth);
                          } else {
                            SoLoud().setCaptureFftSmoothing(smooth);
                          }
                          fftSmoothing.value = smooth;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            /// switch for getting data from player or from mic
            ValueListenableBuilder<bool>(
              valueListenable: isVisualizerForPlayer,
              builder: (_, forPlayer, __) {
                return Row(
                  children: [
                    Checkbox(
                      value: !forPlayer,
                      onChanged: (value) {
                        isVisualizerForPlayer.value = !value!;
                        visualizerController
                            .changeIsVisualizerForPlayer(!value);
                      },
                    ),
                    const Text('show capture data'),
                    Checkbox(
                      value: forPlayer,
                      onChanged: (value) {
                        isVisualizerForPlayer.value = value!;
                        visualizerController.changeIsVisualizerForPlayer(value);
                      },
                    ),
                    const Text('show player data'),
                  ],
                );
              },
            ),

            /// switch to enable / disable retrieving audio data
            ValueListenableBuilder<bool>(
              valueListenable: isVisualizerEnabled,
              builder: (_, isEnabled, __) {
                return Row(
                  children: [
                    Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: isEnabled,
                      onChanged: (value) {
                        isVisualizerEnabled.value = value;
                        visualizerController.changeIsVisualizerEnabled(value);
                      },
                    ),
                    const Text('FFT data'),
                  ],
                );
              },
            ),

            /// VISUALIZER
            FutureBuilder<ui.FragmentShader?>(
              future: loadShader(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ValueListenableBuilder<TextureType>(
                    valueListenable: textureType,
                    builder: (_, type, __) {
                      // return SizedBox.shrink();
                      return Visualizer(
                        key: UniqueKey(),
                        controller: visualizerController,
                        shader: snapshot.data!,
                        textureType: type,
                      );
                    },
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
            ),
          ],
        ),
      ),
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

  /// play file
  Future<void> play(String file) async {
    if (currentSound != null) {
      if (await SoLoud().disposeSound(currentSound!) != PlayerErrors.noError) {
        return;
      }
      stopTimer();
    }

    /// load the file
    final loadRet = await SoLoud().loadFile(file);
    if (loadRet.error != PlayerErrors.noError) return;
    currentSound = loadRet.sound;

    /// play it
    final playRet = await SoLoud().play(currentSound!);
    if (loadRet.error != PlayerErrors.noError) return;
    currentSound = playRet.sound;

    /// get its length and notify it
    soundLength.value = SoLoud().getLength(currentSound!).length;

    /// Stop the timer and dispose the sound when the sound ends
    currentSound!.soundEvents.stream.listen(
      (event) {
        stopTimer();
        // TODO(me): put this elsewhere?
        event.sound.soundEvents.close();

        /// It's needed to call dispose when it end else it will
        /// not be cleared
        SoLoud().disposeSound(currentSound!);
        currentSound = null;
      },
    );
    startTimer();
  }

  /// plays an assets file
  Future<void> playAsset(String assetsFile) async {
    final audioFile = await getAssetFile(assetsFile);
    return play(audioFile.path);
  }

  /// get the assets file and copy it to the temp dir
  Future<File> getAssetFile(String assetsFile) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final filePath = '$tempPath/$assetsFile';
    final file = File(filePath);
    if (file.existsSync()) {
      return file;
    } else {
      final byteData = await rootBundle.load(assetsFile);
      final buffer = byteData.buffer;
      await file.create(recursive: true);
      return file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
  }

  /// start timer to update the audio position slider
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (currentSound != null) {
        soundPosition.value =
            SoLoud().getPosition(currentSound!.handle.last).position;
      }
    });
  }

  /// stop timer
  void stopTimer() {
    timer?.cancel();
  }
}
