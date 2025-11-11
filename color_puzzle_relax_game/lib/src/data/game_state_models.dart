import 'gradient_puzzle_level.dart';

/// Serializable snapshot of the game session.
///
/// Used by the UI and persistence layers to render progress without exposing
/// the mutable controller implementations.
class GameStateSnapshot {
  const GameStateSnapshot({
    required this.level,
    required this.moves,
    required this.lives,
    required this.hints,
    required this.rewards,
    required this.highestUnlockedLevelIndex,
  });

  final GradientPuzzleLevel level;
  final int moves;
  final int lives;
  final int hints;
  final int rewards;
  final int highestUnlockedLevelIndex;
}

/// Immutable result produced when a player finishes a level.
class GameResult {
  const GameResult({
    required this.level,
    required this.moveCount,
    required this.invalidMoveCount,
    required this.duration,
  });

  final GradientPuzzleLevel level;
  final int moveCount;
  final int invalidMoveCount;
  final Duration duration;
}
