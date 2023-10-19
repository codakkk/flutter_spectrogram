import 'package:flutter/material.dart';

class ColourGradient {
  ColourGradient({
    required this.min,
    required this.max,
    required this.colours,
  });

  double min;
  double max;
  final List<Color> colours;

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
    final list = <Color>[];
    list.add(const Color.fromARGB(
      255,
      0,
      0,
      0,
    )); // Black
    list.add(const Color.fromARGB(
      255,
      255,
      255,
      255,
    )); // White

    return ColourGradient(min: 0.0, max: 1.0, colours: list);
  }

  static ColourGradient whiteBlack() {
    final list = <Color>[];
    list.add(const Color.fromARGB(255, 255, 255, 255)); // White
    list.add(const Color.fromARGB(255, 0, 0, 0)); // Black

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
    final m = ((len - 1).toDouble()) / (max - min); // TODO: Precalc this value
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
