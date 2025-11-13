import 'dart:math';
import 'dart:ui';

enum ColorBlindnessType { none, protanopia, deuteranopia, tritanopia }

Color applyColorBlindness(Color color, ColorBlindnessType type) {
  switch (type) {
    case ColorBlindnessType.none:
      return color;
    case ColorBlindnessType.protanopia:
      return _transform(color, const <List<double>>[
        <double>[0.56667, 0.43333, 0.0],
        <double>[0.55833, 0.44167, 0.0],
        <double>[0.0, 0.24167, 0.75833],
      ]);
    case ColorBlindnessType.deuteranopia:
      return _transform(color, const <List<double>>[
        <double>[0.625, 0.375, 0.0],
        <double>[0.7, 0.3, 0.0],
        <double>[0.0, 0.3, 0.7],
      ]);
    case ColorBlindnessType.tritanopia:
      return _transform(color, const <List<double>>[
        <double>[0.95, 0.05, 0.0],
        <double>[0.0, 0.43333, 0.56667],
        <double>[0.0, 0.475, 0.525],
      ]);
  }
}

Color _transform(Color color, List<List<double>> matrix) {
  final double r = color.red / 255.0;
  final double g = color.green / 255.0;
  final double b = color.blue / 255.0;

  final double newR = matrix[0][0] * r + matrix[0][1] * g + matrix[0][2] * b;
  final double newG = matrix[1][0] * r + matrix[1][1] * g + matrix[1][2] * b;
  final double newB = matrix[2][0] * r + matrix[2][1] * g + matrix[2][2] * b;

  return Color.fromARGB(
    255,
    _clampToChannel(newR * 255.0),
    _clampToChannel(newG * 255.0),
    _clampToChannel(newB * 255.0),
  );
}

int _clampToChannel(double value) {
  if (value.isNaN) {
    return 0;
  }
  return max(0, min(255, (value + 0.5).floor()));
}
