import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/game_state_models.dart';
import '../data/gradient_puzzle_level.dart';
import '../data/level_progress.dart';
import 'game_board_controller.dart';
import '../services/ad_service.dart';
import '../services/progress_storage.dart';

class GameSession extends ChangeNotifier {
  GameSession({
    required this.levels,
    required AdService adService,
    required ProgressStorage progressStorage,
    LevelProgress initialProgress = const LevelProgress.initial(),
  })  : _adService = adService,
        _progressStorage = progressStorage,
        _progress = initialProgress,
        _highestUnlocked = initialProgress.highestUnlockedLevelIndex,
        _bestScores = Map<String, int>.from(initialProgress.bestScores),
        _completedLevels = Set<String>.from(initialProgress.completedLevelIds) {
    if (levels.isNotEmpty) {
      _highestUnlocked =
          _highestUnlocked.clamp(0, levels.length - 1) as int;
      final startIndex = _highestUnlocked;
      selectLevel(levels[startIndex]);
    }
  }

  final List<GradientPuzzleLevel> levels;
  final AdService _adService;
  final ProgressStorage _progressStorage;

  GradientPuzzleLevel? _currentLevel;
  GameBoardController? _controller;
  int _currentLevelIndex = 0;

  int _lives = 5;
  int _hints = 3;
  int _rewards = 0;
  int _highestUnlocked = 0;
  final Map<String, int> _bestScores;
  final Set<String> _completedLevels;
  LevelProgress _progress;
  GameResult? _lastResult;

  GradientPuzzleLevel? get currentLevel => _currentLevel;

  GameBoardController? get controller => _controller;

  int get lives => _lives;

  int get hints => _hints;

  int get rewards => _rewards;

  int get currentLevelIndex => _currentLevelIndex;

  int get highestUnlocked => _highestUnlocked;

  int? bestScoreForLevel(String levelId) => _bestScores[levelId];

  LevelProgress get progress => _progress;

  GameResult? get lastResult => _lastResult;

  GameStateSnapshot? get snapshot {
    final current = _currentLevel;
    final controller = _controller;
    if (current == null || controller == null) {
      return null;
    }
    return GameStateSnapshot(
      level: current,
      moves: controller.moveCount,
      lives: _lives,
      hints: _hints,
      rewards: _rewards,
      highestUnlockedLevelIndex: _highestUnlocked,
    );
  }

  bool isLevelUnlocked(GradientPuzzleLevel level) {
    final index = levels.indexOf(level);
    if (index < 0) {
      return false;
    }
    return index <= _highestUnlocked;
  }

  bool get isOutOfLives => _lives <= 0;

  void selectLevel(GradientPuzzleLevel level) {
    if (!isLevelUnlocked(level)) {
      return;
    }
    _currentLevel = level;
    _currentLevelIndex = levels.indexOf(level);
    _controller = GameBoardController(level);
    _lastResult = null;
    notifyListeners();
  }

  void recordCompletion(GradientPuzzleLevel level, int moves) {
    final levelIndex = levels.indexOf(level);
    if (levelIndex >= 0) {
      _completedLevels.add(level.id);
      if (levelIndex + 1 < levels.length) {
        if (_highestUnlocked < levelIndex + 1) {
          _highestUnlocked = levelIndex + 1;
        }
      } else {
        _highestUnlocked = levels.length - 1;
      }
      final best = _bestScores[level.id];
      if (best == null || moves < best) {
        _bestScores[level.id] = moves;
      }
    }
    final controller = _controller;
    if (controller != null) {
      _lastResult = controller.buildResult();
    }
    _persistProgress();
    notifyListeners();
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

  void rewardPlayer() {
    _rewards++;
    notifyListeners();
  }

  void resetSession() {
    _lives = 5;
    _hints = 3;
    _rewards = 0;
    _highestUnlocked = 0;
    _bestScores.clear();
    _completedLevels.clear();
    _progress = const LevelProgress.initial();
    unawaited(_progressStorage.clear());
    _lastResult = null;
    if (levels.isNotEmpty) {
      selectLevel(levels.first);
    }
    _controller?.reset();
  }

  void _persistProgress() {
    _progress = LevelProgress(
      highestUnlockedLevelIndex: _highestUnlocked,
      bestScores: Map<String, int>.from(_bestScores),
      completedLevelIds: Set<String>.from(_completedLevels),
    );
    unawaited(_progressStorage.save(_progress));
  }
}
