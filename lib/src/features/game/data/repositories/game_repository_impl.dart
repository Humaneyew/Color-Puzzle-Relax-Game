import '../../domain/entities/game_board.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/level.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local_level_data_source.dart';
import '../models/level_model.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._dataSource);

  final LevelDataSource _dataSource;

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

    return GameSession(
      level: level,
      board: GameBoard.empty(level.boardSize),
      movesUsed: 0,
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

    updated[index] = updated[index].copyWith(isUnlocked: true);

    if (index + 1 < updated.length) {
      final LevelModel next = updated[index + 1];
      updated[index + 1] = next.copyWith(isUnlocked: true);
    }

    await _dataSource.persistProgress(updated);
  }
}
