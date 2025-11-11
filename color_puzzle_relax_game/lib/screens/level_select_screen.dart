import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/level.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = context.watch<GameSession>().levels;
    return Scaffold(
      appBar: AppBar(title: const Text('Вибір рівня')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: levels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final level = levels[index];
          return _LevelCard(level: level);
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final GradientPuzzleLevel level;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: level.id,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<GameSession>().selectLevel(level);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GameScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        for (var i = 0; i < level.palette.length; i++)
                          level.palette[i],
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${level.gridSize} x ${level.gridSize}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
