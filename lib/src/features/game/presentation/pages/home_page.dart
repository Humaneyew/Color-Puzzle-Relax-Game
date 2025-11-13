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
  static const String routePath = '/levels';

  @override
  Widget build(BuildContext context) {
    final GameState state = context.watch<GameNotifier>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Puzzle Relax'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Choose a Level to Start',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.session == null
            ? null
            : () => context.read<GameNotifier>().completeCurrentSession(),
        label: const Text('Complete session'),
        icon: const Icon(Icons.check),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppConstants.defaultBoardSize,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: levels.length,
      itemBuilder: (BuildContext context, int index) {
        final Level level = levels[index];
        return LevelCard(
          level: level,
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
