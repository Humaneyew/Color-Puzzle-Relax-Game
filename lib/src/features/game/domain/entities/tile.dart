import 'dart:ui';

import 'package:equatable/equatable.dart';

class Tile extends Equatable {
  const Tile({
    required this.correctIndex,
    required this.currentIndex,
    required this.color,
    this.isAnchor = false,
  });

  final int correctIndex;
  final int currentIndex;
  final Color color;
  final bool isAnchor;

  bool get isInCorrectPosition => correctIndex == currentIndex;

  Tile copyWith({
    int? correctIndex,
    int? currentIndex,
    Color? color,
    bool? isAnchor,
  }) {
    return Tile(
      correctIndex: correctIndex ?? this.correctIndex,
      currentIndex: currentIndex ?? this.currentIndex,
      color: color ?? this.color,
      isAnchor: isAnchor ?? this.isAnchor,
    );
  }

  @override
  List<Object?> get props => <Object?>[correctIndex, currentIndex, color, isAnchor];
}
