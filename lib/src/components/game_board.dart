import 'dart:math';

import 'package:flutter/material.dart';

import '../data/level.dart';
import '../data/tile.dart';
import '../logic/game_board_controller.dart';
import 'gradient_tile.dart';

/// Game board that renders the puzzle grid and handles tile interactions.
class GradientGameBoard extends StatelessWidget {
  const GradientGameBoard({
    required this.controller,
    required this.level,
    required this.highlightedIndex,
    required this.onTileDragged,
    required this.onDragEnd,
    super.key,
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
        final boardExtent = min(constraints.maxWidth, constraints.maxHeight);
        final tileSlotSize = boardExtent / level.gridSize;
        final tileExtent = max(24.0, tileSlotSize - 8);
        final boardSize = tileSlotSize * level.gridSize;
        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _BoardGridPainter(
                    gridSize: level.gridSize,
                    fixedCells: level.fixedCells,
                  ),
                ),
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: level.gridSize,
                  ),
                  itemCount: level.tileCount,
                  itemBuilder: (context, index) {
                    final tile = controller.tileAt(index);
                    return AnimatedScale(
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
                  },
                ),
              ],
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

class _BoardGridPainter extends CustomPainter {
  _BoardGridPainter({
    required this.gridSize,
    required this.fixedCells,
  });

  final int gridSize;
  final Set<int> fixedCells;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fixedPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (final index in fixedCells) {
      final row = index ~/ gridSize;
      final col = index % gridSize;
      final rect = Rect.fromLTWH(
        col * cellSize,
        row * cellSize,
        cellSize,
        cellSize,
      ).deflate(4);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      canvas.drawRRect(rRect, fixedPaint);
    }

    for (var i = 0; i <= gridSize; i++) {
      final position = i * cellSize;
      canvas.drawLine(Offset(position, 0), Offset(position, size.height), gridPaint);
      canvas.drawLine(Offset(0, position), Offset(size.width, position), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardGridPainter oldDelegate) {
    if (oldDelegate.gridSize != gridSize) {
      return true;
    }
    if (oldDelegate.fixedCells.length != fixedCells.length) {
      return true;
    }
    for (final value in fixedCells) {
      if (!oldDelegate.fixedCells.contains(value)) {
        return true;
      }
    }
    for (final value in oldDelegate.fixedCells) {
      if (!fixedCells.contains(value)) {
        return true;
      }
    }
    return false;
  }
}
