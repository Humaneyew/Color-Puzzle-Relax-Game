import 'package:equatable/equatable.dart';

class GameBoard extends Equatable {
  const GameBoard({
    required this.size,
    required this.tiles,
  });

  final int size;
  final List<List<int>> tiles;

  factory GameBoard.empty(int size) {
    return GameBoard(
      size: size,
      tiles: List<List<int>>.generate(
        size,
        (_) => List<int>.filled(size, 0),
        growable: false,
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[size, tiles];
}
