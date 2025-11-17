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
    if (puzzle.solution.length != puzzle.rows ||
        puzzle.start.length != puzzle.rows ||
        puzzle.anchors.length != puzzle.rows) {
      throw StateError('Puzzle ${puzzle.id} has inconsistent row counts.');
    }

    void validateColumns<T>(List<List<T>> matrix) {
      for (final List<T> row in matrix) {
        if (row.length != puzzle.cols) {
          throw StateError('Puzzle ${puzzle.id} has inconsistent column counts.');
        }
      }
    }

    validateColumns<String>(puzzle.solution);
    validateColumns<String>(puzzle.start);
    validateColumns<bool>(puzzle.anchors);

    final List<Tile> tiles = <Tile>[];
    final List<Color> solutionColors = <Color>[];
    for (int r = 0; r < puzzle.rows; r++) {
      for (int c = 0; c < puzzle.cols; c++) {
        final int index = r * puzzle.cols + c;
        final String solutionHex = puzzle.solution[r][c];
        final String startHex = puzzle.start[r][c];
        final bool isAnchor = puzzle.anchors[r][c];
        if (isAnchor && startHex != solutionHex) {
          throw StateError(
            'Anchor at ($r, $c) in level ${puzzle.id} must match the solution.',
          );
        }
        solutionColors.add(_colorFromHex(solutionHex));
        tiles.add(
          Tile(
            id: index,
            currentIndex: index,
            color: _colorFromHex(startHex),
            isAnchor: isAnchor,
          ),
        );
      }
    }

    return Board(
      columns: puzzle.cols,
      rows: puzzle.rows,
      tiles: tiles,
      solutionColors: solutionColors,
    );
  }

  Color _colorFromHex(String hex) {
    final String value = hex.startsWith('#') ? hex.substring(1) : hex;
    final int intValue = int.parse(value, radix: 16);
    return Color(0xFF000000 | intValue);
  }
}
