import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/game_header.dart';
import '../data/game_state.dart';
import '../data/level.dart';
import '../logic/game_session.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();
    final theme = Theme.of(context);
    final levels = session.levels;
    final state = session.snapshot;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameHeader(
                title: 'Color Puzzle',
                subtitle: 'Choose a level to start',
                state: state,
                onSettingsTap: () => _showComingSoon(context),
                onShopTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 24),
              const _ModeCard(),
              const SizedBox(height: 24),
              const _LifeHintInfoCard(),
              const SizedBox(height: 24),
              Expanded(
                child: _LevelGrid(
                  levels: levels,
                  currentIndex: session.currentLevelIndex,
                  highestUnlocked: state.highestUnlocked,
                  isLevelCompleted: session.isLevelCompleted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
      ),
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

class _LifeHintInfoCard extends StatelessWidget {
  const _LifeHintInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Як працюють життя та підказки',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            _RuleBullet(
              text:
                  'За кожну помилку віднімається 1 життя. Дивіться рекламу або проходьте рівні без помилок, щоб відновити життя.',
            ),
            SizedBox(height: 8),
            _RuleBullet(
              text:
                  'Ви починаєте з ${GameSession.initialLives} життями. Максимальний запас — ${GameSession.maxLives}.',
            ),
            SizedBox(height: 8),
            _RuleBullet(
              text:
                  'Початковий запас підказок — ${GameSession.initialHints}. Всього можна накопичити до ${GameSession.maxHints} підказок. Додаткові підказки доступні після перегляду реклами.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleBullet extends StatelessWidget {
  const _RuleBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({
    required this.levels,
    required this.currentIndex,
    required this.highestUnlocked,
    required this.isLevelCompleted,
  });

  final List<GradientPuzzleLevel> levels;
  final int currentIndex;
  final int highestUnlocked;
  final bool Function(GradientPuzzleLevel level) isLevelCompleted;

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
        final completed = isLevelCompleted(level);
        return Hero(
          tag: level.id,
          child: _LevelBadge(
            index: index,
            unlocked: unlocked,
            isCurrent: isCurrent,
            completed: completed,
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
    required this.completed,
    required this.onTap,
  });

  final int index;
  final bool unlocked;
  final bool isCurrent;
  final bool completed;
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
        child: Stack(
          children: [
            Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (completed)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: isCurrent
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
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
