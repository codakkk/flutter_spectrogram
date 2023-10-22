import 'package:flutter/material.dart';

class ColourGradient {
  ColourGradient({
    required double min,
    required double max,
    required this.colours,
  })  : _min = min,
        _max = max,
        m = ((colours.length - 1).toDouble()) / (max - min);

  double _min;
  double _max;

  double m;
  final List<Color> colours;

  double get min => _min;

  set min(double value) {
    _min = value;

    _recalculateM();
  }

  double get max => _max;

  set max(double value) {
    _max = value;

    _recalculateM();
  }

  void _recalculateM() {
    m = ((colours.length - 1).toDouble()) / (_max - _min);
  }

  static ColourGradient audacity() {
    final list = <Color>[];
    list.add(const Color.fromARGB(255, 215, 215, 215)); // Grey
    list.add(const Color.fromARGB(255, 114, 169, 242)); // Blue
    list.add(const Color.fromARGB(255, 227, 61, 215)); // Pink
    list.add(const Color.fromARGB(255, 246, 55, 55)); // Red
    list.add(const Color.fromARGB(255, 255, 255, 255)); // White

    return ColourGradient(min: 0.0, max: 1.0, colours: list);
  }

  static ColourGradient blackWhite() {
    final list = <Color>[Colors.black, Colors.white];

    return ColourGradient(min: 0.0, max: 1.0, colours: list);
  }

  static ColourGradient whiteBlack() {
    final list = <Color>[Colors.white, Colors.black];

    return ColourGradient(min: 0.0, max: 1.0, colours: list);
  }

  Color getColour(double value) {
    int len = colours.length;

    assert(len > 1);
    assert(max >= min);

    if (value >= max) {
      return colours.last;
    }

    if (value <= min) {
      return colours.first;
    }

    // Get the scaled values and indexes to lookup the colour
    final scaledValue = (value - min) * m;
    final idxValue = scaledValue.floor();
    final ratio = scaledValue - idxValue.toDouble();
    final (i, j) = (idxValue, idxValue + 1);

    // Prevent over indexing after index computation
    if (j >= len) {
      return colours.last;
    }

    // Get the colour band
    final first = colours[i];
    final second = colours[j];

    return Color.fromARGB(
      interpolate(first.alpha, second.alpha, ratio),
      interpolate(first.red, second.red, ratio),
      interpolate(first.green, second.green, ratio),
      interpolate(first.blue, second.blue, ratio),
    );
  }

  int interpolate(int start, int finish, double ratio) {
    return ((finish.toDouble() - start.toDouble()) * ratio + start.toDouble())
        .round();
  }
}
