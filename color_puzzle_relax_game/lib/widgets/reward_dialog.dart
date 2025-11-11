import 'package:flutter/material.dart';

class RewardDialog extends StatelessWidget {
  const RewardDialog({
    required this.rewardCount,
    required this.onContinue,
    super.key,
  });

  final int rewardCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFC857),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Вітаємо!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ви отримали $rewardCount нагород.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Продовжити'),
            ),
          ],
        ),
      ),
    );
  }
}
