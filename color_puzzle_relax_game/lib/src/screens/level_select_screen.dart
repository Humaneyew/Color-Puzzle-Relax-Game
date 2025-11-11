import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/gradient_puzzle_level.dart';
import '../logic/game_session.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();
    final theme = Theme.of(context);
    final levels = session.levels;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(lives: session.lives),
              const SizedBox(height: 24),
              _TitleHeader(theme: theme),
              const SizedBox(height: 24),
              const _ModeCard(),
              const SizedBox(height: 24),
              Expanded(
                child: _LevelGrid(
                  levels: levels,
                  currentIndex: session.currentLevelIndex,
                  highestUnlocked: session.highestUnlocked,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
        ),
      ],
    );
  }
}

class _TitleHeader extends StatelessWidget {
  const _TitleHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'COLOR\nPUZZLE',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a Level to Start',
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

class _ModeCard extends StatelessWidget {
  const _ModeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.blur_on,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Mode',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Relaxing and elegant. No pressure.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({
    required this.levels,
    required this.currentIndex,
    required this.highestUnlocked,
  });

  final List<GradientPuzzleLevel> levels;
  final int currentIndex;
  final int highestUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCount = (levels.length / 5).ceil() * 5;
    return GridView.builder(
      itemCount: totalCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        if (index >= levels.length) {
          return _LockedLevelBadge(theme: theme);
        }
        final level = levels[index];
        final unlocked = index <= highestUnlocked;
        final isCurrent = index == currentIndex;
        return Hero(
          tag: level.id,
          child: _LevelBadge(
            index: index,
            unlocked: unlocked,
            isCurrent: isCurrent,
            onTap: unlocked
                ? () {
                    context.read<GameSession>().selectLevel(level);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GameScreen(),
                      ),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unlock previous levels to continue.'),
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.index,
    required this.unlocked,
    required this.isCurrent,
    required this.onTap,
  });

  final int index;
  final bool unlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isCurrent
        ? theme.colorScheme.primary
        : unlocked
            ? Colors.white.withOpacity(0.5)
            : Colors.white.withOpacity(0.25);
    final foreground = isCurrent
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface.withOpacity(unlocked ? 0.8 : 0.5);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (isCurrent)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedLevelBadge extends StatelessWidget {
  const _LockedLevelBadge({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.lock,
        color: theme.colorScheme.onSurface.withOpacity(0.35),
      ),
    );
  }
}
