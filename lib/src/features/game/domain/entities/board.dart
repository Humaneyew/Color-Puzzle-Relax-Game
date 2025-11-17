import 'dart:ui';

import 'package:equatable/equatable.dart';

import 'tile.dart';

class Board extends Equatable {
  Board({
    required this.columns,
    required this.rows,
    required List<Tile> tiles,
    required List<Color> solutionColors,
  })  : assert(columns > 0 && rows > 0),
        assert(columns * rows == tiles.length,
            'Tile count must match board dimensions'),
        assert(columns * rows == solutionColors.length,
            'Solution must match board dimensions'),
        tiles = List<Tile>.unmodifiable(_sortByCurrentIndex(tiles)),
        solutionColors = List<Color>.unmodifiable(solutionColors);

  final int columns;
  final int rows;
  final List<Tile> tiles;
  final List<Color> solutionColors;

  Tile tileAt(int index) => tiles[index];

  Color targetColorAt(int index) => solutionColors[index];

  bool isSolved() {
    for (final Tile tile in tiles) {
      final Color expected = solutionColors[tile.currentIndex];
      if (tile.color.value != expected.value) {
        return false;
      }
    }
    return true;
  }

  int countMisplacedTiles({bool includeAnchors = false}) {
    int count = 0;
    for (final Tile tile in tiles) {
      if (!includeAnchors && tile.isAnchor) {
        continue;
      }
      final Color expected = solutionColors[tile.currentIndex];
      if (tile.color.value != expected.value) {
        count++;
      }
    }
    return count;
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
      solutionColors: solutionColors,
    );
  }

  @override
  List<Object?> get props => <Object?>[columns, rows, tiles, solutionColors];
}

List<Tile> _sortByCurrentIndex(List<Tile> tiles) {
  final List<Tile> sorted = List<Tile>.from(tiles);
  sorted.sort((Tile a, Tile b) => a.currentIndex.compareTo(b.currentIndex));
  return sorted;
}
