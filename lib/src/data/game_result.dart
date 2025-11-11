import 'package:meta/meta.dart';

/// Outcome of a completed gradient puzzle level.
@immutable
class GameResult {
  const GameResult({
    required this.levelId,
    required this.moves,
    required this.hintsUsed,
    required this.duration,
  });

  final String levelId;
  final int moves;
  final int hintsUsed;
  final Duration duration;
}
