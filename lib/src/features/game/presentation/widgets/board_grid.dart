import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/tile.dart';
import '../state/board_controller.dart';
import 'color_tile.dart';

class BoardGrid extends StatefulWidget {
  const BoardGrid({
    super.key,
    required this.board,
    required this.controller,
    this.disableInteractions = false,
  });

  final Board board;
  final BoardController controller;
  final bool disableInteractions;

  static const Duration _swapDuration = Duration(milliseconds: 220);

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  int? _hoverIndex;
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final Duration swapDuration = reducedMotion ? Duration.zero : BoardGrid._swapDuration;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        final int gridSize = widget.board.size;

        final bool hasFiniteWidth = maxWidth.isFinite;
        final bool hasFiniteHeight = maxHeight.isFinite;

        final double fallbackExtent = gridSize.toDouble();

        final double availableWidth = hasFiniteWidth
            ? math.max(maxWidth, 0)
            : (hasFiniteHeight ? math.max(maxHeight, 0) : fallbackExtent);
        final double availableHeight = hasFiniteHeight
            ? math.max(maxHeight, 0)
            : (hasFiniteWidth ? math.max(maxWidth, 0) : fallbackExtent);

        final double tileWidth = availableWidth / gridSize;
        final double tileHeight = availableHeight / gridSize;
        final double boardWidth = tileWidth * gridSize;
        final double boardHeight = tileHeight * gridSize;

        return SizedBox(
          width: hasFiniteWidth ? availableWidth : boardWidth,
          height: hasFiniteHeight ? availableHeight : boardHeight,
          child: Stack(
            children: widget.board.tiles.map((Tile tile) {
              return _AnimatedTile(
                key: ValueKey<int>(tile.correctIndex),
                tile: tile,
                tileWidth: tileWidth,
                tileHeight: tileHeight,
                gridSize: widget.board.size,
                controller: widget.controller,
                disableInteractions:
                    widget.disableInteractions || widget.controller.isLocked,
                reducedMotion: reducedMotion,
                swapDuration: swapDuration,
                hoverIndex: _hoverIndex,
                draggingIndex: _draggingIndex,
                onHoverChanged: _handleHoverChanged,
                onDragChanged: _handleDragChanged,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handleHoverChanged(int? index, bool isHovering) {
    setState(() {
      if (!isHovering && _hoverIndex == index) {
        _hoverIndex = null;
      } else if (isHovering) {
        _hoverIndex = index;
      }
    });
  }

  void _handleDragChanged(int index, bool isDragging) {
    setState(() {
      if (!isDragging && _draggingIndex == index) {
        _draggingIndex = null;
      } else if (isDragging) {
        _draggingIndex = index;
      }
    });
  }
}

class _AnimatedTile extends StatelessWidget {
  const _AnimatedTile({
    super.key,
    required this.tile,
    required this.tileWidth,
    required this.tileHeight,
    required this.gridSize,
    required this.controller,
    required this.disableInteractions,
    required this.reducedMotion,
    required this.swapDuration,
    required this.hoverIndex,
    required this.draggingIndex,
    required this.onHoverChanged,
    required this.onDragChanged,
  });

  final Tile tile;
  final double tileWidth;
  final double tileHeight;
  final int gridSize;
  final BoardController controller;
  final bool disableInteractions;
  final bool reducedMotion;
  final Duration swapDuration;
  final int? hoverIndex;
  final int? draggingIndex;
  final void Function(int? index, bool isHovering) onHoverChanged;
  final void Function(int index, bool isDragging) onDragChanged;

  @override
  Widget build(BuildContext context) {
    final int row = tile.currentIndex ~/ gridSize;
    final int column = tile.currentIndex % gridSize;
    final double top = row * tileHeight;
    final double left = column * tileWidth;

    return AnimatedPositioned(
      duration: swapDuration,
      curve: Curves.easeOutCubic,
      top: top,
      left: left,
      width: tileWidth,
      height: tileHeight,
      child: _TileDraggable(
        tile: tile,
        tileWidth: tileWidth,
        tileHeight: tileHeight,
        controller: controller,
        disableInteractions: disableInteractions,
        reducedMotion: reducedMotion,
        isHover: hoverIndex == tile.currentIndex,
        isDragging: draggingIndex == tile.currentIndex,
        onHoverChanged: onHoverChanged,
        onDragChanged: onDragChanged,
      ),
    );
  }
}

class _TileDraggable extends StatefulWidget {
  const _TileDraggable({
    required this.tile,
    required this.tileWidth,
    required this.tileHeight,
    required this.controller,
    required this.disableInteractions,
    required this.reducedMotion,
    required this.isHover,
    required this.isDragging,
    required this.onHoverChanged,
    required this.onDragChanged,
  });

  final Tile tile;
  final double tileWidth;
  final double tileHeight;
  final BoardController controller;
  final bool disableInteractions;
  final bool reducedMotion;
  final bool isHover;
  final bool isDragging;
  final void Function(int? index, bool isHovering) onHoverChanged;
  final void Function(int index, bool isDragging) onDragChanged;

  @override
  State<_TileDraggable> createState() => _TileDraggableState();
}

class _TileDraggableState extends State<_TileDraggable> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final bool isSelected =
            widget.controller.isTileSelected(widget.tile.currentIndex);
        final bool canInteract = !widget.disableInteractions;

        final ColorTile baseTile = ColorTile(
          tile: widget.tile,
          isSelected: isSelected,
          isDropTarget: widget.isHover,
          isDragging: widget.isDragging,
          reducedMotion: widget.reducedMotion,
          onTap: canInteract
              ? () => widget.controller.handleTap(widget.tile.currentIndex)
              : null,
        );

        if (!canInteract || widget.tile.isAnchor) {
          return baseTile;
        }

        return DragTarget<int>(
          onWillAccept: (int? data) {
            final bool accept =
                data != null && data != widget.tile.currentIndex && !widget.tile.isAnchor;
            widget.onHoverChanged(widget.tile.currentIndex, accept);
            return accept;
          },
          onAccept: (int fromIndex) {
            widget.onHoverChanged(widget.tile.currentIndex, false);
            widget.controller.swap(fromIndex, widget.tile.currentIndex);
          },
          onLeave: (_) => widget.onHoverChanged(widget.tile.currentIndex, false),
          builder: (BuildContext context, List<int?> candidateData, List<dynamic> rejectedData) {
            final bool isActiveTarget = candidateData.isNotEmpty || widget.isHover;
            return Draggable<int>(
              data: widget.tile.currentIndex,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              onDragStarted: () =>
                  widget.onDragChanged(widget.tile.currentIndex, true),
              onDraggableCanceled: (_, __) =>
                  widget.onDragChanged(widget.tile.currentIndex, false),
              onDragEnd: (_) => widget.onDragChanged(widget.tile.currentIndex, false),
              feedback: SizedBox(
                width: widget.tileWidth,
                height: widget.tileHeight,
                child: ColorTile(
                  tile: widget.tile,
                  isSelected: true,
                  isDropTarget: false,
                  isDragging: true,
                  reducedMotion: widget.reducedMotion,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: baseTile,
              ),
              child: ColorTile(
                tile: widget.tile,
                isSelected: isSelected,
                isDropTarget: isActiveTarget,
                isDragging: widget.isDragging,
                reducedMotion: widget.reducedMotion,
                onTap: () => widget.controller.handleTap(widget.tile.currentIndex),
              ),
            );
          },
        );
      },
    );
  }
}
