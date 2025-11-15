import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/tile.dart';
import '../../domain/usecases/get_levels.dart';
import '../../domain/usecases/save_progress.dart';
import '../../domain/usecases/start_level.dart';
import 'game_state.dart';

class GameNotifier extends ChangeNotifier {
  GameNotifier()
      : _getLevels = serviceLocator(),
        _startLevel = serviceLocator(),
        _saveProgress = serviceLocator();

  final GetLevelsUseCase _getLevels;
  final StartLevelUseCase _startLevel;
  final SaveProgressUseCase _saveProgress;

  GameState _state = const GameState();

  GameState get state => _state;

  Future<void> initialize() async {
    await loadLevels();
  }

  Future<void> loadLevels() async {
    _updateState(
      _state.copyWith(
        status: GameStatus.loading,
        bestScore: null,
        worldAverage: null,
        hintsRemaining: 0,
        isProvidingHint: false,
        isSharing: false,
      ),
    );
    try {
      final List<Level> levels = await _getLevels();
      _updateState(
        _state.copyWith(
          status: GameStatus.ready,
          levels: levels,
          clearError: true,
          showResults: false,
          showVictoryWave: false,
          hasSavedCompletion: false,
          bestScore: null,
          worldAverage: null,
          hintsRemaining: 0,
          isProvidingHint: false,
          isSharing: false,
        ),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(
          status: GameStatus.error,
          errorMessage: error.toString(),
          isProvidingHint: false,
          isSharing: false,
        ),
      );
    }
  }

  Future<void> startLevel(String levelId) async {
      _updateState(
        _state.copyWith(
          status: GameStatus.loading,
          clearError: true,
          showVictoryWave: false,
          showResults: false,
          hasSavedCompletion: false,
          isProvidingHint: false,
          isSharing: false,
        ),
      );

    try {
      final GameSession session = await _startLevel(levelId);
      _updateState(
        _state.copyWith(
          status: GameStatus.inSession,
          session: session,
          showVictoryWave: false,
          showResults: false,
          hasSavedCompletion: false,
          bestScore: session.bestScore,
          worldAverage: session.worldAverage,
          hintsRemaining: session.hintsRemaining,
          isProvidingHint: false,
          isSharing: false,
        ),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(
          status: GameStatus.error,
          errorMessage: error.toString(),
          isProvidingHint: false,
          isSharing: false,
        ),
      );
    }
  }

  Future<void> completeCurrentSession() async {
    final GameSession? session = _state.session;
    if (session == null) {
      return;
    }

    try {
      if (!_state.hasSavedCompletion) {
        await _saveProgress(session);
      }
      _updateState(
        _state.copyWith(
          status: GameStatus.ready,
          clearSession: true,
          showVictoryWave: false,
          showResults: false,
          hasSavedCompletion: false,
          bestScore: null,
          worldAverage: null,
          hintsRemaining: 0,
          isProvidingHint: false,
          isSharing: false,
        ),
      );
      await loadLevels();
    } catch (error) {
      _updateState(
        _state.copyWith(
          status: GameStatus.error,
          errorMessage: error.toString(),
          isProvidingHint: false,
          isSharing: false,
        ),
      );
    }
  }

  void abandonSession() {
    if (_state.session == null) {
      return;
    }
    _updateState(
        _state.copyWith(
          status: GameStatus.ready,
          clearSession: true,
          showVictoryWave: false,
          showResults: false,
          hasSavedCompletion: false,
          bestScore: null,
          worldAverage: null,
          hintsRemaining: 0,
          isProvidingHint: false,
          isSharing: false,
        ),
      );
  }

  void swapTiles(int fromIndex, int toIndex) {
    final GameSession? session = _state.session;
    if (session == null) {
      return;
    }

    if (_state.showResults) {
      return;
    }

    final Board board = session.board;
    if (fromIndex == toIndex) {
      return;
    }

    final Tile first = board.tileAt(fromIndex);
    final Tile second = board.tileAt(toIndex);

    if (first.isAnchor || second.isAnchor) {
      return;
    }

    final List<Tile> updatedTiles = List<Tile>.from(board.tiles);
    updatedTiles[fromIndex] = second.copyWith(currentIndex: fromIndex);
    updatedTiles[toIndex] = first.copyWith(currentIndex: toIndex);

    final Board updatedBoard = board.copyWith(tiles: updatedTiles);
    GameSession updatedSession = session.copyWith(
      board: updatedBoard,
      movesUsed: session.movesUsed + 1,
    );

    final bool solved = updatedBoard.isSolved();
    int? bestScore = updatedSession.bestScore;
    if (solved) {
      final int currentScore = updatedSession.movesUsed;
      bestScore =
          bestScore == null ? currentScore : min(bestScore, currentScore);
      updatedSession = updatedSession.copyWith(bestScore: bestScore);
    }

    final GameState previousState = _state;
    final bool shouldSave = solved && !previousState.hasSavedCompletion;

    _updateState(
      previousState.copyWith(
        session: updatedSession,
        showVictoryWave: solved,
        showResults: solved || previousState.showResults,
        hasSavedCompletion:
            solved ? (previousState.hasSavedCompletion || shouldSave) : false,
        bestScore: bestScore,
        worldAverage: updatedSession.worldAverage,
        hintsRemaining: updatedSession.hintsRemaining,
      ),
    );

    if (shouldSave) {
      unawaited(_saveProgress(updatedSession).then((_) => _refreshLevels()));
    }
  }

  void provideHint() {
    final GameSession? session = _state.session;
    if (session == null) {
      return;
    }

    if (_state.showResults ||
        _state.showVictoryWave ||
        _state.status == GameStatus.loading) {
      return;
    }

    if (session.hintsRemaining <= 0 || _state.isProvidingHint) {
      return;
    }

    _updateState(_state.copyWith(isProvidingHint: true));

    final Board board = session.board;
    final List<Tile> candidates = board.movables
        .where((Tile tile) => !tile.isInCorrectPosition)
        .toList();
    if (candidates.isEmpty) {
      _updateState(_state.copyWith(isProvidingHint: false));
      return;
    }

    final Tile target = candidates.first;
    final Tile swapTile = board.tileAt(target.correctIndex);

    final List<Tile> updatedTiles = List<Tile>.from(board.tiles);
    updatedTiles[target.currentIndex] =
        swapTile.copyWith(currentIndex: target.currentIndex);
    updatedTiles[target.correctIndex] =
        target.copyWith(currentIndex: target.correctIndex);

    final Board updatedBoard = board.copyWith(tiles: updatedTiles);
    GameSession updatedSession = session.copyWith(
      board: updatedBoard,
      movesUsed: session.movesUsed + 1,
      hintsRemaining: session.hintsRemaining - 1,
    );

    final bool solved = updatedBoard.isSolved();
    int? bestScore = updatedSession.bestScore;
    if (solved) {
      final int currentScore = updatedSession.movesUsed;
      bestScore =
          bestScore == null ? currentScore : min(bestScore, currentScore);
      updatedSession = updatedSession.copyWith(bestScore: bestScore);
    }

    final GameState previousState = _state;
    final bool shouldSave = solved && !previousState.hasSavedCompletion;

    _updateState(
      previousState.copyWith(
        session: updatedSession,
        showVictoryWave: solved,
        showResults: solved || previousState.showResults,
        hasSavedCompletion:
            solved ? (previousState.hasSavedCompletion || shouldSave) : false,
        bestScore: bestScore,
        worldAverage: updatedSession.worldAverage,
        hintsRemaining: updatedSession.hintsRemaining,
        isProvidingHint: false,
      ),
    );

    if (shouldSave) {
      unawaited(_saveProgress(updatedSession).then((_) => _refreshLevels()));
    }
  }

  Future<void> shareProgress({bool allowDuringOverlay = false}) async {
    final GameSession? session = _state.session;
    if (session == null) {
      return;
    }

    if (!allowDuringOverlay && (_state.showResults || _state.showVictoryWave)) {
      return;
    }

    if (_state.isSharing || _state.status == GameStatus.loading) {
      return;
    }

    _updateState(_state.copyWith(isSharing: true));

    final String levelValue =
        session.level.title.isNotEmpty ? session.level.title : session.level.id;
    final String message =
        'I just solved "$levelValue" in ${session.movesUsed} moves in Color Puzzle Relax!';

    try {
      await Share.share(
        message,
        subject: 'Color Puzzle Relax',
      );
    } finally {
      _updateState(_state.copyWith(isSharing: false));
    }
  }

  void dismissVictoryWave() {
    if (!_state.showVictoryWave) {
      return;
    }
    _updateState(
      _state.copyWith(showVictoryWave: false),
    );
  }

  void resetResults() {
    if (!_state.showResults && !_state.showVictoryWave) {
      return;
    }
    _updateState(
      _state.copyWith(
        showResults: false,
        showVictoryWave: false,
        isProvidingHint: false,
      ),
    );
  }

  String? nextLevelId() {
    final GameSession? session = _state.session;
    if (session == null) {
      return null;
    }
    final int currentIndex =
        _state.levels.indexWhere((Level level) => level.id == session.level.id);
    if (currentIndex == -1 || currentIndex + 1 >= _state.levels.length) {
      return null;
    }
    return _state.levels[currentIndex + 1].id;
  }

  Future<void> _refreshLevels() async {
    try {
      final List<Level> levels = await _getLevels();
      _updateState(
        _state.copyWith(levels: levels),
      );
    } catch (_) {
      // Ignore refresh errors while in-session.
    }
  }

  void _updateState(GameState state) {
    _state = state;
    notifyListeners();
  }
}
