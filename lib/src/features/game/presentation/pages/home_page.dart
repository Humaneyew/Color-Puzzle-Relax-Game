import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/level.dart';
import '../state/game_notifier.dart';
import '../state/game_state.dart';
import '../widgets/level_card.dart';
import 'level_overview_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = 'home';
  static const String routePath = '/';

  @override
  Widget build(BuildContext context) {
    final GameState state = context.watch<GameNotifier>().state;

    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _TopBar(
                onCompleteSession: state.session == null
                    ? null
                    : () => context.read<GameNotifier>().completeCurrentSession(),
              ),
              const SizedBox(height: 24),
              Text(
                'COLOR',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 32,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'PUZZLE',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 32,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a Level to Start',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Relaxing and elegant. No pressure.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GameState state) {
    switch (state.status) {
      case GameStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case GameStatus.error:
        return Center(child: Text(state.errorMessage ?? 'Unknown error'));
      case GameStatus.ready:
      case GameStatus.inSession:
        return _LevelGrid(levels: state.levels);
      case GameStatus.initial:
        return const SizedBox.shrink();
    }
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.levels});

  final List<Level> levels;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppConstants.defaultBoardSize,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: levels.length,
      itemBuilder: (BuildContext context, int index) {
        final Level level = levels[index];
        return LevelCard(
          level: level,
          number: index + 1,
          onTap: level.isUnlocked
              ? () => context.push(
                    LevelOverviewPage.routePath.replaceFirst(':levelId', level.id),
                  )
              : null,
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onCompleteSession});

  final VoidCallback? onCompleteSession;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _StatusBadge(
          icon: Icons.play_arrow,
          label: '',
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          onTap: onCompleteSession,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: foregroundColor),
          if (label.isNotEmpty) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foregroundColor,
                  ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: content,
    );
  }
}
