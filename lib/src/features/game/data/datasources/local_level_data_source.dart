import '../../../../core/constants/app_constants.dart';
import '../models/level_model.dart';

abstract class LevelDataSource {
  Future<List<LevelModel>> loadLevels();
  Future<void> persistProgress(List<LevelModel> levels);
}

class LocalLevelDataSource implements LevelDataSource {
  LocalLevelDataSource();

  List<LevelModel> _cache = _seedLevels();

  @override
  Future<List<LevelModel>> loadLevels() async {
    return List<LevelModel>.unmodifiable(_cache);
  }

  @override
  Future<void> persistProgress(List<LevelModel> levels) async {
    _cache = List<LevelModel>.from(levels);
  }
}

List<LevelModel> _seedLevels() {
  const int totalLevels = 500;
  return List<LevelModel>.generate(totalLevels, (int index) {
    final int levelNumber = index + 1;
    return LevelModel(
      id: 'level_$levelNumber',
      title: 'Level $levelNumber',
      description: 'Relax and solve puzzle $levelNumber.',
      difficulty: 1 + (index ~/ 50),
      boardSize: AppConstants.defaultBoardSize,
      isUnlocked: levelNumber == 1,
      bestScore: null,
      worldAverage: 20 + (index % 10) + (index ~/ 50) * 5,
      hintsRemaining: 3,
    );
  });
}
