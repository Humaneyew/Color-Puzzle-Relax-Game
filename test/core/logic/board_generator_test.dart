import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/core/colors/color_blindness.dart';
import 'package:color_puzzle_relax_game/src/core/logic/board_generator.dart';
import 'package:color_puzzle_relax_game/src/features/game/domain/entities/board.dart';
import 'package:color_puzzle_relax_game/src/features/game/domain/entities/level_config.dart';
import 'package:color_puzzle_relax_game/src/features/game/domain/entities/tile.dart';

void main() {
  const BoardGenerator generator = BoardGenerator();

  LevelConfig createConfig() {
    return LevelConfig(
      columns: 3,
      rows: 3,
      topLeft: const Color(0xFF0000FF),
      topRight: const Color(0xFFFF0000),
      bottomLeft: const Color(0xFF00FF00),
      bottomRight: const Color(0xFFFFFF00),
      anchorIndices: <int>{0, 2, 6, 8},
      misplacedThreshold: 2,
      colorBlindness: ColorBlindnessType.none,
      randomSeed: 7,
    );
  }

  test('buildBoard creates interpolated board with anchors applied', () {
    final LevelConfig config = createConfig();
    final Board board = generator.buildBoard(config, random: Random(5));

    expect(board.columns, config.columns);
    expect(board.rows, config.rows);
    expect(board.tiles, hasLength(config.columns * config.rows));
    expect(board.anchors, hasLength(config.anchorIndices.length));
    expect(board.movables.length + board.anchors.length, board.tiles.length);
    expect(board.countMisplacedTiles(), greaterThanOrEqualTo(config.misplacedThreshold));
  });

  test('buildBoard supports rectangular grids', () {
    final LevelConfig config = LevelConfig(
      columns: 5,
      rows: 7,
      topLeft: const Color(0xFF0000FF),
      topRight: const Color(0xFFFF0000),
      bottomLeft: const Color(0xFF00FF00),
      bottomRight: const Color(0xFFFFFF00),
      anchorIndices: <int>{0, 4, 30, 34},
      misplacedThreshold: 5,
      colorBlindness: ColorBlindnessType.none,
      randomSeed: 11,
    );

    final Board board = generator.buildBoard(config, random: Random(3));

    expect(board.columns, 5);
    expect(board.rows, 7);
    expect(board.tiles, hasLength(35));
    expect(board.anchors.length, config.anchorIndices.length);
  });

  test('applyAnchors marks specified tiles and leaves others movable', () {
    final List<Tile> tiles = List<Tile>.generate(
      4,
      (int index) => Tile(
        correctIndex: index,
        currentIndex: index,
        color: const Color(0xFF123456),
      ),
    );
    final Board board = Board(columns: 2, rows: 2, tiles: tiles);
    final Board anchored = generator.applyAnchors(board, <int>{0, 3});

    expect(anchored.tileAt(0).isAnchor, isTrue);
    expect(anchored.tileAt(3).isAnchor, isTrue);
    expect(anchored.tileAt(1).isAnchor, isFalse);
    expect(anchored.tileAt(2).isAnchor, isFalse);
  });

  test('shuffleMovables shuffles movable tiles while keeping anchors', () {
    final List<Tile> tiles = List<Tile>.generate(
      9,
      (int index) => Tile(
        correctIndex: index,
        currentIndex: index,
        color: const Color(0xFF112233),
      ),
    );
    Board board = Board(columns: 3, rows: 3, tiles: tiles);
    board = generator.applyAnchors(board, <int>{0, 2, 6, 8});

    final Board shuffled = generator.shuffleMovables(
      board,
      3,
      random: Random(2),
      maxAttempts: 100,
    );

    expect(shuffled.countMisplacedTiles(), greaterThanOrEqualTo(3));
    expect(shuffled.tileAt(0).isAnchor, isTrue);
    expect(shuffled.tileAt(8).isAnchor, isTrue);
  });

  test('Board.isSolved reflects tile positions', () {
    final List<Tile> solvedTiles = List<Tile>.generate(
      4,
      (int index) => Tile(
        correctIndex: index,
        currentIndex: index,
        color: const Color(0xFF010101),
      ),
    );
    final Board solved = Board(columns: 2, rows: 2, tiles: solvedTiles);
    expect(solved.isSolved(), isTrue);

    final List<Tile> unsolvedTiles = <Tile>[
      const Tile(
        correctIndex: 0,
        currentIndex: 1,
        color: Color(0xFF000000),
      ),
      const Tile(
        correctIndex: 1,
        currentIndex: 0,
        color: Color(0xFFFFFFFF),
      ),
      const Tile(
        correctIndex: 2,
        currentIndex: 2,
        color: Color(0xFF111111),
      ),
      const Tile(
        correctIndex: 3,
        currentIndex: 3,
        color: Color(0xFF222222),
      ),
    ];
    final Board unsolved = Board(columns: 2, rows: 2, tiles: unsolvedTiles);
    expect(unsolved.isSolved(), isFalse);
  });
}
