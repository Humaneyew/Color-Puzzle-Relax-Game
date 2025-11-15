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
                            return SizedBox.expand(
                              child: Stack(
                                fit: StackFit.expand,
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
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
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
