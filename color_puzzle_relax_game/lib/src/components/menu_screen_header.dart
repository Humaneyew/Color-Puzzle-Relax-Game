import 'package:flutter/material.dart';

class MenuScreenHeader extends StatelessWidget {
  const MenuScreenHeader({
    super.key,
    required this.lives,
    required this.title,
    required this.subtitle,
    this.onPrimaryAction,
    this.primaryActionIcon = Icons.play_arrow_rounded,
  });

  final int lives;
  final String title;
  final String subtitle;
  final VoidCallback? onPrimaryAction;
  final IconData primaryActionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            _LivesIndicator(lives: lives),
            const Spacer(),
            IconButton(
              onPressed: onPrimaryAction,
              icon: Icon(primaryActionIcon, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: i == 1 ? 18 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == 1
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LivesIndicator extends StatelessWidget {
  const _LivesIndicator({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Color(0xFFDF7F5B)),
          const SizedBox(width: 8),
          Text(
            lives.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
