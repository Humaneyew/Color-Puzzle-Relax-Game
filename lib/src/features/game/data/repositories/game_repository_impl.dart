import '../../../../core/logic/board_generator.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/level_config.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local_level_data_source.dart';
import '../models/level_model.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._dataSource, this._boardGenerator);

  final LevelDataSource _dataSource;
  final BoardGenerator _boardGenerator;

  @override
  Future<List<Level>> fetchLevels() async {
    return _dataSource.loadLevels();
  }

  @override
  Future<GameSession> startSession(String levelId) async {
    final List<LevelModel> levels = await _dataSource.loadLevels();
    final LevelModel level = levels.firstWhere(
      (Level level) => level.id == levelId,
      orElse: () => throw ArgumentError('Unknown level: $levelId'),
    );

    final LevelConfig config = LevelConfig.fromLevel(level);
    final Board board = _boardGenerator.buildBoard(config);

    return GameSession(
      level: level,
      board: board,
      movesUsed: 0,
      bestScore: level.bestScore,
      worldAverage: level.worldAverage,
      hintsRemaining: level.hintsRemaining,
    );
  }

  @override
  Future<void> saveProgress(GameSession session) async {
    final List<LevelModel> levels = await _dataSource.loadLevels();
    final List<LevelModel> updated = List<LevelModel>.from(levels);

    final int index = updated.indexWhere((Level level) => level.id == session.level.id);
    if (index == -1) {
      throw ArgumentError('Cannot save progress for unknown level: ${session.level.id}');
    }

    updated[index] = updated[index].copyWith(
      isUnlocked: true,
      bestScore: session.bestScore,
      hintsRemaining: session.hintsRemaining,
    );

    if (index + 1 < updated.length) {
      final LevelModel next = updated[index + 1];
      updated[index + 1] = next.copyWith(isUnlocked: true);
    }

    await _dataSource.persistProgress(updated);
  }
}
