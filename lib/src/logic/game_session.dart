import 'package:flutter/foundation.dart';

import 'package:color_puzzle_relax_game/src/data/models/game_result.dart';
import 'package:color_puzzle_relax_game/src/data/models/level.dart';
import 'package:color_puzzle_relax_game/src/logic/game_board.dart';
import 'package:color_puzzle_relax_game/src/logic/services/ad_service.dart';

class GameSession extends ChangeNotifier {
  GameSession({required this.levels, required AdService adService})
      : _adService = adService {
    selectLevel(levels.first);
  }

  final List<GradientPuzzleLevel> levels;
  final AdService _adService;

  GradientPuzzleLevel? _currentLevel;
  GameBoardController? _controller;
  int _currentLevelIndex = 0;

  int _lives = 5;
  int _hints = 3;
  int _rewards = 0;
  int _highestUnlocked = 0;
  final Map<String, int> _bestScores = {};
  final List<GameResult> _results = <GameResult>[];

  GradientPuzzleLevel? get currentLevel => _currentLevel;

  GameBoardController? get controller => _controller;

  int get lives => _lives;

  int get hints => _hints;

  int get rewards => _rewards;

  int get currentLevelIndex => _currentLevelIndex;

  int get highestUnlocked => _highestUnlocked;

  int? bestScoreForLevel(String levelId) => _bestScores[levelId];

  List<GameResult> get results => List.unmodifiable(_results);

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
    notifyListeners();
  }

  GameResult recordCompletion({
    required GradientPuzzleLevel level,
    required int moves,
    required Duration duration,
    required int hintsUsed,
  }) {
    final levelIndex = levels.indexOf(level);
    if (levelIndex >= 0) {
      if (_highestUnlocked < levelIndex + 1 && levelIndex + 1 < levels.length) {
        _highestUnlocked = levelIndex + 1;
      }
      final best = _bestScores[level.id];
      if (best == null || moves < best) {
        _bestScores[level.id] = moves;
      }
    }
    final result = GameResult(
      levelId: level.id,
      moves: moves,
      hintsUsed: hintsUsed,
      duration: duration,
      completedAt: DateTime.now(),
    );
    _results.add(result);
    notifyListeners();
    return result;
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
    _results.clear();
    if (levels.isNotEmpty) {
      selectLevel(levels.first);
    }
    _controller?.reset();
  }
}
