import 'package:flutter/foundation.dart';

import '../game_board.dart';
import 'level.dart';
import '../services/ad_service.dart';

class GameSession extends ChangeNotifier {
  GameSession({required this.levels, required AdService adService})
      : _adService = adService {
    selectLevel(levels.first);
  }

  final List<GradientPuzzleLevel> levels;
  final AdService _adService;

  GradientPuzzleLevel? _currentLevel;
  GameBoardController? _controller;

  int _lives = 5;
  int _hints = 3;
  int _rewards = 0;

  GradientPuzzleLevel? get currentLevel => _currentLevel;

  GameBoardController? get controller => _controller;

  int get lives => _lives;

  int get hints => _hints;

  int get rewards => _rewards;

  bool get isOutOfLives => _lives <= 0;

  void selectLevel(GradientPuzzleLevel level) {
    _currentLevel = level;
    _controller = GameBoardController(level);
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
    _controller?.reset();
    notifyListeners();
  }
}
