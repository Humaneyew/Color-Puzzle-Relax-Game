import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/game_session.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';
import 'game_screen.dart';

class LevelOverviewPage extends StatefulWidget {
  const LevelOverviewPage({super.key, required this.levelId});

  static const String routeName = 'level-overview';
  static const String routePath = '/play/:levelId';

  final String levelId;

  @override
  State<LevelOverviewPage> createState() => _LevelOverviewPageState();
}

class _LevelOverviewPageState extends State<LevelOverviewPage> {
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final GameNotifier notifier = context.read<GameNotifier>();
    final GameState state = context.watch<GameNotifier>().state;

    final bool isLoading = state.status == GameStatus.loading && _isStarting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Level identifier: ${widget.levelId}'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => _isStarting = true);
                      try {
                        await notifier.startLevel(widget.levelId);
                        if (!mounted) {
                          return;
                        }
                        context.go(GameScreen.pathFor(widget.levelId));
                      } finally {
                        if (mounted) {
                          setState(() => _isStarting = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start level'),
            ),
            const SizedBox(height: 24),
            if (state.status == GameStatus.inSession &&
                state.session?.level.id == widget.levelId)
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
