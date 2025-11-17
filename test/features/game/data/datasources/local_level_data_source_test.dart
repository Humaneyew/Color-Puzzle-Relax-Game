import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/core/constants/app_constants.dart';
import 'package:color_puzzle_relax_game/src/features/game/data/datasources/local_level_data_source.dart';

void main() {
  test('second level uses a 5x7 board configuration', () async {
    final LocalLevelDataSource dataSource = LocalLevelDataSource();

    final levels = await dataSource.loadLevels();

    expect(levels, isNotEmpty);

    final firstLevel = levels.first;
    expect(firstLevel.boardColumns, AppConstants.defaultBoardColumns);
    expect(firstLevel.boardRows, AppConstants.defaultBoardRows);

    final secondLevel = levels[1];
    expect(secondLevel.boardColumns, AppConstants.defaultBoardColumns);
    expect(secondLevel.boardRows, 7);
  });
}
