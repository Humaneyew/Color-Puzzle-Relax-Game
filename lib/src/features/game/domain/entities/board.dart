import 'package:equatable/equatable.dart';

import 'tile.dart';

class Board extends Equatable {
  Board({
    required this.width,
    required this.height,
    required List<Tile> tiles,
  }) : assert(width > 0, 'Board width must be positive'),
        assert(height > 0, 'Board height must be positive'),
        assert(tiles.length == width * height,
            'Tile count must equal board width × height'),
        tiles = List<Tile>.unmodifiable(_sortByCurrentIndex(tiles));

  final int width;
  final int height;
  final List<Tile> tiles;

  Tile tileAt(int index) => tiles[index];

  bool isSolved() => tiles.every((Tile tile) => tile.isInCorrectPosition);

  int countMisplacedTiles({bool includeAnchors = false}) {
    return tiles
        .where((Tile tile) => (includeAnchors || !tile.isAnchor) && !tile.isInCorrectPosition)
        .length;
  }

  List<Tile> get anchors =>
      tiles.where((Tile tile) => tile.isAnchor).toList(growable: false);

  List<Tile> get movables =>
      tiles.where((Tile tile) => !tile.isAnchor).toList(growable: false);

  int get tileCount => width * height;

  Board copyWith({
    List<Tile>? tiles,
    int? width,
    int? height,
  }) {
    return Board(
      width: width ?? this.width,
      height: height ?? this.height,
      tiles: tiles ?? this.tiles,
    );
  }

  @override
  List<Object?> get props => <Object?>[width, height, tiles];
}

List<Tile> _sortByCurrentIndex(List<Tile> tiles) {
  final List<Tile> sorted = List<Tile>.from(tiles);
  sorted.sort((Tile a, Tile b) => a.currentIndex.compareTo(b.currentIndex));
  return sorted;
}
