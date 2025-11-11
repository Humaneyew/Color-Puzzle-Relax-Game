import 'package:flutter/material.dart';

class RewardDialog extends StatelessWidget {
  const RewardDialog({
    required this.livesEarned,
    required this.moveCount,
    required this.bestScore,
    required this.worldAverage,
    required this.onContinue,
    required this.onViewPuzzle,
    required this.onRetry,
    required this.onShare,
    super.key,
  });

  final int livesEarned;
  final int moveCount;
  final int? bestScore;
  final int worldAverage;
  final VoidCallback onContinue;
  final VoidCallback onViewPuzzle;
  final VoidCallback onRetry;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE3D3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFFDF7F5B),
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Awesome!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '+$livesEarned Heart',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _RewardStat(label: 'Move Count', value: moveCount.toString()),
            _RewardStat(
              label: 'Best Score',
              value: bestScore?.toString() ?? '-',
            ),
            _RewardStat(
              label: 'World Average',
              value: worldAverage.toString(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('CONTINUE'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onViewPuzzle,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('VIEW PUZZLE'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay),
                    label: const Text('RETRY'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share),
                    label: const Text('SHARE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
