import 'dart:math';

import 'package:flutter/material.dart';

import '../data/level.dart';
import '../data/tile.dart';

/// Controller encapsulating puzzle state and user actions.
class GameBoardController extends ChangeNotifier {
  GameBoardController(this.level, {Random? random})
      : _random = random ?? Random() {
    _initializeTiles();
  }

  final GradientPuzzleLevel level;
  final Random _random;

  late List<GradientTile> _tiles;
  int _moveCount = 0;
  int _invalidMoves = 0;

  GradientTile tileAt(int index) => _tiles[index];

  List<GradientTile> get tiles => List.unmodifiable(_tiles);

  int get moveCount => _moveCount;

  int get invalidMoves => _invalidMoves;

  bool get isSolved => _tiles.asMap().entries.every(
        (entry) => entry.value.correctIndex == entry.key,
      );

  int get correctTiles => _tiles.asMap().entries
      .where((entry) => entry.key == entry.value.correctIndex)
      .length;

  void reset() {
    _moveCount = 0;
    _invalidMoves = 0;
    _initializeTiles();
    notifyListeners();
  }

  void _initializeTiles() {
    final baseTiles = List.generate(level.tileCount, (index) {
      final color = level.colorForIndex(index);
      final fixed = level.fixedCells.contains(index);
      return GradientTile(correctIndex: index, color: color, fixed: fixed);
    });

    final movableIndexes = <int>[];
    for (var i = 0; i < baseTiles.length; i++) {
      if (!level.fixedCells.contains(i)) {
        movableIndexes.add(i);
      }
    }

    final shuffledTiles = [
      for (final index in movableIndexes) baseTiles[index],
    ]..shuffle(_random);

    _tiles = List<GradientTile>.filled(baseTiles.length, baseTiles.first);
    var movablePointer = 0;
    for (var i = 0; i < baseTiles.length; i++) {
      if (level.fixedCells.contains(i)) {
        _tiles[i] = baseTiles[i];
      } else {
        _tiles[i] = shuffledTiles[movablePointer++];
      }
    }

    if (isSolved && movableIndexes.isNotEmpty) {
      // Ensure the puzzle is not already solved.
      final a = movableIndexes.first;
      final b = movableIndexes.last;
      final temp = _tiles[a];
      _tiles[a] = _tiles[b];
      _tiles[b] = temp;
    }
  }

  /// Swaps two tiles if both are movable.
  ///
  /// Returns `true` when the swap results in a board update.
  bool swapTiles(int from, int to) {
    if (from == to) {
      _invalidMoves++;
      notifyListeners();
      return false;
    }
    if (_isIndexOutOfRange(from) || _isIndexOutOfRange(to)) {
      _invalidMoves++;
      notifyListeners();
      return false;
    }
    final fromTile = _tiles[from];
    final toTile = _tiles[to];
    if (fromTile.fixed || toTile.fixed) {
      _invalidMoves++;
      notifyListeners();
      return false;
    }
    _tiles[from] = toTile;
    _tiles[to] = fromTile;
    _moveCount++;
    notifyListeners();
    return true;
  }

  bool _isIndexOutOfRange(int index) => index < 0 || index >= _tiles.length;

  /// Places a correct tile into its position and returns the index affected.
  /// Returns `-1` if no hint was applied (already solved).
  int applyHint() {
    final incorrectIndexes = <int>[];
    for (var i = 0; i < _tiles.length; i++) {
      final tile = _tiles[i];
      if (!tile.fixed && tile.correctIndex != i) {
        incorrectIndexes.add(i);
      }
    }
    if (incorrectIndexes.isEmpty) {
      return -1;
    }
    incorrectIndexes.shuffle(_random);
    final targetIndex = incorrectIndexes.first;
    final targetTile = _tiles.firstWhere((tile) => tile.correctIndex == targetIndex);
    final originIndex = _tiles.indexOf(targetTile);
    if (originIndex == targetIndex) {
      return -1;
    }
    _tiles[originIndex] = _tiles[targetIndex];
    _tiles[targetIndex] = targetTile;
    _moveCount++;
    notifyListeners();
    return targetIndex;
  }
}
