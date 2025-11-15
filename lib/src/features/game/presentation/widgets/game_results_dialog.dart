import 'package:flutter/material.dart';

class GameResultsDialog extends StatefulWidget {
  const GameResultsDialog({
    super.key,
    required this.visible,
    required this.movesCount,
    this.bestScore,
    this.worldAverage,
    required this.onContinue,
    required this.onViewPuzzle,
    required this.onRetry,
    this.onShare,
    required this.reducedMotion,
  });

  final bool visible;
  final int movesCount;
  final int? bestScore;
  final int? worldAverage;
  final VoidCallback onContinue;
  final VoidCallback onViewPuzzle;
  final VoidCallback onRetry;
  final VoidCallback? onShare;
  final bool reducedMotion;

  @override
  State<GameResultsDialog> createState() => _GameResultsDialogState();
}

class _GameResultsDialogState extends State<GameResultsDialog>
    with SingleTickerProviderStateMixin {
  static const Duration _defaultDuration = Duration(milliseconds: 280);

  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.reducedMotion ? Duration.zero : _defaultDuration,
      reverseDuration: widget.reducedMotion ? Duration.zero : _defaultDuration,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scale = Tween<double>(begin: 0.92, end: 1).animate(_opacity);

    if (widget.visible) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(GameResultsDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      final Duration duration =
          widget.reducedMotion ? Duration.zero : _defaultDuration;
      _controller
        ..duration = duration
        ..reverseDuration = duration;
    }
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        if (widget.reducedMotion) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      } else {
        if (widget.reducedMotion) {
          _controller.value = 0;
        } else {
          _controller.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: _DialogContent(
          movesCount: widget.movesCount,
          bestScore: widget.bestScore,
          worldAverage: widget.worldAverage,
          onContinue: widget.onContinue,
          onViewPuzzle: widget.onViewPuzzle,
          onRetry: widget.onRetry,
          onShare: widget.onShare,
        ),
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.movesCount,
    required this.bestScore,
    required this.worldAverage,
    required this.onContinue,
    required this.onViewPuzzle,
    required this.onRetry,
    this.onShare,
  });

  final int movesCount;
  final int? bestScore;
  final int? worldAverage;
  final VoidCallback onContinue;
  final VoidCallback onViewPuzzle;
  final VoidCallback onRetry;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    String formatValue(int? value) => value == null ? '--' : '$value';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                theme.colorScheme.primaryContainer.withOpacity(0.6),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Awesome!',
                  style: textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You solved the puzzle!',
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _StatTile(
                          label: 'Move Count',
                          value: formatValue(movesCount),
                          align: TextAlign.left,
                        ),
                        _StatDivider(color: theme.colorScheme.outlineVariant),
                        _StatTile(
                          label: 'Best Score',
                          value: formatValue(bestScore),
                        ),
                        _StatDivider(color: theme.colorScheme.outlineVariant),
                        _StatTile(
                          label: 'World Average',
                          value: formatValue(worldAverage),
                          align: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onContinue,
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onViewPuzzle,
                    child: const Text('View Puzzle'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.align = TextAlign.center,
  });

  final String label;
  final String value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align == TextAlign.left
            ? CrossAxisAlignment.start
            : align == TextAlign.right
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
            textAlign: align,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: align,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: VerticalDivider(
        width: 24,
        thickness: 1.2,
        color: color.withOpacity(0.6),
      ),
    );
  }
}
