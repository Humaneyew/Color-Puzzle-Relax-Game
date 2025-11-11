import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_board.dart';
import '../models/game_state.dart';
import '../widgets/gradient_tile.dart';
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LevelCompleteScreen(
              level: level,
              moves: controller.moveCount,
              hintsUsed: _hintsUsed,
              duration: DateTime.now().difference(_startedAt),
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
      appBar: AppBar(
        title: Text(level.name),
        actions: [
          IconButton(
            tooltip: 'Отримати підказку',
            onPressed: session.hints > 0 ? _onHintPressed : null,
            icon: const Icon(Icons.lightbulb_outline),
          ),
          IconButton(
            tooltip: 'Показати рекламу за підказку',
            onPressed: _onWatchAdForHint,
            icon: const Icon(Icons.play_circle_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsBar(session, controller),
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildStatsBar(GameSession session, GameBoardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatChip(
              icon: Icons.favorite,
              label: 'Життя',
              value: session.lives.toString(),
            ),
            _StatChip(
              icon: Icons.lightbulb,
              label: 'Підказки',
              value: session.hints.toString(),
            ),
            _StatChip(
              icon: Icons.swap_vert,
              label: 'Ходи',
              value: controller.moveCount.toString(),
            ),
          ],
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
