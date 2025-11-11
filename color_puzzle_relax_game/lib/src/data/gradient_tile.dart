import 'package:flutter/material.dart';

/// Immutable description of a single tile rendered on the puzzle board.
///
/// The tile stores its [correctIndex] so that the board controller can
/// determine whether the tile is placed at the right position. A tile can be
/// marked as [fixed] to indicate that it cannot be moved by the player.
class GradientTile {
  const GradientTile({
    required this.correctIndex,
    required this.color,
    this.fixed = false,
  });

  /// Index describing the position that completes the puzzle.
  final int correctIndex;

  /// Render color calculated from the level's gradient palette.
  final Color color;

  /// Indicates whether the tile is locked in place.
  final bool fixed;

  GradientTile copyWith({bool? fixed}) {
    return GradientTile(
      correctIndex: correctIndex,
      color: color,
      fixed: fixed ?? this.fixed,
    );
  }
}
