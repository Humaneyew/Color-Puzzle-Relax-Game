import 'package:equatable/equatable.dart';

import 'tile.dart';

class Board extends Equatable {
  Board({
    required this.columns,
    required this.rows,
    required List<Tile> tiles,
  })  : assert(columns > 0 && rows > 0),
        assert(columns * rows == tiles.length,
            'Tile count must match board dimensions'),
        tiles = List<Tile>.unmodifiable(_sortByCurrentIndex(tiles));

  final int columns;
  final int rows;
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

  Board copyWith({List<Tile>? tiles}) {
    return Board(
      columns: columns,
      rows: rows,
      tiles: tiles ?? this.tiles,
    );
  }

  @override
  List<Object?> get props => <Object?>[columns, rows, tiles];
}

List<Tile> _sortByCurrentIndex(List<Tile> tiles) {
  final List<Tile> sorted = List<Tile>.from(tiles);
  sorted.sort((Tile a, Tile b) => a.currentIndex.compareTo(b.currentIndex));
  return sorted;
}
