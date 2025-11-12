import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/game_header.dart';
import '../data/game_state.dart';
import '../data/level.dart';
import '../logic/game_session.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();
    final levels = session.levels;
    final state = session.snapshot;
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entranceAnimation,
          builder: (context, _) {
            return Padding(
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
                  const SizedBox(height: 20),
                  Transform.translate(
                    offset: Offset(0, 20 * (1 - _entranceAnimation.value)),
                    child: Opacity(
                      opacity: _entranceAnimation.value,
                      child: const _ModeCard(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Transform.translate(
                    offset: Offset(0, 16 * (1 - _entranceAnimation.value)),
                    child: Opacity(
                      opacity: _entranceAnimation.value,
                      child: const _LifeHintInfoCard(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _LevelGrid(
                      levels: levels,
                      currentIndex: session.currentLevelIndex,
                      highestUnlocked: state.highestUnlocked,
                      isLevelCompleted: session.isLevelCompleted,
                      entranceAnimation: _entranceAnimation,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
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
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.9),
              theme.colorScheme.secondaryContainer.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Relaxing and elegant. No pressure.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
              ),
            ],
          ),
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
      color: theme.colorScheme.secondaryContainer.withOpacity(0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Як працюють життя та підказки',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            const _RuleBullet(
              text:
                  'За кожну помилку віднімається 1 життя. Дивіться рекламу або проходьте рівні без помилок, щоб відновити життя.',
            ),
            const SizedBox(height: 8),
            const _RuleBullet(
              text:
                  'Ви починаєте з ${GameSession.initialLives} життями. Максимальний запас — ${GameSession.maxLives}.',
            ),
            const SizedBox(height: 8),
            const _RuleBullet(
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
    required this.entranceAnimation,
  });

  final List<GradientPuzzleLevel> levels;
  final int currentIndex;
  final int highestUnlocked;
  final bool Function(GradientPuzzleLevel level) isLevelCompleted;
  final Animation<double> entranceAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCount = (levels.length / 5).ceil() * 5;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 620
            ? 6
            : width > 480
                ? 5
                : 4;
        final spacing = width > 480 ? 16.0 : 12.0;
        return AnimatedBuilder(
          animation: entranceAnimation,
          builder: (context, _) {
            final animationValue = entranceAnimation.value;
            return GridView.builder(
              itemCount: totalCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
              ),
              itemBuilder: (context, index) {
                final delay = math.min(index * 0.04, 0.6);
                final activation = (animationValue - delay).clamp(0.0, 1.0);
                final eased = Curves.easeOutBack.transform(activation);
                final opacity = activation;
                final translateY = (1 - eased) * 18;
                final scale = 0.92 + eased * 0.08;

                if (index >= levels.length) {
                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: _LockedLevelBadge(theme: theme),
                      ),
                    ),
                  );
                }

                final level = levels[index];
                final unlocked = index <= highestUnlocked;
                final isCurrent = index == currentIndex;
                final completed = isLevelCompleted(level);
                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Hero(
                        tag: level.id,
                        child: _LevelBadge(
                          index: index,
                          unlocked: unlocked,
                          isCurrent: isCurrent,
                          completed: completed,
                          onTap: unlocked
                              ? () async {
                                  final session = context.read<GameSession>();
                                  final navigator = Navigator.of(context);
                                  await session.selectLevel(level);
                                  if (!navigator.mounted) return;
                                  await navigator.push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const GameScreen(),
                                    ),
                                  );
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Unlock previous levels to continue.',
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.inverseSurface,
                                    ),
                                  );
                                },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
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
            ? theme.colorScheme.primaryContainer.withOpacity(0.75)
            : theme.colorScheme.surfaceVariant.withOpacity(0.55);
    final borderColor = isCurrent
        ? theme.colorScheme.primary
        : unlocked
            ? theme.colorScheme.primary.withOpacity(0.25)
            : theme.colorScheme.outline.withOpacity(0.35);
    final foreground = isCurrent
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface.withOpacity(unlocked ? 0.85 : 0.55);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: unlocked ? 1.2 : 1,
          ),
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
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.25),
        ),
      ),
      child: Icon(
        Icons.lock,
        color: theme.colorScheme.onSurface.withOpacity(0.35),
      ),
    );
  }
}
