import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/level.dart';
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
      _state.copyWith(status: GameStatus.loading, clearError: true),
    );

    try {
      final GameSession session = await _startLevel(levelId);
      _updateState(
        _state.copyWith(
          status: GameStatus.inSession,
          session: session,
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
      await _saveProgress(session);
      _updateState(
        _state.copyWith(
          status: GameStatus.ready,
          clearSession: true,
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

  void _updateState(GameState state) {
    _state = state;
    notifyListeners();
  }
}
