import '../../../game/domain/entities/game_session.dart';
import '../../../game/domain/entities/level.dart';

enum GameStatus { initial, loading, ready, inSession, error }

class GameState {
  const GameState({
    this.status = GameStatus.initial,
    this.levels = const <Level>[],
    this.session,
    this.errorMessage,
  });

  final GameStatus status;
  final List<Level> levels;
  final GameSession? session;
  final String? errorMessage;

  GameState copyWith({
    GameStatus? status,
    List<Level>? levels,
    GameSession? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GameState(
      status: status ?? this.status,
      levels: levels ?? this.levels,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
