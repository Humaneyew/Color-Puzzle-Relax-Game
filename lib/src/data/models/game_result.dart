/// Stores metadata describing the outcome of a completed puzzle attempt.
class GameResult {
  const GameResult({
    required this.levelId,
    required this.moves,
    required this.hintsUsed,
    required this.duration,
    required this.completedAt,
  });

  /// Identifier of the level that was completed.
  final String levelId;

  /// Number of moves taken to solve the level.
  final int moves;

  /// Number of hints consumed during the run.
  final int hintsUsed;

  /// Total time spent in the level.
  final Duration duration;

  /// Timestamp when the run was finished.
  final DateTime completedAt;
}
