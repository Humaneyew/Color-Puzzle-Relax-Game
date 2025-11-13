import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/game_session.dart';
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

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleExitToLevels(context),
            ),
            title: Text(session.level.title),
          ),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _GameHeader(session: session),
                      const SizedBox(height: 16),
                      Flexible(
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
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
                      _GameFooter(session: session),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !state.showResults,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: _ResultsPanel(
                          visible: state.showResults,
                          session: session,
                          hasNextLevel: notifier.nextLevelId() != null,
                          onNextLevel: () => _handleNextLevel(context),
                          onReturnToMenu: () => _handleReturnToMenu(context),
                          reducedMotion: reducedMotion,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? titleStyle =
        theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600);
    final TextStyle? subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(session.level.title, style: titleStyle),
        const SizedBox(height: 4),
        Text(session.level.description, style: subtitleStyle),
      ],
    );
  }
}

class _GameFooter extends StatelessWidget {
  const _GameFooter({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? labelStyle = theme.textTheme.titleMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Moves used', style: labelStyle),
        Text(
          session.movesUsed.toString(),
          style: labelStyle?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.visible,
    required this.session,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onReturnToMenu,
    required this.reducedMotion,
  });

  final bool visible;
  final GameSession session;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onReturnToMenu;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Duration duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 280);

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.2),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        child: Material(
          elevation: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Level Complete!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Moves used: ${session.movesUsed}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                if (hasNextLevel)
                  FilledButton(
                    onPressed: visible ? onNextLevel : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Next level'),
                  ),
                if (hasNextLevel) const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: visible ? onReturnToMenu : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(hasNextLevel ? 'Back to menu' : 'Return to menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
