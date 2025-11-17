import 'dart:ui';

import 'package:equatable/equatable.dart';

class Tile extends Equatable {
  const Tile({
    required this.id,
    required this.currentIndex,
    required this.color,
    this.isAnchor = false,
  });

  final int id;
  final int currentIndex;
  final Color color;
  final bool isAnchor;

  Tile copyWith({
    int? id,
    int? currentIndex,
    Color? color,
    bool? isAnchor,
  }) {
    return Tile(
      id: id ?? this.id,
      currentIndex: currentIndex ?? this.currentIndex,
      color: color ?? this.color,
      isAnchor: isAnchor ?? this.isAnchor,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, currentIndex, color, isAnchor];
}
