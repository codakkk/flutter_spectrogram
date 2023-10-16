library flutter_spectrogram;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

export 'src/spectrogram.dart';
export 'src/spectrogram_options.dart';
export 'src/window_type.dart';
export 'src/visualizer_widget.dart';

class FlutterSpectrogram {
  static Future<bool> start() async {
    final value = await SoLoud().startIsolate();
    if (value == PlayerErrors.noError) {
      debugPrint('isolate started');
      return true;
    } else {
      debugPrint('isolate starting error: $value');
      return false;
    }
  }

  static Future<SoundProps?> loadFromFile(File file) async {
    final load = await SoloudTools.loadFromFile(file.path);

    return load;
  }
}
