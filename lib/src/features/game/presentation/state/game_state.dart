import '../../../game/domain/entities/game_session.dart';
import '../../../game/domain/entities/level.dart';

enum GameStatus { initial, loading, ready, inSession, error }

class GameState {
  const GameState({
    this.status = GameStatus.initial,
    this.levels = const <Level>[],
    this.session,
    this.errorMessage,
    this.showVictoryWave = false,
    this.showResults = false,
    this.hasSavedCompletion = false,
  });

  final GameStatus status;
  final List<Level> levels;
  final GameSession? session;
  final String? errorMessage;
  final bool showVictoryWave;
  final bool showResults;
  final bool hasSavedCompletion;

  GameState copyWith({
    GameStatus? status,
    List<Level>? levels,
    GameSession? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearError = false,
    bool? showVictoryWave,
    bool? showResults,
    bool? hasSavedCompletion,
  }) {
    return GameState(
      status: status ?? this.status,
      levels: levels ?? this.levels,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showVictoryWave: showVictoryWave ?? this.showVictoryWave,
      showResults: showResults ?? this.showResults,
      hasSavedCompletion: hasSavedCompletion ?? this.hasSavedCompletion,
    );
  }
}
