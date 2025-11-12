import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/reward_dialog.dart';
import '../data/game_result.dart';
import '../data/level.dart';
import '../logic/game_session.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({
    required this.level,
    required this.result,
    super.key,
  });

  final GradientPuzzleLevel level;
  final GameResult result;

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
        final session = context.read<GameSession>();
        final bestScore = session.bestScoreForLevel(widget.level.id);
        final average = _estimateWorldAverage(widget.level);
        showDialog<void>(
          context: context,
          builder: (_) => RewardDialog(
            levelName: widget.level.name,
            result: widget.result,
            bestScore: bestScore,
            worldAverage: average,
            onContinue: _goToNextLevel,
            onRetry: _retryLevel,
            onShare: _shareResults,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'LEVEL COMPLETED!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.fast_forward_rounded),
                    label: const Text('NEXT'),
                    onPressed: () {
                      unawaited(_goToNextLevel());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.level.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Hero(
                    tag: widget.level.id,
                    child: _LevelPreview(level: widget.level),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  unawaited(_returnToLevelSelect());
                },
                icon: const Icon(Icons.map_rounded),
                label: const Text('Choose another level'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToNextLevel() async {
    final session = context.read<GameSession>();
    final currentIndex = session.levels.indexOf(widget.level);
    if (currentIndex >= 0 && currentIndex + 1 < session.levels.length) {
      final nextLevel = session.levels[currentIndex + 1];
      if (session.isLevelUnlocked(nextLevel)) {
        final navigator = Navigator.of(context);
        await session.selectLevel(nextLevel);
        if (!mounted || !navigator.mounted) {
          return;
        }
        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const GameScreen(),
          ),
        );
        return;
      }
    }
    if (!mounted) return;
    await _returnToLevelSelect();
  }

  Future<void> _returnToLevelSelect() async {
    final navigator = Navigator.of(context);
    if (!navigator.mounted) return;
    await navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LevelSelectScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _retryLevel() async {
    final session = context.read<GameSession>();
    final navigator = Navigator.of(context);
    await session.selectLevel(widget.level);
    if (!mounted || !navigator.mounted) return;
    await navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const GameScreen(),
      ),
    );
  }

  Future<void> _shareResults() async {
    if (!mounted) return;
    final hintLabel = widget.result.hintsUsed == 0
        ? 'no hints'
        : '${widget.result.hintsUsed} hint${widget.result.hintsUsed == 1 ? '' : 's'}';
    final rewardSummary = <String>[];
    if (widget.result.livesEarned > 0) {
      rewardSummary.add('+${widget.result.livesEarned} life');
    }
    if (widget.result.rewardsEarned > 0) {
      rewardSummary.add('+${widget.result.rewardsEarned} pts');
    }
    final rewardLabel = rewardSummary.isEmpty
        ? ''
        : ' (${rewardSummary.join(', ')})';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shared ${widget.level.name}: ${widget.result.moves} moves in '
          '${_formatDuration(widget.result.duration)} with $hintLabel$rewardLabel.',
        ),
      ),
    );
  }

  int _estimateWorldAverage(GradientPuzzleLevel level) {
    final base = level.tileCount;
    return (base * 1.4).round();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _LevelPreview extends StatelessWidget {
  const _LevelPreview({required this.level});

  final GradientPuzzleLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = constraints.biggest.shortestSide;
        return Container(
          width: dimension,
          height: dimension,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: level.gridSize,
            ),
            itemCount: level.tileCount,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: level.colorForIndex(index),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
