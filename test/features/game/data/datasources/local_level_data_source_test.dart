import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/features/game/data/datasources/local_level_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads curated puzzle data from assets', () async {
    final LocalLevelDataSource dataSource = LocalLevelDataSource();

    final levels = await dataSource.loadLevels();
    expect(levels.length, 50);

    final firstLevel = levels.first;
    expect(firstLevel.boardColumns, 7);
    expect(firstLevel.boardRows, 3);

    final secondLevel = levels[1];
    expect(secondLevel.boardColumns, 5);
    expect(secondLevel.boardRows, 5);

    final puzzle = await dataSource.loadPuzzle(firstLevel.id);
    expect(puzzle.cols, firstLevel.boardColumns);
    expect(puzzle.rows, firstLevel.boardRows);
    expect(puzzle.flattenStart(), isNot(equals(puzzle.flattenSolution())));
    final bool hasAnchors =
        puzzle.anchors.any((List<bool> row) => row.any((bool cell) => cell));
    expect(hasAnchors, isTrue);
  });
}
