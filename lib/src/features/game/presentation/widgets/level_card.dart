import 'package:flutter/material.dart';

import '../../domain/entities/level.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.level, this.onTap});

  final Level level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: level.isUnlocked ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                level.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                level.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Icon(level.isUnlocked ? Icons.lock_open : Icons.lock),
            ],
          ),
        ),
      ),
    );
  }
}
