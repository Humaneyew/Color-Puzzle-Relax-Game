import 'package:meta/meta.dart';

/// Outcome of a completed gradient puzzle level.
@immutable
class GameResult {
  const GameResult({
    required this.levelId,
    required this.moves,
    required this.hintsUsed,
    required this.duration,
    required this.livesEarned,
    required this.rewardsEarned,
    required this.isNewRecord,
  });

  final String levelId;
  final int moves;
  final int hintsUsed;
  final Duration duration;
  final int livesEarned;
  final int rewardsEarned;
  final bool isNewRecord;
}
