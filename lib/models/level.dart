import 'package:flutter/material.dart';

/// Describes a playable gradient puzzle level.
class GradientPuzzleLevel {
  const GradientPuzzleLevel({
    required this.id,
    required this.name,
    required this.gridSize,
    required this.palette,
    required this.fixedCells,
  });

  /// Unique identifier used to store progress.
  final String id;

  /// Visible label for the level selection screen.
  final String name;

  /// Number of rows and columns. Grids are always square.
  final int gridSize;

  /// Palette used to generate the gradient. The first color is the
  /// top-left corner while the last color is the bottom-right corner.
  final List<Color> palette;

  /// Set of indexes that represent fixed tiles (not movable by the player).
  final Set<int> fixedCells;

  int get tileCount => gridSize * gridSize;

  /// Computes a smoothly interpolated color for a tile index using the palette.
  Color colorForIndex(int index) {
    if (palette.length < 2) {
      return palette.isEmpty ? Colors.grey : palette.first;
    }
    final position = index / (tileCount - 1).clamp(1, tileCount);
    final scaled = position * (palette.length - 1);
    final lowerIndex = scaled.floor().clamp(0, palette.length - 1);
    final upperIndex = scaled.ceil().clamp(0, palette.length - 1);
    final t = scaled - lowerIndex;
    final lower = palette[lowerIndex];
    final upper = palette[upperIndex];
    return Color.lerp(lower, upper, t) ?? lower;
  }
}
