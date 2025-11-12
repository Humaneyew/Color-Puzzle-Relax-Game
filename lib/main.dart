import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'src/logic/game_session.dart';
import 'src/logic/services/ad_service.dart';
import 'src/logic/services/level_loader.dart';
import 'src/logic/services/progress_repository.dart';
import 'src/logic/services/sound_service.dart';
import 'src/screens/level_select_screen.dart';
import 'src/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final soundService = SoundService();
  final levelLoader = const LevelLoader();
  final levels = await levelLoader.loadLevels();
  final progressRepository = await ProgressRepository.create();
  final session = GameSession(
    levels: levels,
    adService: const AdService(),
    progressRepository: progressRepository,
  );
  await session.restore();
  runApp(
    ColorPuzzleApp(
      soundService: soundService,
      session: session,
    ),
  );
}

class ColorPuzzleApp extends StatefulWidget {
  const ColorPuzzleApp({
    required this.soundService,
    required this.session,
    super.key,
  });

  final SoundService soundService;
  final GameSession session;

  @override
  State<ColorPuzzleApp> createState() => _ColorPuzzleAppState();
}

class _ColorPuzzleAppState extends State<ColorPuzzleApp> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.soundService.start());
  }

  @override
  void dispose() {
    unawaited(widget.soundService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameSession>.value(
      value: widget.session,
      child: MaterialApp(
        title: 'Color Puzzle Relax Game',
        theme: buildAppTheme(),
        home: const LevelSelectScreen(),
      ),
    );
  }
}

