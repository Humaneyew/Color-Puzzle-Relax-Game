import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/game_state.dart';
import '../data/level.dart';
import 'game_board_controller.dart';
import '../data/game_result.dart';
import 'services/ad_service.dart';
import '../data/player_progress.dart';
import 'services/progress_repository.dart';

class GameSession extends ChangeNotifier {
  /// Maximum number of lives a player can have at any time.
  static const int maxLives = 5;

  /// Maximum number of hints a player can store without watching an ad.
  static const int maxHints = 5;

  /// Lives granted when a new session is created or fully reset.
  static const int initialLives = 5;

  /// Hints granted when a new session is created or fully reset.
  static const int initialHints = 3;

  GameSession({
    required this.levels,
    required AdService adService,
    required ProgressRepository progressRepository,
  })  : _adService = adService,
        _progressRepository = progressRepository,
        _progress = PlayerProgress.initial(levels) {
    _applyProgress(_progress);
  }

  final List<GradientPuzzleLevel> levels;
  final AdService _adService;
  final ProgressRepository _progressRepository;

  GradientPuzzleLevel? _currentLevel;
  GameBoardController? _controller;
  int _currentLevelIndex = 0;

  int _lives = initialLives;
  int _hints = initialHints;
  int _rewards = 0;
  int _highestUnlocked = 0;
  PlayerProgress _progress;

  GradientPuzzleLevel? get currentLevel => _currentLevel;

  GameBoardController? get controller => _controller;

  int get lives => _lives;

  int get hints => _hints;

  bool get isLivesFull => _lives >= maxLives;

  bool get isHintsFull => _hints >= maxHints;

  int get rewards => _rewards;

  int get currentLevelIndex => _currentLevelIndex;

  int get highestUnlocked => _highestUnlocked;

  int? bestScoreForLevel(String levelId) {
    return _progress.progressFor(levelId).bestMoves;
  }

  bool isLevelCompleted(GradientPuzzleLevel level) {
    return _progress.isLevelCompleted(level.id);
  }

  Future<void> restore() async {
    final stored = await _progressRepository.loadProgress(levels);
    _progress = stored;
    _applyProgress(_progress);
    notifyListeners();
  }

  GameStateSnapshot get snapshot => GameStateSnapshot(
        levelId: _currentLevel?.id,
        lives: _lives,
        hints: _hints,
        rewards: _rewards,
        highestUnlocked: _highestUnlocked,
        moveCount: _controller?.moveCount ?? 0,
      );

  bool isLevelUnlocked(GradientPuzzleLevel level) {
    final index = levels.indexOf(level);
    if (index < 0) {
      return false;
    }
    return _progress.isLevelUnlocked(level.id);
  }

  bool get isOutOfLives => _lives <= 0;

  void selectLevel(GradientPuzzleLevel level) {
    if (!isLevelUnlocked(level)) {
      return;
    }
    _currentLevel = level;
    _currentLevelIndex = levels.indexOf(level);
    _controller = GameBoardController(level);
    _progress = _progress.withCurrentLevel(level.id);
    unawaited(_progressRepository.saveProgress(_progress));
    notifyListeners();
  }

  GameResult recordCompletion(GradientPuzzleLevel level, int moves,
      {required Duration duration, required int hintsUsed}) {
    final levelIndex = levels.indexOf(level);
    final previousProgress = _progress.progressFor(level.id);
    final previousBest = previousProgress.bestMoves;
    final bool shouldUpdateBest =
        previousBest == null || moves < previousBest;
    final bool flawlessSolve = hintsUsed == 0;
    final efficiencyCap = (level.tileCount * 3) ~/ 2;
    final efficiencyThreshold =
        efficiencyCap < level.tileCount ? level.tileCount : efficiencyCap;
    final bool efficientSolve = moves <= efficiencyThreshold;
    var rewardsEarned = 1;
    if (shouldUpdateBest) {
      rewardsEarned += 1;
    }
    if (flawlessSolve) {
      rewardsEarned += 1;
    }
    final livesEarned = flawlessSolve && efficientSolve ? 1 : 0;
    if (levelIndex >= 0) {
      final updatedLevel = previousProgress.copyWith(
        status: LevelStatus.completed,
        bestMoves: shouldUpdateBest ? moves : previousBest,
      );
      _progress = _progress.updateLevel(updatedLevel);
      final nextIndex = levelIndex + 1;
      if (nextIndex < levels.length) {
        final nextLevel = levels[nextIndex];
        _progress = _progress.unlockLevel(nextLevel.id);
      }
      _progress = _progress.withCurrentLevel(level.id);
      _highestUnlocked = _progress.highestUnlockedIndex(levels);
      unawaited(_progressRepository.saveProgress(_progress));
    }
    if (rewardsEarned > 0) {
      _rewards += rewardsEarned;
    }
    var appliedLives = 0;
    if (livesEarned > 0 && !isLivesFull) {
      final before = _lives;
      _lives = (_lives + livesEarned).clamp(0, maxLives);
      appliedLives = _lives - before;
    }
    notifyListeners();
    return GameResult(
      levelId: level.id,
      moves: moves,
      hintsUsed: hintsUsed,
      duration: duration,
      livesEarned: appliedLives,
      rewardsEarned: rewardsEarned,
      isNewRecord: shouldUpdateBest,
    );
  }

  /// Consumes a life when the player makes an invalid move.
  ///
  /// Lives will never drop below zero and listeners are notified about the
  /// change so the UI can react (e.g. to show warnings or disable actions).
  void decrementLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  /// Attempts to restore a single life by showing a rewarded ad.
  ///
  /// Returns `true` if the ad was completed and a life was granted. When the
  /// player is already at the life cap no ad is shown and `false` is returned.
  Future<bool> watchAdForLife() async {
    if (isLivesFull) {
      return false;
    }
    final result = await _adService.showRewardedAd();
    if (result) {
      _lives = (_lives + 1).clamp(0, maxLives);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Applies a hint on the current board and consumes one stored hint.
  ///
  /// Returns the index that was solved or highlighted. If the board is already
  /// solved or there were no hints available, `-1` is returned and no changes
  /// are made to the game board.
  Future<int> applyHint() async {
    if (_hints <= 0) {
      return -1;
    }
    final index = _controller?.applyHint() ?? -1;
    if (index >= 0) {
      _hints--;
      notifyListeners();
    }
    return index;
  }

  /// Attempts to grant an additional hint after watching a rewarded ad.
  ///
  /// Returns `true` if the hint was granted. When the hint storage is already
  /// full the ad is skipped and `false` is returned.
  Future<bool> watchAdForHint() async {
    if (isHintsFull) {
      return false;
    }
    final result = await _adService.showRewardedAd();
    if (result) {
      _hints = (_hints + 1).clamp(0, maxHints);
      notifyListeners();
      return true;
    }
    return false;
  }

  void resetSession() {
    _lives = initialLives;
    _hints = initialHints;
    _rewards = 0;
    _progress = PlayerProgress.initial(levels);
    _applyProgress(_progress);
    unawaited(_progressRepository.saveProgress(_progress));
    _controller?.reset();
    notifyListeners();
  }

  void _applyProgress(PlayerProgress progress) {
    _highestUnlocked = progress.highestUnlockedIndex(levels);
    final currentIndex = progress.currentLevelIndex(levels) ?? 0;
    if (levels.isEmpty) {
      _currentLevel = null;
      _controller = null;
      _currentLevelIndex = 0;
      return;
    }
    final index = currentIndex.clamp(0, levels.length - 1);
    final level = levels[index];
    _currentLevel = level;
    _currentLevelIndex = index;
    _controller = GameBoardController(level);
  }
}
