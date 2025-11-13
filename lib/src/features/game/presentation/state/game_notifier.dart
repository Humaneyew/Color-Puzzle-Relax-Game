import 'dart:async';

import 'package:flutter/foundation.dart';

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
    _updateState(_state.copyWith(status: GameStatus.loading));
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
        ),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(
          status: GameStatus.error,
          errorMessage: error.toString(),
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
        ),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(
          status: GameStatus.error,
          errorMessage: error.toString(),
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
        ),
      );
      await loadLevels();
    } catch (error) {
      _updateState(
        _state.copyWith(
          status: GameStatus.error,
          errorMessage: error.toString(),
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
    final GameSession updatedSession = session.copyWith(
      board: updatedBoard,
      movesUsed: session.movesUsed + 1,
    );

    final bool solved = updatedBoard.isSolved();

    _updateState(
      _state.copyWith(
        session: updatedSession,
        showVictoryWave: solved,
        showResults: solved || _state.showResults,
        hasSavedCompletion: solved ? _state.hasSavedCompletion : false,
      ),
    );

    if (solved && !_state.hasSavedCompletion) {
      unawaited(_saveProgress(updatedSession).then((_) => _refreshLevels()));
      _updateState(
        _state.copyWith(
          hasSavedCompletion: true,
        ),
      );
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
