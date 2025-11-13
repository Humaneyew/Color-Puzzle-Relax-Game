import 'package:flutter/material.dart';

import '../../domain/entities/tile.dart';

class ColorTile extends StatefulWidget {
  const ColorTile({
    super.key,
    required this.tile,
    this.onTap,
    this.isSelected = false,
    this.isDropTarget = false,
    this.isDragging = false,
    this.reducedMotion = false,
  });

  final Tile tile;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDropTarget;
  final bool isDragging;
  final bool reducedMotion;

  @override
  State<ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  bool _isPressed = false;

  Duration get _pressDuration => widget.reducedMotion
      ? Duration.zero
      : const Duration(milliseconds: 120);

  double get _targetScale {
    if (widget.isDragging) {
      return 1.05;
    }
    if (_isPressed) {
      return 0.95;
    }
    if (widget.isSelected) {
      return 0.98;
    }
    return 1.0;
  }

  @override
  void didUpdateWidget(ColorTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion && _isPressed) {
      _isPressed = false;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.reducedMotion || widget.onTap == null) {
      return;
    }
    setState(() => _isPressed = true);
  }

  void _handleTapCancel() {
    if (!_isPressed) {
      return;
    }
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.onTap == null) {
      return;
    }
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnchor = widget.tile.isAnchor;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Widget tileContent = ColoredBox(
      color: widget.tile.color,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (isAnchor)
            Positioned(
              top: 8,
              right: 8,
              child: Text(
                '×',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colors.onSurface.withOpacity(0.4),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : _handleTapDown,
      onTapCancel: widget.onTap == null ? null : _handleTapCancel,
      onTapUp: widget.onTap == null
          ? null
          : (TapUpDetails details) {
              if (_isPressed) {
                setState(() => _isPressed = false);
              }
            },
      onTap: widget.onTap == null ? null : _handleTap,
      child: AnimatedScale(
        scale: _targetScale,
        duration: _pressDuration,
        curve: Curves.easeOut,
        child: tileContent,
      ),
    );
  }
}
