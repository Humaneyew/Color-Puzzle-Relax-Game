import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/data/game_state_models.dart';
import 'package:color_puzzle_relax_game/src/data/gradient_puzzle_level.dart';
import 'package:flutter/material.dart';

void main() {
  group('GameStateModels', () {
    test('GameStateSnapshot stores values immutably', () {
      const level = GradientPuzzleLevel(
        id: 'test-level',
        name: 'Test',
        gridSize: 3,
        palette: [Colors.black, Colors.white],
        fixedCells: {0},
      );

      const snapshot = GameStateSnapshot(
        level: level,
        moves: 10,
        lives: 2,
        hints: 1,
        rewards: 3,
        highestUnlockedLevelIndex: 4,
      );

      expect(snapshot.level, same(level));
      expect(snapshot.moves, 10);
      expect(snapshot.lives, 2);
      expect(snapshot.hints, 1);
      expect(snapshot.rewards, 3);
      expect(snapshot.highestUnlockedLevelIndex, 4);
    });

    test('GameResult describes the end of a level', () {
      const level = GradientPuzzleLevel(
        id: 'result-level',
        name: 'Result',
        gridSize: 4,
        palette: [Colors.red, Colors.blue],
        fixedCells: {0, 5},
      );

      const result = GameResult(
        level: level,
        moveCount: 24,
        invalidMoveCount: 3,
        duration: Duration(minutes: 2),
      );

      expect(result.level.name, 'Result');
      expect(result.moveCount, 24);
      expect(result.invalidMoveCount, 3);
      expect(result.duration.inMinutes, 2);
    });
  });
}
