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
  return <LevelModel>[
    LevelModel(
      id: 'level_1',
      title: 'Basic Mode',
      description: 'Relaxing and elegant. No pressure.',
      difficulty: 1,
      boardSize: 4,
      isUnlocked: true,
    ),
    LevelModel(
      id: 'level_2',
      title: 'Gradient Flow',
      description: 'Introduce diagonal color shifts.',
      difficulty: 2,
      boardSize: 5,
      isUnlocked: false,
    ),
    LevelModel(
      id: 'level_3',
      title: 'Chromatic Symphony',
      description: 'Complex palette transitions.',
      difficulty: 3,
      boardSize: 6,
      isUnlocked: false,
    ),
  ];
}
