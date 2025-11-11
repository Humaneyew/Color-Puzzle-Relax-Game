import 'package:flutter/material.dart';

/// Represents a single tile in the gradient puzzle grid.
class GradientTile {
  const GradientTile({
    required this.correctIndex,
    required this.color,
    this.fixed = false,
  });

  /// Index where the tile belongs when the puzzle is solved.
  final int correctIndex;

  /// Color rendered for the tile.
  final Color color;

  /// Whether the tile cannot be moved by the player.
  final bool fixed;

  GradientTile copyWith({bool? fixed}) {
    return GradientTile(
      correctIndex: correctIndex,
      color: color,
      fixed: fixed ?? this.fixed,
    );
  }
}
