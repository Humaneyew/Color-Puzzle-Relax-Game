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

  Duration get _animationDuration => widget.reducedMotion
      ? Duration.zero
      : const Duration(milliseconds: 220);

  double get _targetScale {
    if (widget.isDragging) {
      return 1.06;
    }
    if (widget.isDropTarget) {
      return 1.03;
    }
    if (_isPressed) {
      return 0.96;
    }
    if (widget.isSelected) {
      return 0.99;
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
    final bool hasHighlight =
        widget.isSelected || widget.isDropTarget || widget.isDragging;
    final double borderWidth = hasHighlight ? 3 : 1.4;
    final Color borderColor = hasHighlight
        ? Colors.white.withOpacity(widget.isDragging ? 0.9 : 0.8)
        : Colors.white.withOpacity(0.2);
    final double overlayOpacity = widget.isDragging
        ? 0.28
        : (widget.isDropTarget
            ? 0.22
            : (widget.isSelected
                ? 0.16
                : (hasHighlight ? 0.12 : 0.0)));
    final BorderRadius tileRadius = BorderRadius.circular(14);
    final List<BoxShadow> tileShadows = <BoxShadow>[
      if (hasHighlight)
        BoxShadow(
          color: Colors.white.withOpacity(0.28),
          blurRadius: 20,
          spreadRadius: -8,
        ),
      BoxShadow(
        color: colors.shadow.withOpacity(hasHighlight ? 0.25 : 0.12),
        blurRadius: hasHighlight ? 18 : 10,
        offset: Offset(0, hasHighlight ? 10 : 6),
      ),
    ];
    final double anchorOpacity = isAnchor
        ? (widget.isDragging
            ? 0.85
            : (widget.isSelected || widget.isDropTarget ? 0.75 : 0.6))
        : 0;

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
        duration: hasHighlight ? _animationDuration : _pressDuration,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.tile.color,
            borderRadius: tileRadius,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: tileShadows,
          ),
          child: ClipRRect(
            borderRadius: tileRadius,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AnimatedOpacity(
                  opacity: overlayOpacity,
                  duration: _animationDuration,
                  curve: Curves.easeOut,
                  child: const ColoredBox(color: Colors.white),
                ),
                if (isAnchor)
                  Center(
                    child: AnimatedOpacity(
                      opacity: anchorOpacity,
                      duration: _animationDuration,
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: widget.isDragging ? 1.08 : 1.0,
                        duration: _animationDuration,
                        curve: Curves.easeOut,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '×',
                            style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: colors.shadow.withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ) ??
                                TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: colors.shadow.withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
