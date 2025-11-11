import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/level.dart';
import '../widgets/reward_dialog.dart';
import 'level_select_screen.dart';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({
    required this.level,
    required this.moves,
    required this.hintsUsed,
    required this.duration,
    super.key,
  });

  final GradientPuzzleLevel level;
  final int moves;
  final int hintsUsed;
  final Duration duration;

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rewards = context.read<GameSession>().rewards;
        showDialog<void>(
          context: context,
          builder: (_) => RewardDialog(
            rewardCount: rewards,
            onContinue: () => Navigator.of(context).pop(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рівень завершено')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.level.id,
              child: Text(
                widget.level.name,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 24),
            _StatRow(label: 'Ходи', value: widget.moves.toString()),
            _StatRow(label: 'Підказки', value: widget.hintsUsed.toString()),
            _StatRow(
              label: 'Час',
              value: _formatDuration(widget.duration),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              icon: const Icon(Icons.replay),
              label: const Text('Грати ще раз'),
              onPressed: () {
                final session = context.read<GameSession>();
                session.selectLevel(widget.level);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const LevelSelectScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const LevelSelectScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('До вибору рівнів'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
