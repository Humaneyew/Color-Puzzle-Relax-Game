import 'package:flutter/material.dart';

import '../data/tile.dart';

class GradientTileWidget extends StatelessWidget {
  const GradientTileWidget({
    required this.tile,
    required this.size,
    required this.isHighlighted,
    this.dimmed = false,
    super.key,
  });

  final GradientTile tile;
  final double size;
  final bool isHighlighted;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final borderColor = isHighlighted
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: tile.fixed ? 0.4 : 0.25);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.2 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tile.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isHighlighted ? 3 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: tile.fixed ? 0.05 : 0.12),
              blurRadius: tile.fixed ? 6 : 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: tile.fixed
            ? Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: size * 0.35,
                ),
              )
            : null,
      ),
    );
  }
}
