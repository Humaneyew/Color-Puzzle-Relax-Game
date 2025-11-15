import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/tile.dart';
import '../state/board_controller.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';
import '../widgets/board_grid.dart';
import '../widgets/victory_wave.dart';
import 'home_page.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  static const String routeName = 'game';
  static const String routePath = '/play/:levelId/game';

  final String levelId;

  static String pathFor(String levelId) =>
      routePath.replaceFirst(':levelId', levelId);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BoardController _boardController;
  bool _requestedSession = false;
  bool _showCompletionTitle = false;

  @override
  void initState() {
    super.initState();
    _boardController = BoardController(context.read<GameNotifier>());
  }

  @override
  void didUpdateWidget(GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      _requestedSession = false;
      _boardController.clearSelection();
    }
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Consumer<GameNotifier>(
      builder: (BuildContext context, GameNotifier notifier, Widget? child) {
        final GameState state = notifier.state;
        final GameSession? session = state.session;
        final bool hasSession =
            session != null && session.level.id == widget.levelId;

        if (!hasSession && !_requestedSession) {
          _requestedSession = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifier.startLevel(widget.levelId);
          });
        }

        _boardController.attachSession(hasSession ? session : null);

        if (state.showResults) {
          _boardController.clearSelection();
        }

        if (!hasSession || state.status == GameStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_showCompletionTitle != state.showResults) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _showCompletionTitle = state.showResults;
            });
          });
        }

        final String levelValue =
            session.level.title.isNotEmpty ? session.level.title : session.level.id;
        final String levelLabel =
            _showCompletionTitle ? 'LEVEL COMPLETED!' : 'LEVEL $levelValue';

        return Scaffold(
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _GameHud(
                    levelLabel: levelLabel,
                    movesUsed: session.movesUsed,
                    reducedMotion: reducedMotion,
                    onBack: () => _handleExitToLevels(context),
                    onShare: () {},
                    onHints: () {},
                    onNext: state.showResults ? () => _handleNextLevel(context) : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 16),
                          Expanded(
                            child: LayoutBuilder(
                              builder:
                                  (BuildContext context, BoxConstraints constraints) {
                                final double boardSize =
                                    min(constraints.maxWidth, constraints.maxHeight);

                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    width: boardSize,
                                    height: boardSize,
                                    child: Stack(
                                      children: <Widget>[
                                        BoardGrid(
                                          board: session.board,
                                          controller: _boardController,
                                          disableInteractions: state.showResults,
                                        ),
                                        Positioned.fill(
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: VictoryWave(
                                              active: state.showVictoryWave,
                                              borderRadius: BorderRadius.circular(28),
                                              reducedMotion: reducedMotion,
                                              onCompleted: notifier.dismissVictoryWave,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !state.showResults,
                  child: _WinOverlay(
                    visible: state.showResults,
                    board: session.board,
                    hasNextLevel: notifier.nextLevelId() != null,
                    onNextLevel: () => _handleNextLevel(context),
                    onReturnToMenu: () => _handleReturnToMenu(context),
                    reducedMotion: reducedMotion,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleNextLevel(BuildContext context) async {
    final GameNotifier notifier = context.read<GameNotifier>();
    final String? nextLevelId = notifier.nextLevelId();
    if (nextLevelId == null) {
      await notifier.completeCurrentSession();
      if (!mounted) {
        return;
      }
      context.go(HomePage.routePath);
      return;
    }

    await notifier.completeCurrentSession();
    if (!mounted) {
      return;
    }
    await notifier.startLevel(nextLevelId);
    if (!mounted) {
      return;
    }
    setState(() {
      _requestedSession = true;
    });
    context.go(GameScreen.pathFor(nextLevelId));
  }

  Future<void> _handleReturnToMenu(BuildContext context) async {
    final GameNotifier notifier = context.read<GameNotifier>();
    await notifier.completeCurrentSession();
    if (!mounted) {
      return;
    }
    context.go(HomePage.routePath);
  }

  void _handleExitToLevels(BuildContext context) {
    final GameNotifier notifier = context.read<GameNotifier>();
    notifier.abandonSession();
    context.go(HomePage.routePath);
  }
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.levelLabel,
    required this.movesUsed,
    required this.reducedMotion,
    required this.onBack,
    required this.onShare,
    required this.onHints,
    this.onNext,
  });

  final String levelLabel;
  final int movesUsed;
  final bool reducedMotion;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onHints;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? levelStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final TextStyle? movesStyle = theme.textTheme.bodyMedium?.copyWith(
      letterSpacing: 0.8,
    );
    final Duration animationDuration =
        reducedMotion ? Duration.zero : const Duration(milliseconds: 220);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              onPressed: onBack,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: animationDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      if (reducedMotion) {
                        return child;
                      }
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      levelLabel,
                      key: ValueKey<String>(levelLabel),
                      textAlign: TextAlign.center,
                      style: levelStyle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: animationDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      if (reducedMotion) {
                        return child;
                      }
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      'MOVES $movesUsed',
                      key: ValueKey<int>(movesUsed),
                      style: movesStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  tooltip: 'Share',
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Hints',
                  onPressed: onHints,
                  icon: const Icon(Icons.lightbulb_outline),
                ),
                AnimatedSwitcher(
                  duration: animationDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    if (reducedMotion) {
                      return child;
                    }
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: onNext == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilledButton(
                            key: const ValueKey<String>('next'),
                            onPressed: onNext,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Next'),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WinOverlay extends StatelessWidget {
  const _WinOverlay({
    required this.visible,
    required this.board,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onReturnToMenu,
    required this.reducedMotion,
  });

  final bool visible;
  final Board board;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onReturnToMenu;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Duration duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'LEVEL COMPLETED!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!hasNextLevel)
                      _OverlayActionButton(
                        label: 'MENU',
                        onPressed: visible ? onReturnToMenu : null,
                        variant: _OverlayActionVariant.primary,
                      ),
                    if (hasNextLevel)
                      _OverlayActionButton(
                        label: 'MENU',
                        onPressed: visible ? onReturnToMenu : null,
                        variant: _OverlayActionVariant.outlined,
                      ),
                    if (hasNextLevel) const SizedBox(width: 12),
                    if (hasNextLevel)
                      _OverlayActionButton(
                        label: 'NEXT',
                        onPressed: visible ? onNextLevel : null,
                        variant: _OverlayActionVariant.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final double boardSize =
                          min(constraints.maxHeight, constraints.maxWidth);
                      return Center(
                        child: SizedBox(
                          width: boardSize,
                          height: boardSize,
                          child: _SolvedBoardPoster(board: board),
                        ),
                      );
                    },
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

class _SolvedBoardPoster extends StatelessWidget {
  const _SolvedBoardPoster({required this.board});

  final Board board;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int gridSize = board.size;
        final double extent = min(constraints.maxWidth, constraints.maxHeight);
        final double tileSize = extent / gridSize;

        return RepaintBoundary(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: board.tiles.map((Tile tile) {
                final int row = tile.correctIndex ~/ gridSize;
                final int column = tile.correctIndex % gridSize;
                final double left = column * tileSize;
                final double top = row * tileSize;
                final double width =
                    column == gridSize - 1 ? extent - left : tileSize;
                final double height =
                    row == gridSize - 1 ? extent - top : tileSize;
                return Positioned(
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: ColoredBox(color: tile.color),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

enum _OverlayActionVariant { primary, outlined }

class _OverlayActionButton extends StatelessWidget {
  const _OverlayActionButton({
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  final String label;
  final VoidCallback? onPressed;
  final _OverlayActionVariant variant;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    late final ButtonStyle baseStyle;
    switch (variant) {
      case _OverlayActionVariant.primary:
        baseStyle = FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        );
        break;
      case _OverlayActionVariant.outlined:
        baseStyle = OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        );
        break;
    }

    switch (variant) {
      case _OverlayActionVariant.primary:
        return FilledButton(
          style: baseStyle,
          onPressed: onPressed,
          child: Text(label),
        );
      case _OverlayActionVariant.outlined:
        return OutlinedButton(
          style: baseStyle,
          onPressed: onPressed,
          child: Text(label),
        );
    }
  }
}
