import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../core/colors/color_blindness.dart';
import 'level.dart';

class LevelConfig extends Equatable {
  const LevelConfig({
    required this.size,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.anchorIndices,
    required this.misplacedThreshold,
    this.colorBlindness = ColorBlindnessType.none,
    this.randomSeed,
  });

  final int size;
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
    final int seed = level.id.hashCode;
    final Random random = Random(seed);
    final int size = level.boardSize;
    final int totalTiles = size * size;

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
      size - 1,
      totalTiles - size,
      totalTiles - 1,
    };

    final int misplacedThreshold = size <= 1 ? 0 : max(1, (totalTiles * 0.25).round());

    return LevelConfig(
      size: size,
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
    int? size,
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
      size: size ?? this.size,
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
        size,
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
