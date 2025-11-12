import 'package:flutter/material.dart';

import '../data/game_result.dart';

class RewardDialog extends StatelessWidget {
  const RewardDialog({
    required this.levelName,
    required this.result,
    required this.bestScore,
    required this.worldAverage,
    required this.onContinue,
    required this.onRetry,
    required this.onShare,
    super.key,
  });

  final String levelName;
  final GameResult result;
  final int? bestScore;
  final int worldAverage;
  final Future<void> Function() onContinue;
  final Future<void> Function() onRetry;
  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Future<void> handle(Future<void> Function() action) async {
      Navigator.of(context).pop();
      await action();
    }

    final rewardBadges = <Widget>[];
    if (result.livesEarned > 0) {
      rewardBadges.add(_Badge(
        icon: Icons.favorite,
        label: '+${result.livesEarned} life',
        background: const Color(0xFFFFE3D3),
        iconColor: const Color(0xFFDF7F5B),
      ));
    }
    if (result.rewardsEarned > 0) {
      rewardBadges.add(_Badge(
        icon: Icons.stars_rounded,
        label: '+${result.rewardsEarned} points',
        background: theme.colorScheme.primary.withOpacity(0.15),
        iconColor: theme.colorScheme.primary,
      ));
    }

    final achievementBadges = <Widget>[];
    if (result.isNewRecord) {
      achievementBadges.add(_Tag(text: 'New record'));
    }
    if (result.hintsUsed == 0) {
      achievementBadges.add(_Tag(text: 'No hints used'));
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Level complete',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              levelName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (rewardBadges.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: rewardBadges,
              ),
            if (achievementBadges.isNotEmpty) ...[
              if (rewardBadges.isNotEmpty) const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: achievementBadges,
              ),
            ],
            if (rewardBadges.isNotEmpty || achievementBadges.isNotEmpty)
              const SizedBox(height: 16),
            _RewardStat(
              label: 'Moves',
              value: result.moves.toString(),
            ),
            _RewardStat(
              label: 'Time',
              value: _formatDuration(result.duration),
            ),
            _RewardStat(
              label: 'Hints used',
              value: result.hintsUsed.toString(),
            ),
            _RewardStat(
              label: 'Best score',
              value: bestScore?.toString() ?? '-',
            ),
            _RewardStat(
              label: 'World average',
              value: worldAverage.toString(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => handle(onContinue),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('CONTINUE'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => handle(onRetry),
              icon: const Icon(Icons.replay),
              label: const Text('RETRY'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => handle(onShare),
              icon: const Icon(Icons.share),
              label: const Text('SHARE RESULT'),
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

class _RewardStat extends StatelessWidget {
  const _RewardStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
