import 'package:flutter/material.dart';

import '../data/game_state.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.state,
    this.onSettingsTap,
    this.onShopTap,
  });

  final String title;
  final String subtitle;
  final GameStateSnapshot state;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onShopTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      letterSpacing: 2,
      fontWeight: FontWeight.w700,
    );
    final subtitleStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: titleStyle),
                  const SizedBox(height: 6),
                  Text(subtitle, style: subtitleStyle),
                ],
              ),
            ),
            _RoundIconButton(
              icon: Icons.settings_outlined,
              onPressed: onSettingsTap,
            ),
            const SizedBox(width: 12),
            _RoundIconButton(
              icon: Icons.shopping_bag_outlined,
              onPressed: onShopTap,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatChip(
              icon: Icons.favorite,
              label: state.lives.toString(),
              backgroundColor: Colors.white.withOpacity(0.35),
              iconColor: const Color(0xFFDF7F5B),
            ),
            _StatChip(
              icon: Icons.lightbulb_outline,
              label: state.hints.toString(),
              backgroundColor: Colors.white.withOpacity(0.3),
              iconColor: theme.colorScheme.primary,
            ),
            _StatChip(
              icon: Icons.stars_rounded,
              label: state.rewards.toString(),
              backgroundColor: Colors.white.withOpacity(0.3),
              iconColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white.withOpacity(0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 22,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ),
    );
  }
}
