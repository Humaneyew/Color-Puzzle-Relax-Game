import 'dart:collection';
import 'dart:ui';

import '../../domain/entities/board.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/tile.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local_level_data_source.dart';
import '../models/level_model.dart';
import '../models/puzzle_level_model.dart';

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

    final PuzzleLevelModel puzzle = await _dataSource.loadPuzzle(levelId);
    final Board board = _buildBoardFromPuzzle(puzzle);

    return GameSession(
      level: level,
      board: board,
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

  Board _buildBoardFromPuzzle(PuzzleLevelModel puzzle) {
    final List<String> solution = puzzle.flattenSolution();
    final List<String> start = puzzle.flattenStart();
    if (solution.length != start.length) {
      throw StateError('Puzzle ${puzzle.id} has mismatched tile counts.');
    }

    final Map<String, Queue<int>> targetIndices = <String, Queue<int>>{};
    for (int index = 0; index < solution.length; index++) {
      targetIndices
          .putIfAbsent(solution[index], () => ListQueue<int>())
          .add(index);
    }

    final Set<int> anchors = puzzle.anchorIndices;
    final List<Tile> tiles = <Tile>[];
    for (int currentIndex = 0; currentIndex < start.length; currentIndex++) {
      final String colorHex = start[currentIndex];
      final Queue<int>? queue = targetIndices[colorHex];
      if (queue == null || queue.isEmpty) {
        throw StateError('Color $colorHex missing from solution for level ${puzzle.id}.');
      }
      final int correctIndex = queue.removeFirst();
      final bool isAnchor = anchors.contains(correctIndex);
      if (isAnchor && correctIndex != currentIndex) {
        throw StateError('Anchor mismatch detected in level ${puzzle.id}.');
      }
      tiles.add(
        Tile(
          correctIndex: correctIndex,
          currentIndex: currentIndex,
          color: _colorFromHex(colorHex),
          isAnchor: isAnchor,
        ),
      );
    }

    return Board(columns: puzzle.cols, rows: puzzle.rows, tiles: tiles);
  }

  Color _colorFromHex(String hex) {
    final String value = hex.startsWith('#') ? hex.substring(1) : hex;
    final int intValue = int.parse(value, radix: 16);
    return Color(0xFF000000 | intValue);
  }
}
