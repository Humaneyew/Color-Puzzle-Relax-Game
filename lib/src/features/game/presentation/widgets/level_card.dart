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
        ? colors.primaryContainer.withOpacity(0.8)
        : colors.surfaceVariant;
    final Color borderColor = isUnlocked
        ? colors.primary
        : colors.outlineVariant ?? colors.outline.withOpacity(0.5);
    final TextStyle numberStyle = (theme.textTheme.titleLarge ??
            const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))
        .copyWith(
      fontWeight: FontWeight.w700,
      color: isUnlocked ? colors.onPrimaryContainer : colors.onSurfaceVariant,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isUnlocked ? 2 : 1,
            ),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 12,
                  left: 12,
                  child: Text(
                    number.toString(),
                    style: theme.textTheme.labelLarge?.copyWith(
                          color: isUnlocked
                              ? colors.onPrimaryContainer.withOpacity(0.8)
                              : colors.onSurfaceVariant.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? colors.onPrimaryContainer.withOpacity(0.8)
                              : colors.onSurfaceVariant.withOpacity(0.8),
                        ),
                  ),
                ),
                if (isUnlocked)
                  Center(
                    child: Text(
                      number.toString(),
                      style: numberStyle,
                    ),
                  ),
                if (!isUnlocked)
                  Center(
                    child: Icon(
                      Icons.lock,
                      color: colors.onSurfaceVariant.withOpacity(0.8),
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
