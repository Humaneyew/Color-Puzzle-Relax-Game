import 'package:flutter/material.dart';

import '../../domain/entities/level.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    required this.number,
    this.onTap,
  });

  final Level level;
  final int number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isUnlocked = level.isUnlocked;

    final Color backgroundColor = isUnlocked
        ? colors.primaryContainer
        : const Color(0xFFD9C199);
    final Color borderColor = isUnlocked
        ? colors.primary
        : colors.outlineVariant ?? colors.outline.withOpacity(0.5);
    final BorderRadius borderRadius = BorderRadius.circular(8);
    final TextStyle numberStyle = (theme.textTheme.titleLarge ??
            const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))
        .copyWith(
      fontWeight: FontWeight.w700,
      color: isUnlocked ? colors.onPrimaryContainer : colors.onSurfaceVariant,
    );

    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double dimension = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : constraints.biggest.shortestSide;

          return InkWell(
            onTap: isUnlocked ? onTap : null,
            borderRadius: borderRadius,
            child: SizedBox.square(
              dimension: dimension,
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          number.toString(),
                          style: numberStyle,
                        )
                      : Icon(
                          Icons.lock,
                          color: colors.onSurfaceVariant.withOpacity(0.8),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
