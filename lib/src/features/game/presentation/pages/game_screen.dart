import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/game_session.dart';
import '../state/board_controller.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';
import '../widgets/board_grid.dart';
import '../widgets/game_results_dialog.dart';
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
  bool _showResultsOverlay = false;
  bool _showResultsDialog = false;
  bool _wasShowingResults = false;

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

        if (_wasShowingResults != state.showResults) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _wasShowingResults = state.showResults;
              if (state.showResults) {
                _showResultsOverlay = true;
                _showResultsDialog = true;
              } else {
                _showResultsOverlay = false;
                _showResultsDialog = false;
              }
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
                    onShare: () {
                      _handleShare(session);
                    },
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
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            ignoring: !_showResultsDialog,
                                            child: _WinOverlay(
                                              visible: _showResultsOverlay,
                                              showDialog: _showResultsDialog,
                                              movesCount: session.movesUsed,
                                              bestScore: null,
                                              worldAverage: null,
                                              onContinue: _handleContinueResults,
                                              onViewPuzzle: _handleViewPuzzle,
                                              onRetry: () =>
                                                  _handleRetry(context, notifier),
                                              onShare: () {
                                                _handleShare(session);
                                              },
                                              reducedMotion: reducedMotion,
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
            ],
          ),
        );
      },
    );
  }

  void _handleContinueResults() {
    if (!_showResultsDialog) {
      return;
    }
    setState(() {
      _showResultsDialog = false;
    });
  }

  void _handleViewPuzzle() {
    if (!_showResultsOverlay && !_showResultsDialog) {
      return;
    }
    setState(() {
      _showResultsDialog = false;
      _showResultsOverlay = false;
    });
  }

  Future<void> _handleRetry(
    BuildContext context,
    GameNotifier notifier,
  ) async {
    final GameSession? session = notifier.state.session;
    if (session == null) {
      return;
    }
    setState(() {
      _requestedSession = true;
      _showResultsDialog = false;
      _showResultsOverlay = false;
      _wasShowingResults = false;
    });
    _boardController.clearSelection();
    await notifier.startLevel(session.level.id);
  }

  Future<void> _handleShare(GameSession session) async {
    final String levelValue =
        session.level.title.isNotEmpty ? session.level.title : session.level.id;
    final String message =
        'I just solved "$levelValue" in ${session.movesUsed} moves in Color Puzzle Relax!';
    await Share.share(
      message,
      subject: 'Color Puzzle Relax',
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
    required this.showDialog,
    required this.movesCount,
    required this.bestScore,
    required this.worldAverage,
    required this.onContinue,
    required this.onViewPuzzle,
    required this.onRetry,
    required this.onShare,
    required this.reducedMotion,
  });

  final bool visible;
  final bool showDialog;
  final int movesCount;
  final int? bestScore;
  final int? worldAverage;
  final VoidCallback onContinue;
  final VoidCallback onViewPuzzle;
  final VoidCallback onRetry;
  final VoidCallback onShare;
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          color: visible
              ? theme.colorScheme.scrim
                  .withOpacity(showDialog ? 0.45 : 0.2)
              : Colors.transparent,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GameResultsDialog(
                visible: showDialog,
                movesCount: movesCount,
                bestScore: bestScore,
                worldAverage: worldAverage,
                onContinue: onContinue,
                onViewPuzzle: onViewPuzzle,
                onRetry: onRetry,
                onShare: onShare,
                reducedMotion: reducedMotion,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
