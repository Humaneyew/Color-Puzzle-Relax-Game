import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/core/colors/color_blindness.dart';

void main() {
  test('applyColorBlindness returns same color for none', () {
    const Color color = Color(0xFF3366FF);
    expect(applyColorBlindness(color, ColorBlindnessType.none), color);
  });

  test('applyColorBlindness protanopia adjusts red channel', () {
    const Color color = Color(0xFFFF6633);
    final Color adjusted = applyColorBlindness(color, ColorBlindnessType.protanopia);
    expect(adjusted.red, lessThan(color.red));
    expect(adjusted.green, greaterThan(color.green - 40));
    expect(adjusted.blue.toDouble(), closeTo(color.blue.toDouble(), 40));
  });

  test('applyColorBlindness deuteranopia adjusts green channel', () {
    const Color color = Color(0xFF33FF66);
    final Color adjusted = applyColorBlindness(color, ColorBlindnessType.deuteranopia);
    expect(adjusted.green, lessThan(color.green));
  });

  test('applyColorBlindness tritanopia adjusts blue channel', () {
    const Color color = Color(0xFF3366FF);
    final Color adjusted = applyColorBlindness(color, ColorBlindnessType.tritanopia);
    expect(adjusted.blue, lessThan(color.blue));
  });
}
