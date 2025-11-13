import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/core/colors/color_converters.dart';
import 'package:color_puzzle_relax_game/src/core/colors/lab_color.dart';

void main() {
  test('srgbToLab converts red to expected LAB values', () {
    final LabColor lab = srgbToLab(const Color(0xFFFF0000));
    expect(lab.l, closeTo(53.24, 0.1));
    expect(lab.a, closeTo(80.09, 0.2));
    expect(lab.b, closeTo(67.20, 0.2));
  });

  test('labToSrgb round-trips arbitrary color', () {
    final Random random = Random(42);
    for (int i = 0; i < 10; i++) {
      final Color color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
      final LabColor lab = srgbToLab(color);
      final Color converted = labToSrgb(lab);
      expect(converted.red.toDouble(), closeTo(color.red.toDouble(), 1));
      expect(converted.green.toDouble(), closeTo(color.green.toDouble(), 1));
      expect(converted.blue.toDouble(), closeTo(color.blue.toDouble(), 1));
    }
  });
}
