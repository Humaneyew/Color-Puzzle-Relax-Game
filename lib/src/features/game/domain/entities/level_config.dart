import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/colors/color_blindness.dart';
import 'level.dart';

class LevelConfig extends Equatable {
  const LevelConfig({
    required this.width,
    required this.height,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.anchorIndices,
    required this.misplacedThreshold,
    this.colorBlindness = ColorBlindnessType.none,
    this.randomSeed,
  });

  final int width;
  final int height;
  final Color topLeft;
  final Color topRight;
  final Color bottomLeft;
  final Color bottomRight;
  final Set<int> anchorIndices;
  final int misplacedThreshold;
  final ColorBlindnessType colorBlindness;
  final int? randomSeed;

  factory LevelConfig.fromLevel(
    Level level, {
    ColorBlindnessType colorBlindness = ColorBlindnessType.none,
  }) {
    assert(level.width > 0 && level.height > 0, 'Level dimensions must be positive');
    final int seed = level.id.hashCode;
    final Random random = Random(seed);
    final int width = level.width;
    final int height = level.height;
    final int totalTiles = width * height;

    final double baseHue = random.nextDouble() * 360;
    final double hueOffset = 360 / 4;

    Color buildColor(int index) {
      final double hue = (baseHue + hueOffset * index) % 360;
      final double saturation = 0.55 + random.nextDouble() * 0.35;
      final double value = 0.65 + random.nextDouble() * 0.25;
      return HSVColor.fromAHSV(1.0, hue, saturation.clamp(0.0, 1.0), value.clamp(0.0, 1.0)).toColor();
    }

    final Set<int> anchors = <int>{
      0,
      width - 1,
      totalTiles - width,
      totalTiles - 1,
    };

    final int misplacedThreshold =
        totalTiles <= 1 ? 0 : max(1, (totalTiles * 0.25).round());

    return LevelConfig(
      width: width,
      height: height,
      topLeft: buildColor(0),
      topRight: buildColor(1),
      bottomLeft: buildColor(2),
      bottomRight: buildColor(3),
      anchorIndices: anchors,
      misplacedThreshold: misplacedThreshold,
      colorBlindness: colorBlindness,
      randomSeed: seed,
    );
  }

  LevelConfig copyWith({
    int? width,
    int? height,
    Color? topLeft,
    Color? topRight,
    Color? bottomLeft,
    Color? bottomRight,
    Set<int>? anchorIndices,
    int? misplacedThreshold,
    ColorBlindnessType? colorBlindness,
    int? randomSeed,
  }) {
    return LevelConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
      anchorIndices: anchorIndices ?? this.anchorIndices,
      misplacedThreshold: misplacedThreshold ?? this.misplacedThreshold,
      colorBlindness: colorBlindness ?? this.colorBlindness,
      randomSeed: randomSeed ?? this.randomSeed,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        width,
        height,
        topLeft,
        topRight,
        bottomLeft,
        bottomRight,
        anchorIndices,
        misplacedThreshold,
        colorBlindness,
        randomSeed,
      ];
}
