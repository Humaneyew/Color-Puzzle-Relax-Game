import 'package:flutter/material.dart';

import '../game_board.dart';

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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? Colors.white : Colors.white24,
            width: isHighlighted ? 3 : 1,
          ),
          boxShadow: [
            if (!tile.fixed)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: tile.fixed
            ? const Icon(
                Icons.lock,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
