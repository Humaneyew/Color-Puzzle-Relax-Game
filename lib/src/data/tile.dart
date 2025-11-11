import 'package:flutter/material.dart';

/// Immutable data representation for a single gradient puzzle tile.
class GradientTile {
  const GradientTile({
    required this.correctIndex,
    required this.color,
    this.fixed = false,
  });

  final int correctIndex;
  final Color color;
  final bool fixed;

  GradientTile copyWith({bool? fixed}) {
    return GradientTile(
      correctIndex: correctIndex,
      color: color,
      fixed: fixed ?? this.fixed,
    );
  }
}
