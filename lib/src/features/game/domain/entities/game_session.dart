import 'package:equatable/equatable.dart';

import 'board.dart';
import 'level.dart';

class GameSession extends Equatable {
  const GameSession({
    required this.level,
    required this.board,
    required this.movesUsed,
    this.bestScore,
    required this.worldAverage,
    required this.hintsRemaining,
  });

  final Level level;
  final Board board;
  final int movesUsed;
  final int? bestScore;
  final int worldAverage;
  final int hintsRemaining;

  GameSession copyWith({
    Level? level,
    Board? board,
    int? movesUsed,
    int? bestScore,
    int? worldAverage,
    int? hintsRemaining,
  }) {
    return GameSession(
      level: level ?? this.level,
      board: board ?? this.board,
      movesUsed: movesUsed ?? this.movesUsed,
      bestScore: bestScore ?? this.bestScore,
      worldAverage: worldAverage ?? this.worldAverage,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        level,
        board,
        movesUsed,
        bestScore,
        worldAverage,
        hintsRemaining,
      ];
}
