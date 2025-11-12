import 'package:equatable/equatable.dart';

import 'game_board.dart';
import 'level.dart';

class GameSession extends Equatable {
  const GameSession({
    required this.level,
    required this.board,
    required this.movesUsed,
  });

  final Level level;
  final GameBoard board;
  final int movesUsed;

  GameSession copyWith({
    Level? level,
    GameBoard? board,
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
