import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/gradient_tile.dart';
import '../data/tile.dart';
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
      session.decrementLife();
      if (session.isOutOfLives) {
        _showOutOfLivesDialog();
      }
    }
    if (controller.isSolved) {
      final level = session.currentLevel;
      if (level != null) {
        session.rewardPlayer();
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

  Future<void> _showOutOfLivesDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        final session = context.watch<GameSession>();
        return AlertDialog(
          title: const Text('Закінчились життя'),
          content: const Text('Перегляньте коротку рекламу, щоб отримати ще одне життя.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Пізніше'),
            ),
            FilledButton(
              onPressed: () async {
                await session.watchAdForLife();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Переглянути'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _attachedController?.removeListener(_handleBoardChanged);
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
                onHintPressed: _handleHintPressed,
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
                child: _BoardView(
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
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted && _highlightedIndex == index) {
        setState(() => _highlightedIndex = -1);
      }
    }
  }

  Future<void> _onWatchAdForHint() async {
    final session = context.read<GameSession>();
    await session.watchAdForHint();
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
    required this.onHintPressed,
  });

  final int levelNumber;
  final int moveCount;
  final int hintsRemaining;
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

class _BoardView extends StatelessWidget {
  const _BoardView({
    required this.controller,
    required this.level,
    required this.highlightedIndex,
    required this.onTileDragged,
    required this.onDragEnd,
  });

  final GameBoardController controller;
  final GradientPuzzleLevel level;
  final int highlightedIndex;
  final ValueChanged<int> onTileDragged;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final tileSize = size / level.gridSize;
        final tileExtent = max(24.0, tileSize - 8);
        return Center(
          child: SizedBox(
            width: tileSize * level.gridSize,
            height: tileSize * level.gridSize,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: level.gridSize,
              ),
              itemCount: level.tileCount,
              itemBuilder: (context, index) {
                final tile = controller.tileAt(index);
                final tileWidget = AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: highlightedIndex == index ? 1.05 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _TileDraggable(
                      index: index,
                      tile: tile,
                      tileSize: tileExtent,
                      isHighlighted: highlightedIndex == index,
                      controller: controller,
                      onTileDragged: onTileDragged,
                      onDragEnd: onDragEnd,
                    ),
                  ),
                );
                return tileWidget;
              },
            ),
          ),
        );
      },
    );
  }
}

class _TileDraggable extends StatelessWidget {
  const _TileDraggable({
    required this.index,
    required this.tile,
    required this.tileSize,
    required this.isHighlighted,
    required this.controller,
    required this.onTileDragged,
    required this.onDragEnd,
  });

  final int index;
  final GradientTile tile;
  final double tileSize;
  final bool isHighlighted;
  final GameBoardController controller;
  final ValueChanged<int> onTileDragged;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final child = _TileDropTarget(
      index: index,
      controller: controller,
      tileSize: tileSize,
      tile: tile,
      isHighlighted: isHighlighted,
      onDragEnd: onDragEnd,
    );

    if (tile.fixed) {
      return child;
    }

    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: tileSize,
          height: tileSize,
          child: GradientTileWidget(
            tile: tile,
            size: tileSize,
            isHighlighted: true,
          ),
        ),
      ),
      onDragStarted: () => onTileDragged(index),
      onDragEnd: (_) => onDragEnd(),
      childWhenDragging: GradientTileWidget(
        tile: tile,
        size: tileSize,
        isHighlighted: false,
        dimmed: true,
      ),
      child: child,
    );
  }
}

class _TileDropTarget extends StatelessWidget {
  const _TileDropTarget({
    required this.index,
    required this.controller,
    required this.tileSize,
    required this.tile,
    required this.isHighlighted,
    required this.onDragEnd,
  });

  final int index;
  final GameBoardController controller;
  final double tileSize;
  final GradientTile tile;
  final bool isHighlighted;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAccept: (data) => data != null,
      onAccept: (fromIndex) {
        controller.swapTiles(fromIndex, index);
        onDragEnd();
      },
      builder: (context, candidateData, rejectedData) {
        return GradientTileWidget(
          tile: tile,
          size: tileSize,
          isHighlighted: isHighlighted || candidateData.isNotEmpty,
        );
      },
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
