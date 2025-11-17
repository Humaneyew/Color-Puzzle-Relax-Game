import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/features/game/data/datasources/local_level_data_source.dart';
import 'package:color_puzzle_relax_game/src/features/game/data/models/level_model.dart';
import 'package:color_puzzle_relax_game/src/features/game/data/models/puzzle_level_model.dart';
import 'package:color_puzzle_relax_game/src/features/game/data/repositories/game_repository_impl.dart';
import 'package:color_puzzle_relax_game/src/features/game/domain/entities/game_session.dart';

class _FakeLevelDataSource implements LevelDataSource {
  _FakeLevelDataSource(this._puzzle);

  final PuzzleLevelModel _puzzle;

  @override
  Future<PuzzleLevelModel> loadPuzzle(String levelId) async {
    if (levelId != _puzzle.levelId) {
      throw ArgumentError('Unknown level: $levelId');
    }
    return _puzzle;
  }

  @override
  Future<List<LevelModel>> loadLevels() async {
    return <LevelModel>[
      LevelModel(
        id: _puzzle.levelId,
        title: 'Test',
        description: 'Test puzzle',
        difficulty: 1,
        boardColumns: _puzzle.cols,
        boardRows: _puzzle.rows,
        isUnlocked: true,
      ),
    ];
  }

  @override
  Future<void> persistProgress(List<LevelModel> levels) async {}
}

void main() {
  test('startSession handles duplicate colors for anchors and tiles', () async {
    final PuzzleLevelModel puzzle = PuzzleLevelModel(
      id: 1,
      rows: 3,
      cols: 3,
      solution: const <List<String>>[
        <String>['#FF00FF', '#00FF00', '#FF00FF'],
        <String>['#00FFFF', '#00FF00', '#00FFFF'],
        <String>['#FF00FF', '#00FF00', '#FF00FF'],
      ],
      anchors: const <List<bool>>[
        <bool>[true, true, true],
        <bool>[false, false, false],
        <bool>[true, true, true],
      ],
      start: const <List<String>>[
        <String>['#FF00FF', '#00FF00', '#FF00FF'],
        <String>['#00FFFF', '#00FF00', '#00FFFF'],
        <String>['#FF00FF', '#00FF00', '#FF00FF'],
      ],
      palette: const <String>['#FF00FF', '#00FF00', '#00FFFF'],
    );

    final List<List<String>> start = <List<String>>[
      <String>['#FF00FF', '#00FF00', '#FF00FF'],
      <String>['#00FFFF', '#00FFFF', '#00FF00'],
      <String>['#FF00FF', '#00FF00', '#FF00FF'],
    ];
    final PuzzleLevelModel startable = PuzzleLevelModel(
      id: puzzle.id,
      rows: puzzle.rows,
      cols: puzzle.cols,
      solution: puzzle.solution,
      anchors: puzzle.anchors,
      start: start,
      palette: puzzle.palette,
    );

    final GameRepositoryImpl repository =
        GameRepositoryImpl(_FakeLevelDataSource(startable));

    final GameSession session = await repository.startSession(startable.levelId);
    expect(session.board.tiles.length, 9);
    expect(session.board.countMisplacedTiles(includeAnchors: true), greaterThanOrEqualTo(0));
    expect(session.board.anchors.length, 6);
  });
}
