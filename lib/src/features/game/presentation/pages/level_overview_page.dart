import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/game_session.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';

class LevelOverviewPage extends StatelessWidget {
  const LevelOverviewPage({super.key, required this.levelId});

  static const String routeName = 'level-overview';
  static const String routePath = '/level/:levelId';

  final String levelId;

  @override
  Widget build(BuildContext context) {
    final GameNotifier notifier = context.read<GameNotifier>();
    final GameState state = context.watch<GameNotifier>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Level identifier: ' + levelId),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => notifier.startLevel(levelId),
              child: const Text('Start level'),
            ),
            const SizedBox(height: 24),
            if (state.status == GameStatus.inSession &&
                state.session?.level.id == levelId)
              _SessionSummary(session: state.session!),
          ],
        ),
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Board size: ${session.board.size}'),
            const SizedBox(height: 8),
            Text('Moves used: ${session.movesUsed}'),
          ],
        ),
      ),
    );
  }
}
