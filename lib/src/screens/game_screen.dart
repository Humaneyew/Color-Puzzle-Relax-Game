import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/game_board.dart';
import '../logic/game_board_controller.dart';
import '../logic/game_session.dart';
import 'level_complete_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameBoardController? _attachedController;
  int _observedInvalidMoves = 0;
  int _highlightedIndex = -1;
  int _hintsUsed = 0;
  String? _feedbackMessage;
  IconData? _feedbackIcon;
  Color _feedbackColor = Colors.transparent;
  Timer? _feedbackTimer;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachController();
  }

  void _attachController() {
    final session = context.read<GameSession>();
    final controller = session.controller;
    if (_attachedController == controller) {
      return;
    }
    _attachedController?.removeListener(_handleBoardChanged);
    _attachedController = controller;
    if (controller != null) {
      _observedInvalidMoves = controller.invalidMoves;
      controller.addListener(_handleBoardChanged);
    }
  }

  void _handleBoardChanged() {
    final session = context.read<GameSession>();
    final controller = _attachedController;
    if (controller == null || !mounted) {
      return;
    }
    if (controller.invalidMoves > _observedInvalidMoves) {
      _observedInvalidMoves = controller.invalidMoves;
      final previousLives = session.lives;
      session.decrementLife();
      final livesLeft = session.lives;
      if (previousLives > livesLeft) {
        _showFeedback(
          message: 'Помилка: -1 життя. Залишилось $livesLeft',
          icon: Icons.favorite,
          color: Theme.of(context).colorScheme.error,
        );
      }
      if (session.isOutOfLives) {
        _showOutOfLivesDialog();
      }
    }
    if (controller.isSolved) {
      final level = session.currentLevel;
      if (level != null) {
        final result = session.recordCompletion(
          level,
          controller.moveCount,
          duration: DateTime.now().difference(_startedAt),
          hintsUsed: _hintsUsed,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LevelCompleteScreen(
              level: level,
              result: result,
            ),
          ),
        );
      }
    }
  }

  void _showFeedback({
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
          _feedbackIcon = null;
        });
      }
    });
    setState(() {
      _feedbackMessage = message;
      _feedbackIcon = icon;
      _feedbackColor = color;
    });
  }

  Future<void> _handleRecoverLife() async {
    final session = context.read<GameSession>();
    if (session.isLivesFull) {
      _showFeedback(
        message: 'У вас вже максимальна кількість життів.',
        icon: Icons.favorite,
        color: Theme.of(context).colorScheme.secondary,
      );
      return;
    }
    final restored = await session.watchAdForLife();
    if (!mounted) return;
    if (restored) {
      _showFeedback(
        message:
            'Життя відновлено! ${session.lives}/${GameSession.maxLives}',
        icon: Icons.favorite,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      _showFeedback(
        message: 'Не вдалося отримати життя зараз.',
        icon: Icons.favorite_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _showOutOfLivesDialog() async {
    if (!mounted) return;
    final action = await showDialog<_OutOfLifeAction>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Закінчились життя'),
          content: const Text('Перегляньте коротку рекламу, щоб отримати ще одне життя.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(_OutOfLifeAction.none),
              child: const Text('Пізніше'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_OutOfLifeAction.watchAd),
              child: const Text('Переглянути'),
            ),
          ],
        );
      },
    );
    if (!mounted || action != _OutOfLifeAction.watchAd) {
      return;
    }
    await _handleRecoverLife();
  }

  @override
  void dispose() {
    _attachedController?.removeListener(_handleBoardChanged);
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSession>();
    final controller = session.controller;
    final level = session.currentLevel;
    if (controller == null || level == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GameHeader(
                levelNumber: session.currentLevelIndex + 1,
                moveCount: controller.moveCount,
                hintsRemaining: session.hints,
                livesRemaining: session.lives,
                onRecoverLife: _handleRecoverLife,
                onHintPressed: _handleHintPressed,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _feedbackMessage == null
                    ? const SizedBox.shrink()
                    : Padding(
                        key: ValueKey(_feedbackMessage),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _FeedbackBanner(
                          icon: _feedbackIcon ?? Icons.info_outline,
                          message: _feedbackMessage!,
                          color: _feedbackColor,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                level.name,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(letterSpacing: 1.1),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GradientGameBoard(
                  controller: controller,
                  level: level,
                  highlightedIndex: _highlightedIndex,
                  onTileDragged: (index) {
                    setState(() => _highlightedIndex = index);
                  },
                  onDragEnd: () {
                    if (mounted) {
                      setState(() => _highlightedIndex = -1);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onHintPressed() async {
    final session = context.read<GameSession>();
    final index = await session.applyHint();
    if (!mounted) return;
    if (index >= 0) {
      setState(() {
        _highlightedIndex = index;
        _hintsUsed++;
      });
      _showFeedback(
        message: 'Підказка використана. Залишилось ${session.hints}',
        icon: Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.primary,
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted && _highlightedIndex == index) {
        setState(() => _highlightedIndex = -1);
      }
    } else {
      _showFeedback(
        message: 'Підказка недоступна для цієї комірки.',
        icon: Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.secondary,
      );
    }
  }

  Future<void> _onWatchAdForHint() async {
    final session = context.read<GameSession>();
    if (session.isHintsFull) {
      _showFeedback(
        message: 'Підказок вже максимум.',
        icon: Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.secondary,
      );
      return;
    }
    final granted = await session.watchAdForHint();
    if (!mounted) return;
    if (granted) {
      _showFeedback(
        message: 'Отримано +1 підказку (${session.hints}/${GameSession.maxHints}).',
        icon: Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.primary,
      );
    } else {
      _showFeedback(
        message: 'Не вдалося отримати підказку зараз.',
        icon: Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _handleHintPressed() async {
    final session = context.read<GameSession>();
    if (session.hints > 0) {
      await _onHintPressed();
    } else {
      await _onWatchAdForHint();
    }
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.levelNumber,
    required this.moveCount,
    required this.hintsRemaining,
    required this.livesRemaining,
    required this.onRecoverLife,
    required this.onHintPressed,
  });

  final int levelNumber;
  final int moveCount;
  final int hintsRemaining;
  final int livesRemaining;
  final Future<void> Function() onRecoverLife;
  final Future<void> Function() onHintPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBadge(
          label: 'LEVEL',
          value: levelNumber.toString(),
        ),
        const Spacer(),
        _InfoBadge(
          label: 'MOVES',
          value: moveCount.toString(),
        ),
        const SizedBox(width: 12),
        _IconLabelButton(
          icon: Icons.favorite,
          label: 'LIVES',
          badgeText: '${livesRemaining}/${GameSession.maxLives}',
          onPressed: onRecoverLife,
          highlight: livesRemaining <= 1,
        ),
        const SizedBox(width: 12),
        _IconLabelButton(
          icon: Icons.share,
          label: 'SHARE',
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing will be available soon.')),
            );
          },
        ),
        const SizedBox(width: 12),
        _IconLabelButton(
          icon: Icons.lightbulb_outline,
          label: 'HINTS',
          badgeText: hintsRemaining > 0 ? 'x$hintsRemaining' : 'WATCH',
          onPressed: onHintPressed,
          highlight: hintsRemaining == 0,
        ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _OutOfLifeAction { none, watchAd }

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLabelButton extends StatelessWidget {
  const _IconLabelButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badgeText,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;
  final String? badgeText;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = highlight
        ? theme.colorScheme.secondary.withOpacity(0.2)
        : Colors.white.withOpacity(0.3);
    final iconColor = highlight
        ? theme.colorScheme.secondary
        : theme.colorScheme.onSurface.withOpacity(0.8);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onPressed(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(height: 2),
            Text(
              badgeText!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 11,
                color: highlight
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
