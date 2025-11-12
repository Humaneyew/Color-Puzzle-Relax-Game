import 'package:flutter_test/flutter_test.dart';

import 'package:color_puzzle_relax_game/src/core/di/injection_container.dart';
import 'package:color_puzzle_relax_game/src/features/game/presentation/state/game_notifier.dart';
import 'package:color_puzzle_relax_game/src/features/game/presentation/state/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    serviceLocator.reset(dispose: true);
    await configureDependencies();
  });

  test('GameNotifier loads levels on initialize', () async {
    final GameNotifier notifier = GameNotifier();

    await notifier.initialize();

    expect(notifier.state.status, GameStatus.ready);
    expect(notifier.state.levels, isNotEmpty);
  });
}
