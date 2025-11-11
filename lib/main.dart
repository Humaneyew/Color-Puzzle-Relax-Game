import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'src/data/level.dart';
import 'src/logic/game_session.dart';
import 'src/logic/services/ad_service.dart';
import 'src/logic/services/sound_service.dart';
import 'src/screens/level_select_screen.dart';
import 'src/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final soundService = SoundService();
  runApp(ColorPuzzleApp(soundService: soundService));
}

class ColorPuzzleApp extends StatefulWidget {
  const ColorPuzzleApp({required this.soundService, super.key});

  final SoundService soundService;

  @override
  State<ColorPuzzleApp> createState() => _ColorPuzzleAppState();
}

class _ColorPuzzleAppState extends State<ColorPuzzleApp> {
  late final GameSession _session;

  @override
  void initState() {
    super.initState();
    unawaited(widget.soundService.start());
    _session = GameSession(
      levels: _createLevels(),
      adService: const AdService(),
    );
  }

  @override
  void dispose() {
    unawaited(widget.soundService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameSession>.value(
      value: _session,
      child: MaterialApp(
        title: 'Color Puzzle Relax Game',
        theme: buildAppTheme(),
        home: const LevelSelectScreen(),
      ),
    );
  }

  List<GradientPuzzleLevel> _createLevels() {
    return const [
      GradientPuzzleLevel(
        id: 'sunset-serenity',
        name: 'Sunset Serenity',
        gridSize: 4,
        palette: [
          Color(0xFF0F172A),
          Color(0xFF1D4ED8),
          Color(0xFFF97316),
          Color(0xFFFFC857),
        ],
        fixedCells: {0, 5, 10, 15},
      ),
      GradientPuzzleLevel(
        id: 'forest-hush',
        name: 'Forest Hush',
        gridSize: 5,
        palette: [
          Color(0xFF022C22),
          Color(0xFF047857),
          Color(0xFF4ADE80),
          Color(0xFFA7F3D0),
        ],
        fixedCells: {0, 6, 18, 24},
      ),
      GradientPuzzleLevel(
        id: 'aurora-dream',
        name: 'Aurora Dream',
        gridSize: 6,
        palette: [
          Color(0xFF111827),
          Color(0xFF7C3AED),
          Color(0xFFEC4899),
          Color(0xFFFDE68A),
        ],
        fixedCells: {0, 11, 17, 35},
      ),
    ];
  }
}
