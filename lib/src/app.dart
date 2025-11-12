import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/state/game_notifier.dart';

class ColorPuzzleApp extends StatelessWidget {
  const ColorPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameNotifier>(
          create: (_) => GameNotifier()..initialize(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Color Puzzle Relax',
        theme: AppTheme.light,
        routerConfig: createRouter(),
      ),
    );
  }
}
