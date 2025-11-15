import 'dart:math';
import 'dart:ui';

import '../colors/color_blindness.dart';
import '../colors/color_converters.dart';
import '../colors/color_interpolation.dart';
import '../colors/lab_color.dart';
import '../../features/game/domain/entities/board.dart';
import '../../features/game/domain/entities/level_config.dart';
import '../../features/game/domain/entities/tile.dart';

class BoardGenerator {
  const BoardGenerator();

  Board buildBoard(LevelConfig config, {Random? random}) {
    final Random rng = random ?? Random(config.randomSeed);
    final List<Tile> initialTiles = _buildTiles(config);
    Board board = Board(
      width: config.width,
      height: config.height,
      tiles: initialTiles,
    );
    board = applyAnchors(board, config.anchorIndices);
    return shuffleMovables(
      board,
      config.misplacedThreshold,
      random: rng,
    );
  }

  Board applyAnchors(Board board, Set<int> anchorIndices) {
    if (anchorIndices.isEmpty) {
      return board;
    }
    final List<Tile> updated = board.tiles
        .map((Tile tile) => anchorIndices.contains(tile.correctIndex)
            ? tile.copyWith(
                isAnchor: true,
                currentIndex: tile.correctIndex,
              )
            : tile.copyWith(isAnchor: false))
        .toList();
    return board.copyWith(tiles: updated);
  }

  Board shuffleMovables(
    Board board,
    int misplacedThreshold, {
    Random? random,
    int maxAttempts = 50,
  }) {
    final List<Tile> movables = board.movables;
    if (movables.isEmpty) {
      return board;
    }

    final Random rng = random ?? Random();
    final List<int> movablePositions =
        movables.map((Tile tile) => tile.currentIndex).toList(growable: false);
    final List<Tile> anchors = board.anchors;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final List<int> shuffledPositions = List<int>.from(movablePositions);
      shuffledPositions.shuffle(rng);

      final List<Tile> updatedTiles = List<Tile>.from(board.tiles);

      for (int i = 0; i < movables.length; i++) {
        final Tile tile = movables[i];
        final int newIndex = shuffledPositions[i];
        updatedTiles[newIndex] = tile.copyWith(currentIndex: newIndex);
      }

      for (final Tile anchor in anchors) {
        updatedTiles[anchor.currentIndex] = anchor.copyWith(
          currentIndex: anchor.correctIndex,
          isAnchor: true,
        );
      }

      final Board candidate = board.copyWith(tiles: updatedTiles);
      final int misplaced = candidate.countMisplacedTiles();
      final bool meetsThreshold = misplaced >= misplacedThreshold;
      final bool acceptableWhenNoThreshold =
          misplacedThreshold == 0 && !candidate.isSolved();

      if (meetsThreshold || acceptableWhenNoThreshold) {
        return candidate;
      }
    }

    return board;
  }

  List<Tile> _buildTiles(LevelConfig config) {
    final LabColor topLeft = srgbToLab(config.topLeft);
    final LabColor topRight = srgbToLab(config.topRight);
    final LabColor bottomLeft = srgbToLab(config.bottomLeft);
    final LabColor bottomRight = srgbToLab(config.bottomRight);

    final List<LabColor> labGrid = bilinearInterpolate(
      topLeft,
      topRight,
      bottomLeft,
      bottomRight,
      config.width,
      config.height,
    );

    final List<Tile> tiles = <Tile>[];
    for (int index = 0; index < labGrid.length; index++) {
      final Color color = labToSrgb(labGrid[index]);
      final Color adjusted =
          applyColorBlindness(color, config.colorBlindness);
      tiles.add(
        Tile(
          correctIndex: index,
          currentIndex: index,
          color: adjusted,
        ),
      );
    }
    return tiles;
  }
}
