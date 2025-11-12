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

  int _lives = 5;
  int _hints = 3;
  int _rewards = 0;
  int _highestUnlocked = 0;
  PlayerProgress _progress;

  GradientPuzzleLevel? get currentLevel => _currentLevel;

  GameBoardController? get controller => _controller;

  int get lives => _lives;

  int get hints => _hints;

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
    if (livesEarned > 0) {
      _lives += livesEarned;
    }
    notifyListeners();
    return GameResult(
      levelId: level.id,
      moves: moves,
      hintsUsed: hintsUsed,
      duration: duration,
      livesEarned: livesEarned,
      rewardsEarned: rewardsEarned,
      isNewRecord: shouldUpdateBest,
    );
  }

  void decrementLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  Future<void> watchAdForLife() async {
    final result = await _adService.showRewardedAd();
    if (result) {
      _lives++;
      notifyListeners();
    }
  }

  Future<int> applyHint() async {
    if (_hints <= 0) {
      return -1;
    }
    _hints--;
    notifyListeners();
    return _controller?.applyHint() ?? -1;
  }

  Future<void> watchAdForHint() async {
    final result = await _adService.showRewardedAd();
    if (result) {
      _hints++;
      notifyListeners();
    }
  }

  void resetSession() {
    _lives = 5;
    _hints = 3;
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
