import 'package:equatable/equatable.dart';

import 'board.dart';
import 'level.dart';

class GameSession extends Equatable {
  const GameSession({
    required this.level,
    required this.board,
    required this.movesUsed,
  });

  final Level level;
  final Board board;
  final int movesUsed;

  GameSession copyWith({
    Level? level,
    Board? board,
    int? movesUsed,
  }) {
    return GameSession(
      level: level ?? this.level,
      board: board ?? this.board,
      movesUsed: movesUsed ?? this.movesUsed,
    );
  }

  @override
  List<Object?> get props => <Object?>[level, board, movesUsed];
}
